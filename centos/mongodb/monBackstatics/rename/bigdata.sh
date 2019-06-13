#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
#不使用全局变量delete_date时,可以在这定义defined_delete_date.若使用delete_date时，请defined_delete_date赋值为空
defined_delete_date="2017-09-26"
redefined_delete_date=$delete_date
if [[ ${defined_delete_date} != "" ]]; then
    delete_date=$defined_delete_date       
fi

name[0]="删除临时表action_log_new_temp"
execSQL[0]='db.getCollection("action_log_new_temp").drop()'
name[1]="复制action_log_new sendTime大于${delete_date}的数据到action_log_new_temp"
execSQL[1]='db.action_log_new.find( {"sendTime":{$gte:ISODate("'${delete_date}T16:00:00Z'")}} ).forEach( function( x ) {db.action_log_new_temp.insert( x );} )'
name[2]="复制action_log_new的索引到action_log_new_temp"
execSQL[2]='db.action_log_new.getIndexes().forEach( function( i ) {db.action_log_new_temp.ensureIndex( i.key );} )'
name[3]="重命名action_log_new_temp为action_log_new"
execSQL[3]='db.action_log_new_temp.renameCollection( 'action_log_new',true )'

length=${#name[@]}
delete_date=$redefined_delete_dat