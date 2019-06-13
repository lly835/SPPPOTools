#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
#不使用全局变量delete_date时,可以在这定义defined_delete_date.若使用delete_date时，请defined_delete_date赋值为空
defined_delete_date="2017-06-14"
redefined_delete_date=$delete_date
if [[ ${defined_delete_date} != "" ]]; then
    delete_date=$defined_delete_date       
fi

name[0]="删除临时表rulemessage_temp"
execSQL[0]='db.getCollection("rulemessage_temp").drop()'
name[1]="复制rulemessage lastUpdated大于${delete_date}的数据到rulemessage_temp"
execSQL[1]='db.rulemessage.find( {"lastUpdated":{$gt:new Date("'$delete_date'").getTime()}} ).forEach( function( x ) {db.rulemessage_temp.insert( x );} )'
name[2]="复制rulemessage的索引到rulemessage_temp"
execSQL[2]='db.rulemessage.getIndexes().forEach( function( i ) {db.rulemessage_temp.ensureIndex( i.key );} )'
name[3]="重命名rulemessage_temp为rulemessage"
execSQL[3]='db.rulemessage_temp.renameCollection( 'rulemessage',true )'

length=${#name[@]}
delete_date=$redefined_delete_dat