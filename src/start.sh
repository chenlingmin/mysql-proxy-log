#!/bin/bash
LOG_FILE=/mysql-proxy/logs/mysql-proxy.log
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p /mysql-proxy/logs
    touch /mysql-proxy/logs/mysql-proxy.log
fi

mysql-proxy \
  --log-level=$LOG_LEVEL \
  --log-file=/mysql-proxy/logs/mysql-proxy.log \
  --user=root \
  --pid-file=/mysql-proxy/mysql-proxy.pid \
  --plugins=admin \
  --admin-address=0.0.0.0:4041 \
  --admin-username=$ADMIN_USER \
  --admin-password=$ADMIN_PASSWORD \
  --admin-lua-script=/usr/lib64/mysql-proxy/lua/admin.lua \
  --plugins=proxy \
  --proxy-address=0.0.0.0:3306 \
  --proxy-backend-addresses=$MASTER_ADDRESSES \
  --proxy-lua-script=$PROXY_LUA_SCRIPT 
