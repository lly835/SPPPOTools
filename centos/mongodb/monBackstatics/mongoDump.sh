#!/bin/bash
#author: 黄高明
#date: 2017-09-26
#qq: 530035210
#blog: http://my.oschina.net/pwd/blog
#统计db数据以及自定义数据备份

logdir=/data/log/shelldb          #日志路径
log=$logdir/log.log            #日志文件
is_font=1                #终端是否打印日志: 1打印 0不打印
is_log=0                 #是否记录日志: 1记录 0不记录
mongodb_host=127.0.0.1
mongodb_port=27017
mongodb_admin_user=admin
mongodb_admin_pass=admin
mongo_bin=/usr/local/mongodb/bin/mongo #默认命令文件,不存在时会查找全局命令文件,全局找不到会退出
mongo_dump=/usr/local/mongodb/bin/mongodump
mongo_restore=/usr/local/mongodb/bin/mongorestore
mongodb_input=0 #是否打印mongodb执行结果
baseDir=$(cd `dirname $0`; pwd) #获取当前脚本工作路径
queryDir=$baseDir/query #自定义查询路径
dumpDir=$baseDir/dump #自定义查询后备份路径
deleteDir=$baseDir/delete #自定义删除代码路径
renameDir=$baseDir/rename #自定义查询rename路径
removeDir=$baseDir/remove #自定义查询remove路径
backDir=/data/backdir/mongodb #备份数据路径
fullBackstatus=0 #0:整库备份 1:自定义查询备份时自定义备份 2:有自定义备份时自定义备份,否则全量备份
now=`date "+%Y%m%d_%H%M%S"`
isCmdInput=1 #是否输出执行命令 1:输出 0:不输出
istar=1 #是否压缩备份 1:压缩 0:不压缩
isdelete=0 #是否开启delete 1:开启 0:关闭
deleteMaxCount=1000 #每次执行删除的最大条数,该参数只有当deleteMode=2时有用
deleteMode=2  #删除模式
delete_date=`date -d "145 days ago" +"%Y-%m-%d"` #全局删除日期
onlyDbname="" #如果只需要在1个或者多个指定的库中执行,可以在这配置,如果所有则配置为空即可
lockPidFile=/tmp/mongodb.pid

#删除模式 
#0:直接按照删除条件直接删除(如:db.collection.remove({"lastUpdated":{$lt:new Date("2017-04-10").getTime()}})) 
#1:按照先insert后renameCollection(比如复制大于2017-04-10到另外一个collection,删除原表,然后在重命名)
#2:根据查询条件,每次删除$deleteMaxCount条数量
#3:添加TTL INDEX删除(如果是这样方式,建议手工添加)

datef(){
    date "+%Y-%m-%d %H:%M:%S"
}

print_log(){
    if [[ $is_log -eq 1  ]];then
        [[ -d $logdir ]] || mkdir -p $logdir
        echo -e "[ $(datef) ] $1" >> $log
    fi
    if [[ $is_font -eq 1  ]];then
        echo -e "[ $(datef) ] $1"
    fi
}

#判断mongo_bin／mongo_dump／mongo_restore命令文件是否存在
#不存在时查找全局变量是否存在，如果全局不存在则退出操作
if [[  ! -f $mongo_bin ]]; then
    which mongo > /dev/null
    if [[ $? -eq 0  ]]; then
        mongo_bin=mongo
    else
        print_log "mongo命令文件不存在"
        exit 
    fi
fi

if [[  ! -f $mongo_dump ]]; then
    which mongodump > /dev/null
    if [[ $? -eq 0  ]]; then
        mongo_dump=mongodump
    else
        print_log "mongodump命令文件不存在"
        exit 
    fi
fi

if [[  ! -f $mongo_restore ]]; then
    which mongorestore > /dev/null
    if [[ $? -eq 0  ]]; then
        mongo_restore=mongorestore
    else
        print_log "mongorestore命令文件不存在"
        exit 
    fi
fi


#执行命令
runCmd(){
    cmd=$1
    host=$2
    user=$3
    pass=$4
    port=$5
    db=$6
    random=$7
    authdb=$8

    if [[  $cmd == "" ]] ;then
        print_log "执行命令不能为空"
        exit
    fi

    if [[  $db == "" ]] ;then
        print_log "执行数据库不能为空"
        exit
    fi

    if [[  $port == "" ]] ;then
        print_log "执行端口不能为空"
        exit
    fi

    if [[  $user == "" ]] ;then
        print_log "执行用户不能为空"
        exit
    fi

    if [[  $pass == "" ]] ;then
        print_log "执行密码不能为空"
        exit
    fi

    if [[  $host == "" ]] ;then
        print_log "执行主机不能为空"
        exit
    fi
    if [[  $random == "" ]] ;then
        print_log "随机数不能为空"
        exit
    fi
    if [[  $authdb == "" ]] ;then
        authdb=$db
    fi
    print_log ""
    print_log ""
    print_log "执行地址: $host 执行用户: $user  认证db: $authdb  执行db: $db"
    print_log "开始执行命令: $cmd"
    start=`date +%s`
    if [[ $isCmdInput -eq 1  ]];then
	print_log "echo '$cmd' | $mongo_bin --authenticationDatabase $authdb  $db  -u xxxx -p xxxx --host $host --port $port --shell"
    fi
    res=`echo "$cmd" | $mongo_bin --authenticationDatabase $authdb  ${db}  -u $user -p $pass --host $host --port $port --shell`
    if [[ $? -eq 0  ]]; then
        code=0
        print_log "执行mongo命令成功"
    else
        code=100
        print_log "执行mongo命令失败"
    fi
    if [[ $mongodb_input -eq 1  ]];then
        print_log "返回结果: \n $res"
    fi
    echo "$res" > /tmp/$random
    end=`date +%s`
    total=`expr $end - $start`
    print_log "结束执行命令: $cmd 耗时${total}秒"
    return $code
}


#执行备份命令
dump(){
    cmd=$1
    host=$2
    user=$3
    pass=$4
    port=$5
    db=$6
    random=$7
    table=$8
    out=$9
    authdb=${10}
    isfull=${11}	 
    if [[  $cmd == "" ]] ;then
        print_log "执行命令不能为空"
        exit
    fi

    if [[  $db == "" ]] ;then
        print_log "执行数据库不能为空"
        exit
    fi

    if [[  $port == "" ]] ;then
        print_log "执行端口不能为空"
        exit
    fi

    if [[  $user == "" ]] ;then
        print_log "执行用户不能为空"
        exit
    fi

    if [[  $pass == "" ]] ;then
        print_log "执行密码不能为空"
        exit
    fi

    if [[  $host == "" ]] ;then
        print_log "执行主机不能为空"
        exit
    fi
    if [[  $random == "" ]] ;then
        print_log "随机数不能为空"
        exit
    fi
    if [[  $table == "" ]] ;then
        print_log "table不能为空"
        exit
    fi
    if [[  $out == "" ]] ;then
        print_log "out输出路径不能为空"
        exit
    fi
    if [[  $authdb == "" ]] ;then
        authdb=$db
    fi
    if [[  $isfull == "" ]] ;then
        print_log "isfull不能为空"
        exit
    fi
    print_log ""
    print_log ""
    print_log "执行备份地址: $host 执行用户: $user  认证db: $authdb  执行db: $db 执行table: $table"
    print_log "执行查询备份命令: $cmd"
    print_log "fullBackstatus: ${fullBackstatus} isfull: ${isfull}"
    start=`date +%s`
    if [[ ${fullBackstatus} -eq 0 ]]; then
        print_log "开始执行全量整库备份"
        if [[ $isCmdInput -eq 1  ]];then
       		print_log "$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -o $out" 
        fi
        res=`$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -o $out`
    elif [[ ${fullBackstatus} -eq 1 && $isfull -ne 1 ]]; then
        print_log "开始执行自定义查询备份"
	if [[ $isCmdInput -eq 1  ]];then
	print_log "执行命令: $mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -c $table -q $cmd  -o $out"
	fi
        res=`$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -c $table -q $cmd  -o $out`   
    elif [[ ${fullBackstatus} -eq 2 ]]; then 
	if  [[ $isfull -eq 1  ]];then

        	print_log "开始执行全量整库备份"
	        if [[ $isCmdInput -eq 1  ]];then
        	        print_log "$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -o $out"
	        fi
       		res=`$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -o $out`
	else

        	print_log "开始执行自定义查询备份"
        	if [[ $isCmdInput -eq 1  ]];then
                	print_log "执行命令: $mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -c $table -q $cmd  -o $out"
        	fi
       		res=`$mongo_dump --authenticationDatabase $authdb -d $db  -u $user -p $pass --host $host --port $port  -c $table -q $cmd  -o $out`
	fi


    else 
        print_log "跳过备份."
        return 0  
    fi 
    if [[ $? -eq 0  ]]; then
        code=0
	if [[ $istar -eq 1  ]];then
		print_log "开始压缩 ${out}.tar.gz"
		tar -zcf ${out}.tar.gz   $out
		if [[ $? -eq 0  ]];then
			rm -rf $out
		fi
		print_log "压缩完成 ${out}.tar.gz"
		print_log "执行mongo备份成功,备份路径: ${out}.tar.gz"
	else
		print_log "执行mongo备份成功,备份路径: $out"
	fi
    else
        code=100
        print_log "执行mongo备份失败"
    fi
    if [[ $mongodb_input -eq 1  ]];then
        print_log "返回结果: \n $res"
    fi
    echo "$res" > /tmp/$random
    end=`date +%s`
    total=`expr $end - $start`
    print_log "结束执行备份: $cmd 耗时${total}秒"
    return $code
}


#查询数据
queryData(){

    #随机数
    random=`date +%s`

    #查看数据库
    runCmd "show dbs" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port admin $random
    if [[ $? -ne 0  ]];then
        print_log "查询db执行失败,退出"
        exit
    fi

    #获取数据库名
    dbList=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |awk '{print $1}'`
    print_log "##获取数据库名: `echo "$dbList" |xargs`"
    if [[ $onlyDbname != "" ]]; then
        print_log "开启数据库限定,查询或执行数据库为:`echo "$onlyDbname" |xargs`"
        dbList=$onlyDbname
    fi
    for i in $dbList
    do
	empty_line=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep "^${i} " |grep "empty" |wc -l`
	if [[  $empty_line -eq 1 ]];then
		print_log "该数据库${i} 为空,退出统计."
		continue
	fi
        print_log "开始查询数据库:$i"
        #获取数据表
        runCmd "show tables" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random admin
        if [[ $? -ne 0  ]];then
            print_log "查询表执行失败,退出"
            exit
        fi
        table=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`
	if [[ -z $table  ]];then
		print_log "${i}中数据表为空"
	else
		print_log "##获取数据表: `echo "$table" |xargs`"
	fi

	#获取数据库大小
        runCmd "db.stats()" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random admin
        if [[ $? -ne 0  ]];then
            print_log "查询数据库执行失败,退出"
            exit
        fi
	dbnumber=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode" |grep fileSize |wc -l`
	if [[ $dbnumber -eq 0   ]];then
	  dbsize=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode" |grep storageSize |awk -F':' '{print $2}' |awk -F',' '{print $1}'`
	else
	  dbsize=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode" |grep fileSize |awk -F':' '{print $2}' |awk -F',' '{print $1}'`
	fi
	dbsizek=`expr $dbsize / 1024 `
	dbsizem=`expr $dbsizek / 1024`
        dbsizeg=`expr $dbsizem / 1024`
	print_log "##数据库${i} 占用空间大小: ${dbsizeg}G/${dbsizem}M/${dbsizek}k"
        #获取数据表条数
        for j in $table
        do
            runCmd "db.$j.count()" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random admin
            if [[ $? -ne 0  ]];then
                print_log "查询数量执行失败,退出"
                exit
            fi
            table_count=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`
            print_log "##数据库名: $i 数据表: $j 数量: $table_count"
            #获取索引情况
            runCmd "db.$j.getIndexes()" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random admin
            if [[ $? -ne 0  ]];then
                print_log "查询执行失败,退出"
                exit
            fi
            index=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`

	    #获取数据表大小
            runCmd "db.$j.storageSize()" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random admin
            if [[ $? -ne 0  ]];then
                print_log "获取数据表大小执行失败,退出"
                exit
            fi	
	    table_size=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`	
            tdbsizek=`expr $table_size / 1024 `
            tdbsizem=`expr $tdbsizek / 1024`
            tdbsizeg=`expr $tdbsizem / 1024`
            print_log "##数据库名: $i 数据表: $j 数据库占用空间: ${tdbsizeg}G/${tdbsizem}M/${tdbsizek}k 索引信息: \n $index"


        done

            #如果有其他查询则执行
            if [[  -f $queryDir/$i.sh ]];then
                name=() #初始化数组
                execSQL=()
                print_log "###############################################################################################################"
                print_log "$i 存在其他查询,加载查询."
                source $queryDir/$i.sh
                print_log "$i 总共执行条数: $length"
                max=`expr $length - 1 `
                for num in `seq 0 $max`
                do
                    print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]}"
                    if [[ ${execSQL[$num]} == ""  ]];then
                        print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]} 该执行语句为空,跳过该步骤."
                        continue
                    fi

                    #执行自定义语句
                    runCmd "${execSQL[$num]}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin
                    if [[ $? -ne 0  ]];then
                        print_log "执行自定义查询失败,退出"
                        exit
                    fi
                    result=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`
                    print_log "##返回数据 执行描述: ${name[$num]}  执行结果:$result"
                    print_log ""

                done
                print_log "###############################################################################################################"
            fi


        #如果开启了删除,则执行删除
        if [[ $isdelete -eq 1  ]];then
        name=() #初始化数组
        execSQL=()
        print_log "---------------------------------------------------------------------------------------------------------------"
                
                #deleteMode=0直接根据条件删除
                if [[  -f ${deleteDir}/${i}.sh && $deleteMode -eq 0 ]];then
                    print_log "###############################################################################################################"
                    print_log "----------------------------------------start--delete模式-----------------------------------------------------------------------"
                    print_log "开始自定义删除${i}中的数据"
                    print_log "$i 存在自定义删除,加载code."
                    source ${deleteDir}/${i}.sh
                    print_log "$i 总共执行条数: $length"
                    max=`expr $length - 1 `
                    for num in `seq 0 $max`
                    do
                        print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]}"
                        if [[ ${execSQL[$num]} == ""  ]];then
                            print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]} 该执行语句为空,跳过该步骤."
                            continue
                        fi

                        #执行自定义语句
                        runCmd "${execSQL[$num]}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin
                        if [[ $? -ne 0  ]];then
                            print_log "执行自定义删除失败,退出"
                            exit
                        fi
                        result=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`
                        print_log "##返回数据 执行描述: ${name[$num]}  执行结果:$result"
                        print_log ""

                    done
                    print_log "结束自定义删除${i}中的数据"
                    print_log "------------------------------------------end--delete模式----------------------------------------------------------------------"
                    print_log "###############################################################################################################"
                else
                    print_log "${deleteDir}/${i}.sh不存在"
                fi


                #deleteMode=1查询后重新insert然后在rename
                if [[  -f ${renameDir}/${i}.sh && $deleteMode -eq 1 ]];then
                    print_log "###############################################################################################################"
                    print_log "----------------------------------------start--insert模式---------------------------------------------------------------------"
                    print_log "开始自定义删除${i}中的数据"
                    print_log "$i 存在自定义删除,加载code."
                    source ${renameDir}/${i}.sh
                    print_log "$i 总共执行条数: $length"
                    max=`expr $length - 1 `
                    for num in `seq 0 $max`
                    do
                        print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]}"
                        if [[ ${execSQL[$num]} == ""  ]];then
                            print_log "执行描述: ${name[$num]}  执行语句:${execSQL[$num]} 该执行语句为空,跳过该步骤."
                            continue
                        fi

                        #执行自定义语句
                        runCmd "${execSQL[$num]}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin
                        if [[ $? -ne 0  ]];then
                            print_log "执行自定义删除失败,退出"
                            exit
                        fi
                        result=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |grep -v "legacy" |grep -v "mode"`
                        print_log "##返回数据 执行描述: ${name[$num]}  执行结果:$result"
                        print_log ""

                    done
                    print_log "结束自定义删除${i}中的数据"
                    print_log "------------------------------------------end--insert模式----------------------------------------------------------------------"
                    print_log "###############################################################################################################"
                else
                    print_log "${renameDir}/${i}.sh不存在"
                fi                


                #deleteMode=2查询_id后然后在remove
                if [[  -f ${removeDir}/${i}.sh && $deleteMode -eq 2 ]];then
                    print_log "###############################################################################################################"
                    print_log "----------------------------------------start--remove模式---------------------------------------------------------------------"
                    print_log "开始自定义删除${i}中的数据"
                    print_log "$i 存在自定义删除,加载并执行code."
                    source ${removeDir}/${i}.sh
                    print_log "结束自定义删除${i}中的数据"
                    print_log "###############################################################################################################"
                    print_log "------------------------------------------end--remove模式----------------------------------------------------------------------"
                else
                    print_log "${renameDir}/${i}.sh不存在"
                fi                

                
                print_log "---------------------------------------------------------------------------------------------------------------"
        
        fi          





        print_log ""
        print_log ""
        print_log "结束查询数据库:$i"
        print_log ""
        print_log ""
    done

    rm -f  /tmp/$random
}


#备份数据
dumpData(){

    #随机数
    random=`date +%s`

    #查询数据库
    runCmd "show dbs" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port admin $random
    if [[ $? -ne 0  ]];then
        print_log "查询db执行失败,退出"
        exit
    fi

    #获取数据库名
    dbList=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  |awk '{print $1}' |grep -v "legacy" |grep -v "mode"`
    print_log "获取数据库名: `echo "$dbList" |xargs`"
    for i in $dbList
    do
        print_log "开始备份数据库:$i"

            outpath=$backDir/$now/$i
            if [[ ! -d $outpath ]];then
            	mkdir -p $outpath
            fi

            #如果存在自定义查询备份,则执行
            if [[  -f $dumpDir/$i.sh ]];then
                print_log "$i 存在自定义备份:$dumpDir/$i.sh,加载自定义数据."
                source $dumpDir/$i.sh
                print_log "$i 总共执行备份条数: $length"
                max=`expr $length - 1 `
                for num in `seq 0 $max`
                do
		    print_log "${name[$num]}"	
                    print_log "执行备份描述: ${name[$num]}  执行语句: ${execSQL[$num]} 执行表: ${collection[$num]} "
                    if [[ ${execSQL[$num]} == ""  ]];then
                        print_log "执行备份描述: ${name[$num]}  执行语句:${execSQL[$num]} 该执行语句为空,跳过该步骤."
                        continue
                    fi

                    #执行自定义语句
                    dump "${execSQL[$num]}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random ${collection[$num]} $outpath 'admin' 0
                    if [[ $? -ne 0  ]];then
                        print_log "执行自定义备份失败,退出"
                        exit
                    fi
                    result=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING  `
                    print_log "返回数据 执行描述: ${name[$num]}  执行结果:$result"
                    print_log ""

                done
	    else	

	   	dump "dump" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random "zhanPlace" $outpath 'admin' 1 
		print_log ""
		
            fi


        print_log ""
        print_log ""
        print_log "结束备份数据库:$i"
        print_log ""
        print_log ""
    done

    rm -f  /tmp/$random
}


#日期校验
dateCheck(){

if [[ $1 != ""  ]];then
  date -d "$1" +%s > /dev/null  2>&1
  if [[  $?  -ne 0  ]];then
  	print_log "第二个日期参数,日期格式不正确"
	exit
  fi
  year=`echo "$1" |awk -F'-' '{print $1}'`
  month=`echo "$1" |awk -F'-' '{print $2}'`
  day=`echo "$1" |awk -F'-' '{print $3}'`
  delete_date=$1
fi

}


case $1  in 

 query)
  dateCheck $2	
  queryData ;;	
 dump)
  if [[ -f ${lockPidFile} ]]; then
        pid=`cat ${lockPidFile}` 
        pidNumber=`ps aux |grep -v grep |grep ${pid} |wc -l`
        if [[ $pidNumber -ne 0 ]]; then
            print_log "备份数据${pid}进程正在进行,退出"
            exit
        fi
  fi  
  echo "$$" > ${lockPidFile} 
  dateCheck $2  
  dumpData
  rm -f ${lockPidFile} 
  ;;
  
 delete)
  if [[ -f ${lockPidFile} ]]; then
        pid=`cat ${lockPidFile}` 
        pidNumber=`ps aux |grep -v grep |grep ${pid} |wc -l`
        if [[ $pidNumber -ne 0 ]]; then
            print_log "删除数据${pid}进程正在进行,退出"
            exit
        fi
  fi  
  echo "$$" > ${lockPidFile} 
  dateCheck $2 
  isdelete=1	
  queryData
  rm -f ${lockPidFile}
  ;; 
   *)
  echo -e "
mongodb数据统计以及自定义备份\n用法示例: \n1.数据统计:./$0 query \n2.备份数据:./$0 dump\n3.删除数据:./$0 delete\n";;	
    
esac

