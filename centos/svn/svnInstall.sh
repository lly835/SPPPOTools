#!/bin/bash
#author: 黄高明
#date: 2019-05-22
#qq: 530035210
#blog: https://www.pvcreate.com/
#svn简易安装脚本(centos 6 7 测试通过)

logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=1               #是否记录日志: 1记录 0不记录
svnDir=/data/svn 				 #svn数据路径
svnPasswd=/data/svn/passwd       #svn用户认证文件
svnPolicy=/data/svn/policy       #svn用户权限控制文件
DefaultUserPasswd="admin  admin" #svn缺省管理账号
DefaultProjectName=project       #svn缺省项目


datef(){
    date "+%Y-%m-%d %H:%M:%S"
}

print_log(){
    if [[ $is_log -eq 1  ]];then
        [[ -d $logdir ]] || mkdir -p $logdir
        echo -e "[ $(datef) ] $1" >> $log
    fi
    if [[ $is_font -eq 1  ]];then
        echo -e "[ $(datef) ] $1"
    fi
}

install(){
	print_log "开始安装httpd svn mod_dav_svn"
	yum install svn mod_dav_svn httpd  -y
	if [[ $? -ne 0 ]]; then
		print_log "安装httpd svn mod_dav_svn失败,请检查yum仓库是否正确"
		exit
	fi
	print_log "安装httpd svn mod_dav_svn完成"
	print_log "开始svn初始化配置"
	source /etc/profile 
	mkdir ${svnDir} -p
	cd ${svnDir}
	svnadmin create ${DefaultProjectName}
	echo "<Location /svn/>
       SVNListParentPath ON
       DAV svn
       Options Indexes FollowSymLinks
       SVNParentPath ${svnDir}
       AuthzSVNAccessFile ${svnPolicy}
       AuthType Basic
       AuthName \"Subversion repository\"
       AuthUserFile ${svnPasswd}
      Require valid-user
</Location>" >> /etc/httpd/conf.d/subversion.conf
	htpasswd -b -c ${svnPasswd} ${DefaultUserPasswd}
	echo "[groups]
root=admin
[/]
@root=rw
[project:/]
@root=rw"> ${svnPolicy}
	chown apache ${svnDir} -R
	service httpd start
	if [[ $? -eq 0 ]]; then
		print_log "svn初始化配置完成,并启动成功"
		print_log "数据目录:${svnDir} 用户数据文件:${svnPasswd} 用户权限文件:${svnPolicy}"
	fi
}

install
if [[ $? -ne 0 ]]; then
	print_log "svn初始化配置失败,可以尝试手动安装"
	exit
fi











