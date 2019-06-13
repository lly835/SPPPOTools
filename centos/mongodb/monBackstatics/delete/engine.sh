#!/bin/bash
#delete_date=`date -d "30 days ago" +"%Y-%m-%d"`
name[0]="删除rulemessage 小于${delete_date}的数量"
execSQL[0]='db.getCollection("rulemessage").remove({"lastUpdated":{$lt:new Date("'$delete_date'").getTime()}})'
length=${#name[@]