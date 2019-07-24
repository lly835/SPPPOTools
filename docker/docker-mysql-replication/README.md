#### 通过脚本在Docker环境中一键安装master主从环境

>  日期：2019-07-24    
>  类别：docker     
>  标题：通过脚本在Docker环境中一键安装master主从环境      
>  作者：黄高明

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |   mac for docker |  实测通过  |
| 支持平台    |   Debian, Ubuntu, Fedora, CentOS and Arch Linux...Docker |    |
| git路径    |   [setup.sh](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/docker/docker-mysql-replication/setup.sh)  |    |
| 脚本名称    |   setup.sh  |    |
| 执行方式    |   /bin/bash setup.sh  |    |
| 是否需要传参数    |   否  |    |
| 是否有配置参数    |   有,见下  |    |

**配置参数**`setup.sh`     

其中`hostip`是必须修改的,其他配置可以酌情修改.       
注意: 如果你的Docker环境是通过Docker Toolbox,且是安装在windows环境,建议将isToolBox=1.     
因为windows下数据目录共享可能会出现磁盘异步io的异常,此时通过设置`--skip-innodb-use-native-aio`关闭异步io之后就会正常.关闭异步io会导致性能下降,此参数仅建议用于测试。磁盘异步IO介绍请参考:[https://dev.mysql.com/doc/refman/5.7/en/innodb-linux-native-aio.html](https://dev.mysql.com/doc/refman/5.7/en/innodb-linux-native-aio.html)     

mysqld启动参数查询:`mysqld --verbose --help |grep aio`


```
logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=0               #是否记录日志: 1记录 0不记录
hostip="10.0.0.107"    #docker host machine 
networkName="o2o-network"       #docker网络
dockerMaster="o2o-mysql-master" #master 名称
dockerSlave="o2o-mysql-slave"   #slave 名称
rootPass="d3eb23f714529f1e73f934876d1b39" #root密码
replicationUser="backup"                  #复制账号
replicationPasss="04698e89512807"         #复制密码
masterPort=3307                           #master映射后端口
isToolBox=0                               #是否toolBox安装docker环境，1是 0否
dockerCompose="docker-compose.yml.template" #docker-compose.yml模板文件
memLimit="8g"               #内存限制
masterData=".\/master\/db"  #master数据目录
slaveData=".\/slave\/db"    #slave数据目录
waitMYSQLTime=30            #mysql初始化后等待时间,单位秒
waitSlaveTime=15            #mysql主从连接初始化后等待时间,单位秒
```


##### 操作说明         

- 初始化以及一键安装      
  `/bin/bash setup.sh`
- 删除数据文件且停止和删除容器  
  `/bin/bash setup.sh clean`    
- 初始化容器(build)   
  `/bin/bash setup.sh init`    
- 初始化配置容器   
  `/bin/bash setup.sh config`    


#### 运行截图     

![1](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/docker/docker-mysql-replication/images/1.png)

![2](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/docker/docker-mysql-replication/images/2.png)

