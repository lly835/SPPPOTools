# docker-mysql-replication
基于docker 的MySQL主从配置

>基于:https://github.com/Evan1120/docker-mysql-replication 进行二次修改


# Running with docker-compose
Step1: 创建网络并启动容器
```
docker network create o2o-network
docker-compose up --build -d
```

Step2: 连接master，并运行以下命令，创建一个用户用来同步数据

```
winpty docker exec -ti  o2o-mysql-master mysql -p'd3eb23f714529f1e73f934876d1b39' -e "GRANT REPLICATION SLAVE ON *.* to 'backup'@'%' identified by '04698e89512807';flush privileges;"

```

查询账号是否创建成功的
```
winpty docker exec -ti  o2o-mysql-master mysql -ubackup -p'04698e89512807' -e "select version()"
```


Step3: 查看master status, 记住File、Position的值，如果没查到数据，请检查第一、第二步，配置问题。 
我查出来的是mysql-bin.000004、312
````
winpty docker exec -ti  o2o-mysql-master mysql -p'd3eb23f714529f1e73f934876d1b39' -e "show master status;"

````

Step4: 连接slave, 运行以下命令连接master
winpty docker exec -ti  o2o-mysql-master bash

````
change master to master_host='<master-ip>',master_user='backup',master_password='123456', master_log_file='mysql-bin.000004',master_log_pos=312,master_port=3307;
````

Step5: 启动slave
````
start slave;
````

Step6: 查看slave status。
````
show slave status;
````

如果看到Waiting for master send event 什么的就成功了，你现在在主库上的修改，都会同步到从库上。



