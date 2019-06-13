#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
#不使用全局变量delete_date时,可以在这定义defined_delete_date.若使用delete_date时，请defined_delete_date赋值为空
defined_delete_date="2017-09-24"
redefined_delete_date=$delete_date
if [[ ${defined_delete_date} != "" ]]; then
    delete_date=$defined_delete_date       
fi

name[0]="删除临时表robotTask_temp"
execSQL[0]='db.getCollection("robotTask_temp").drop()'
name[1]="复制robotTask startTime大于${delete_date}的数据到robotTask_temp"
execSQL[1]='db.robotTask.find( {"startTime":{$gte:ISODate("'${delete_date}T16:00:00Z'")}} ).forEach( function( x ) {db.robotTask_temp.insert( x );} )'
name[2]="复制robotTask的索引到robotTask_temp"
execSQL[2]='db.robotTask.getIndexes().forEach( function( i ) {db.robotTask_temp.ensureIndex( i.key );} )'
name[3]="重命名robotTask_temp为robotTask"
execSQL[3]='db.robotTask_temp.renameCollection( 'robotTask',true )'

length=${#name[@]}
delete_date=$redefined_delete_dat