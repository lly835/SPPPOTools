#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="获取action_log_new 小于${delete_date}的数量"
execSQL[0]='db.action_log_new.find({"sendTime":{$lt:ISODate("'$delete_date'")}}).count()'
name[1]="获取action_log_new 大于或等于${delete_date}的数量"
execSQL[1]='db.action_log_new.find({"sendTime":{$gte:ISODate("'$delete_date'")}}).count()'
length=${#name[@]}

