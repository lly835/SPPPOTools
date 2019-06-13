#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="获取rulemessage 小于${delete_date}的数量"
execSQL[0]='db.getCollection("rulemessage").find({"lastUpdated":{$lt:new Date("'$delete_date'").getTime()}}).count()'
name[1]="获取rulemessage 大于或等于${delete_date}的数量"
execSQL[1]='db.getCollection("rulemessage").find({"lastUpdated":{$gte:new Date("'$delete_date'").getTime()}}).count()'
length=${#name[@]}

