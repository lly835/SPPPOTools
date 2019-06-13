#!/bin/bash
#delete_date=`date -d "5 days ago" +"%Y-%m-%d"`
#不使用全局变量delete_date时,可以在这定义defined_delete_date.若使用delete_date时，请defined_delete_date赋值为空
defined_delete_date="2017-06-14"
redefined_delete_date=$delete_date
if [[ ${defined_delete_date} != "" ]]; then
    delete_date=$defined_delete_date       
fi
#随机数
random=`date +%s`

#查询总的数据量
runCmd "db.robotTask.count()" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin

if [[ $? -ne 0  ]];then
    print_log "获取robotTask总的数据量失败,退出"
    exit
fi
totalCount=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING`
rm -f /tmp/$random

print_log "###robotTask总数据量:${totalCount}"
#查询小于${delete_date}的数量语句
runSQL='db.getCollection("robotTask").find({"startTime":{$lt:ISODate("'${delete_date}'")}}).count()'

k=0
while true
do

    k=`expr ${k} + 1`
    #查询小于${delete_date}的数量
    print_log "获取robotTask 小于${delete_date}的数量"
    print_log "执行语句:$runSQL"
    runCmd "${runSQL}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin
    if [[ $? -ne 0  ]];then
        print_log "获取robotTask 小于${delete_date}的数量失败,退出"
        exit
    fi
    maxCount=`cat /tmp/$random |grep -v bye |sed "1,3d" | grep -v help |grep -v WARNING`
    print_log "###robotTask startTime小于${delete_date}的数量:${maxCount}"
    rm -f /tmp/$random
    if [[ ${maxCount} -eq 0 ]]; then
        print_log "robotTask startTime小于${delete_date}的数据为:${maxCount},退出循环"
        break
    fi

    #执行删除
    deleteSQL='removeIdsArray=db.getCollection("robotTask").find({"startTime":{$lt:ISODate("'${delete_date}'")}}).limit('${deleteMaxCount}').toArray().map(function(doc) { return doc._id; });db.robotTask.remove({_id: {$in: removeIdsArray}})'
    print_log "执行自定义数据函数删除,执行语句:$deleteSQL"
    dstart=`date +%s`
    runCmd "${deleteSQL}" $mongodb_host $mongodb_admin_user $mongodb_admin_pass $mongodb_port $i $random  admin
    if [[ $? -ne 0  ]];then
        print_log "执行第${k}次删除失败,退出"
        exit
    fi
    dend=`date +%s`
    dtotal=`expr $dend - $dstart `
    print_log "执行第${k}次删除成功,每次删除条数:${deleteMaxCount} 消耗时间:${dtotal}秒"
    rm -f /tmp/$random

done

delete_date=$redefined_delete_date