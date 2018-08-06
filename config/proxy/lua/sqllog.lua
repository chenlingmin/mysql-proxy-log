local tokenizer = require("proxy.tokenizer")

local log_file  = "/mysql-proxy/logs/sql/sql-%s.log"
local logfd     = assert(io.open(string.format(log_file, os.date('%Y-%m-%d')), "a+"))
local stmt_token_namea = ""

function read_query( packet )
    if string.byte(packet) == proxy.COM_QUERY then
        local tokens    = tokenizer.tokenize(packet:sub(2))
        local stmt      = tokenizer.first_stmt_token(tokens)
        stmt_token_name = stmt.token_name 
        proxy.queries:append(1, packet, {resultset_is_needed = true})
        return proxy.PROXY_SEND_QUERY
    end
end

function read_query_result( inj )
    local con       = proxy.connection
    local query     = inj.query
    local res       = inj.resultset  
    local error     = "null"
    local row_count = 0
    local db_name   = con.client.default_db

    if string.len(db_name) == 0 then
        db_name = "null"
    end
    if res.affected_rows then
        row_count = res.affected_rows
    else
        local num_cols = string.byte(res.raw, 1)
        if num_cols > 0 and num_cols < 255 then
            for row in res.rows do
                row_count = row_count + 1
            end
        end
    end

    if res.query_status == proxy.MYSQLD_PACKET_ERR then
        error = string.format("%q", res.raw:sub(10))
    end
    
    logfd:write(
        string.format(
            "%s|%6d|%s-%s-%s|%s|%s|%s|%s|%s|%s|%s|%s|%sms|%s \n",
            os.date('%Y-%m-%d %H:%M:%S'),
            con.server["thread_id"],
            con.client.username,
            con.client.src.name,
            db_name,
            stmt_token_name,
            tostring(res.query_status),
            error,
            res.warning_count,
            tostring(res.flags.in_trans),
            tostring(res.flags.no_index_used),
            tostring(res.flags.no_good_index_used),
            row_count,
            inj.response_time / 1e3,
            string.gsub(query, "\n", " ")
        )
    )
    
    logfd:flush()

end
