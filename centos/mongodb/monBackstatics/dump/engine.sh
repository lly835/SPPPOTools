#!/bin/bash
#delete_date=`date -d "5 days ago" +"%Y-%m-%d"`
#随机数
random=`date +%s`

#获取NumberLong
runCmd 'new Date("'${delete_date}'").getTime()' $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port admin $random
if [[ $? -ne 0  ]];then
    print_log "获取NumberLong执行失败,退出"
    exit
fi

numberLong=`cat /tmp/$random |grep -v bye |sed "1,3d"`
rm -f /tmp/$random

name[0]="备份rulemessage大于或等于${delete_date}数据"
execSQL[0]='{"lastUpdated":"'${numberLong}'"}'
collection[0]='rulemessage'
length=${#name[@]}
