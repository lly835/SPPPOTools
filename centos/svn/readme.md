#### svn简易安装脚本
    
>作者: 黄高明      
>日期: 2019-05-22    
>说明: 通过脚本一键安装svn    

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |   centos6.2、centos7.3 |  实测通过  |
| git路径    |   [svnInstall.sh](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/svn/svnInstall.sh)  |    |
| 脚本名称    |   svnInstall.sh  |    |
| 执行方式    |   /bin/bash svnInstall.sh  |    |
| 是否需要传参数    |   否  |    |
| 是否有配置参数    |   有,见下  |    |

**配置参数**`svnInstall.sh`      
```
logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=1               #是否记录日志: 1记录 0不记录
svnDir=/data/svn                 #svn数据路径
svnPasswd=/data/svn/passwd       #svn用户认证文件
svnPolicy=/data/svn/policy       #svn用户权限控制文件
DefaultUserPasswd="admin  admin" #svn缺省管理账号
DefaultProjectName=project       #svn缺省项目
```

**运行截图**        
![cmd](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/svn/images/cmd.png)

![cmd](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/svn/images/web.png)

#### svn全量备份和增量备份脚本
    
>作者: 黄高明      
>日期: 2019-06-13    
>说明: 通过脚本一键备份svn    

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |   centos6.2、centos7.3 |  实测通过  |
| git路径    |   [svnBackup.sh](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/svn/svnBackup.sh)  |    |
| 脚本名称    |   svnBackup.sh  |    |
| 执行方式    |   /bin/bash  svnBackup.sh |    |
| 是否需要传参数    |   是(非必须)  |    |
| 是否有配置参数    |   有,见下  |    |

**配置参数**`svnBackup.sh`      
```
logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=1               #是否记录日志: 1记录 0不记录
now=`date +%Y%m%d_%H%M%S`
svndir=/data/svn            #svn缺省目录
basedir=/data/backup/svn    #svn备份目录 
backupdir=$basedir/$now     #当前时间svn的备份目录
maxBackupTimes=15   #最大备份保留天数
svnVersionFile=$basedir/svnVersionFile.txt  #svn版本记录
backWays=0          #0全量备份 1增量备份                
fullBack="hotcopy"  #hotcopy:hotcopy全备方式 dump:dump备份方式
tarFile=1           #0不压缩,1压缩
```

**运行截图**        


