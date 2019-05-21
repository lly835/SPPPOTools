# svn简易安装脚本

>通过脚本一键安装svn

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |   centos6.2、centos7.3 `OK` |    |
| 脚本名称    |   svnInstall.sh  |    |
| 执行方式    |   /bin/bash svnInstall.sh  |    |
| 是否需要传参数    |   否  |    |
| 是否有配置参数    |   有,见下  |    |

配置参数`svnInstall.sh`      
```
logdir=/data/log/shell          #日志路径
log=$logdir/log.log            #日志文件
is_font=1              #终端是否打印日志: 1打印 0不打印
is_log=1               #是否记录日志: 1记录 0不记录
svnDir=/data/svn                #svn数据路径
svnPasswd=/data/svn/passwd      #svn用户认证文件
svnPolicy=/data/svn/policy      #svn用户权限控制文件
DefaultUserPasswd=admin  admin  #svn缺省管理账号
DefaultProjectName=project      #svn缺省项目
```




