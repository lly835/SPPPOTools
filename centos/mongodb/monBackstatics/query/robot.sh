#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="获取robotTask 小于${delete_date}的数量"
execSQL[0]='db.robotTask.find({"startTime":{$lt:ISODate("'$delete_date'")}}).count()'
name[1]="获取robotTask 大于或等于${delete_date}的数量"
execSQL[1]='db.robotTask.find({"startTime":{$gte:ISODate("'$delete_date'")}}).count()'
length=${#name[@]}

