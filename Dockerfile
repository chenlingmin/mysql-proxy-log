FROM centos:7.2.1511

WORKDIR /root
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
    && yum install -y mysql-proxy.x86_64 

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 3306
EXPOSE 4041

ENV LOG_LEVEL debug
ENV ADMIN_USER admin
ENV ADMIN_PASSWORD admin
ENV MASTER_ADDRESSES 127.0.0.1:3306
ENV PROXY_LUA_SCRIPT /usr/lib64/mysql-proxy/lua/proxy/test.lua

ADD src/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

