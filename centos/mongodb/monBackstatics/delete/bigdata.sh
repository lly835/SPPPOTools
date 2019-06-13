#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="删除action_log_new 小于${delete_date}的数量"
execSQL[0]='db.action_log_new.remove({"sendTime":{$lt:ISODate("'$delete_date'")}})'
length=${#name[@]}

