#!/bin/bash
#author: 黄高明
#date: 2019-07-24
#qq: 530035210
#blog: https://www.pvcreate.com/
#一键创建MYSQL主从同步for Docker

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

datef(){
    date "+%Y-%m-%d %H:%M:%S"
}

print_log(){
    if [[ $is_log -eq 1  ]];then
        [[ -d $logdir ]] || mkdir -p $logdir
        echo -e "[ $(datef) ] $1" >> $log
    fi
    if [[ $is_font -eq 1  ]];then
        if [[ $2 -eq 1 ]]; then
            echo -e "[ $(datef) ] \033[31m$1\033[0m"
        else
            echo -e "[ $(datef) ] \033[32m$1\033[0m"
        fi      
    fi
}


checkMysql(){
    name=$1
    result=`docker exec -ti $name  mysql -p"${rootPass}" -e "select version()"`
    if [[ $? -eq 0 ]]; then
        mysql_running=0
    else
        mysql_running=1
    fi
}

runCommand(){
    name=$1
    cmd=$2
    result=`docker exec -ti $name  mysql -p"${rootPass}" -e "${cmd}"`
    if [[ $? -eq 0 ]]; then
        run=0
    else
        run=1
    fi
}

#init docker for mysql
init(){
    if [[ $isToolBox -eq 0 ]]; then
        dockerYaml=`cat $dockerCompose | sed  "s/,--skip-innodb-use-native-aio//g" ` 
    else
        dockerYaml=`cat $dockerCompose`      
    fi
    dockerYaml=`echo "$dockerYaml" | sed  "s/##rootPass##/${rootPass}/g"`
    dockerYaml=`echo "$dockerYaml" |sed "s/##masterData##/${masterData}/g"`
    dockerYaml=`echo "$dockerYaml" |sed "s/##slaveData##/${slaveData}/g"`
    dockerYaml=`echo "$dockerYaml" |sed  "s/##memLimit##/${memLimit}/g"`
    dockerYaml=`echo "$dockerYaml" |sed  "s/##dockerMaster##/${dockerMaster}/g"`
    dockerYaml=`echo "$dockerYaml" |sed  "s/##dockerSlave##/${dockerSlave}/g"`
    dockerYaml=`echo "$dockerYaml" |sed  "s/##networkName##/${networkName}/g"`
    echo "${dockerYaml}" > docker-compose.yml
    print_log  "$FUNCNAME(): init docker-compose.yml"
    if [[ -z `docker network ls  |grep "$networkName"` ]]; then
        docker network create $networkName && print_log "$FUNCNAME(): docker network : $networkName create successful!"  || print_log "$FUNCNAME(): docker network : $networkName create faild,exit!" 1
    else
        print_log "$FUNCNAME(): docker network : $networkName have exist" 
    fi
    print_log "$FUNCNAME(): start build and start docker container..."
    print_log "$FUNCNAME(): cmd: docker-compose up --build -d"
    docker-compose up --build -d
    print_log "$FUNCNAME(): waiting mysql startup....${waitMYSQLTime}s"
    sleep ${waitMYSQLTime} 
    checkMysql $dockerMaster
    if [[ $mysql_running -ne 0 ]]; then
        print_log "$FUNCNAME(): mysql master build faild,please check,exit" 1
        exit
    fi
    checkMysql $dockerSlave
    if [[ $mysql_running -ne 0 ]]; then
        print_log "$FUNCNAME(): mysql slave build faild,please check,exit" 1
        exit
    fi
    print_log "$FUNCNAME(): mysql master and  slave build and connect test successful"  
}

#config master and slave
config(){

    runCommand $dockerMaster "GRANT REPLICATION SLAVE ON *.* to '${replicationUser}'@'%' identified by '${replicationPasss}';flush privileges;"
    if [[ $run -ne 0 ]]; then
        print_log "result:${result}"
        print_log "$FUNCNAME(): create replicationUser faild" 1
        exit
    fi

    runCommand $dockerMaster "show master status;"
    posFile=`echo "$result" |grep "mysql-bin" |awk -F'|' '{print $2}' |sed "s/ //g"`
    pos=`echo "$result" |grep "mysql-bin" |awk -F'|' '{print $3}'|sed "s/ //g"`
    print_log "$FUNCNAME():posFile:${posFile} pos:${pos}"
    if [[  -z ${posFile} ||  -z ${pos}  ]]; then
        print_log "result:${result}"
        print_log "get posFile or pos faild ,exit" 1
        exit
    fi

    runCommand $dockerSlave "change master to master_host='${hostip}',master_user='${replicationUser}',master_password='${replicationPasss}', master_log_file='${posFile}',master_log_pos=${pos},master_port=${masterPort};"
    if [[ $run -ne 0 ]]; then
        print_log "result:${result}"
        print_log "$FUNCNAME(): change master faild" 1
        exit
    fi

    runCommand $dockerSlave "start slave;"
    if [[ $run -ne 0 ]]; then
        print_log "result:${result}" 
        print_log "$FUNCNAME(): get slave status faild" 1
        exit
    fi
    print_log "$FUNCNAME(): waiting mysql slave startup....${waitSlaveTime}s"
    sleep ${waitSlaveTime}
    runCommand $dockerSlave "show slave status \G;"
    if [[ -z `echo "${result}" |grep "Slave_IO_Running" |grep "Yes"` || -z `echo "${result}" |grep "Slave_SQL_Running" |grep "Yes"` ]];then
        print_log "result:${result}"
        print_log "$FUNCNAME(): mysql master and slave sync faild" 1
        exit
    fi
    print_log "$FUNCNAME(): master and slave create successful,all done!" 
    exit 0

}

clean(){
    docker kill o2o-mysql-master o2o-mysql-slave
    docker rm o2o-mysql-master o2o-mysql-slave
    docker image rm docker-mysql-replication_mysql-master docker-mysql-replication_mysql-slave
    rm -rf master/db/* slave/db/*
    rm -f docker-compose.yml
}


case $1 in
    clean )
        clean
        ;;
    config )
        config
        ;;
    init )
        init
        ;;        
    * )
        init
        config        
        ;;   
esac




