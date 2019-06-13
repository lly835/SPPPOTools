#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="删除robotTask 小于${delete_date}的数量"
execSQL[0]='db.robotTask.remove({"startTime":{$lt:ISODate("'$delete_date'")}})'
length=${#name[@]}

