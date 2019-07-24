FROM daocloud.io/library/mysql:5.7.13
COPY my.cnf /etc/mysql/my.cnf
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone 
EXPOSE 3306
