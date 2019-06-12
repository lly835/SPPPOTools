#!/bin/bash
#author: 黄高明
#date: 2019-05-22
#qq: 530035210
#blog: https://www.pvcreate.com/
#svn全量备份

logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=1               #是否记录日志: 1记录 0不记录
now=`date +%Y%m%d_%H%M%S`
hostip=`/sbin/ifconfig eth0|grep "inet addr"|awk '{print $2}'|awk -F: '{print $2}'`
svndir=/data/svn
basedir=/data/backup/svn
backupdir=$basedir/$now
maxBackupTimes=15	#最大备份保留天数
svnVersionFile=$basedir/svnVersionFile.txt	#svn版本记录
backWays=0 			#0全量备份 1增量备份				
fullBack="hotcopy"  #hotcopy:hotcopy全备方式 dump:dump备份方式
tarFile=1			#0不压缩,1压缩

datef(){
    date "+%Y-%m-%d %H:%M:%S"
}

print_log(){
    if [[ $is_log -eq 1  ]];then
        [[ -d $logdir ]] || mkdir -p $logdir
        echo -e "[ $(datef) ] $1" >> $log
    fi
    if [[ $is_font -eq 1  ]];then
    	if [[ $2 -eq 1 ]]; then
    		echo -e "[ $(datef) ] \033[31m$1\033[0m"
    	elif [[ $2 -eq 2 ]]; then
    		echo -e "[ $(datef) ] \033[34m$1\033[0m"
    	else
    		echo -e "[ $(datef) ] $1"
    	fi      
    fi
}

source /etc/profile

svnbackup(){

	[[  -f /tmp/svnbackup.faild ]] && print_log "上次svn备份失败,此次备份终止,请检查备份是否正常,如正常请删除/tmp/svnbackup.faild" 1 && exit
	mkdir -p $backupdir
	print_log "$hostip 开始备份svn."

	cd $svndir
	ls -l  $svndir | grep ^d | awk '{print $9}'| sort |while read i
	do
		if [[ ! -f ${i}/format ]];then
			continue
		fi
		version=$(svnlook youngest ${svndir}/${i})
		print_log "${hostip} $i:$version"
		if [[ $backWays -eq 0 ]]; then
			if [[ ${fullBack} == "hotcopy" ]]; then
				print_log "${hostip} cmd: svnadmin hotcopy $svndir/$i $backupdir/$i --clean-logs"
				svnadmin hotcopy $svndir/$i $backupdir/$i --clean-logs
			elif [[ ${fullBack} == "dump"  ]]; then
				print_log "${hostip} cmd: svnadmin dump $svndir/$i > $backupdir/${i}.dump"
				svnadmin dump $svndir/$i > $backupdir/${i}.dump
			else
				print_log "${hostip} fullBack参数获取失败!!!" 1
				exit 2
			fi
		else
			lastVer=$(cat ${svnVersionFile} |grep "^$i:" | tail -n 1 |awk -F':' '{print $2}'|xargs |sed "s/ //" )
			if [[ $lastVer == "" ]]; then
				print_log "${hostip} 增量备份时，获取上个版本为空!!!" 1
				exit 3 
			fi
			if [[ $lastVer == $version ]]; then
				print_log "${hostip} 增量备份时，获取上个版本和当前版本相等($i:	$lastVer == $version)，退出当前项目的备份!!!"
				continue
			fi
			print_log "cmd:svnadmin dump $svndir/$i --revision ${lastVer}:${version} --incremental > $backupdir/${i}.dump"
			svnadmin dump $svndir/$i --revision ${lastVer}:${version} --incremental > $backupdir/${i}.dump
		fi
		
		if [[ $? != 0 ]]
		then
			echo "$now" >/tmp/svnbackup.faild 
			print_log "${hostip} svn备份失败!!!" 1
			exit 1
		else
			print_log "${hostip} $svndir/$i ->$backupdir/$i  svn备份成功"
			echo "$i:$version" >> ${svnVersionFile}
		fi
	done
	count=`ls $backupdir/$*|wc -w`
	if [[ $count -eq 0  ]]; then
		print_log "${hostip} $backupdir:备份目录为空" 2
		exit 4
	fi
	if [[ $tarFile -eq 1 ]]; then
		cd $basedir
		tar -zcf ${now}.tar.gz $backupdir
		rm -rf $backupdir
		print_log "${hostip} 压缩成功: $basedir/${now}.tar.gz"
	fi
	find $basedir -type d -mtime ${maxBackupTimes} | xargs rm -rf  >/dev/null 2>&1
	find $basedir -type f -mtime ${maxBackupTimes} | xargs rm -f  >/dev/null 2>&1
	print_log "${hostip} svn全部备份成功"
}

svnbackup
