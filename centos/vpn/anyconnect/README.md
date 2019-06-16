#### 通过脚本一键安装ocserv(anyconnect服务端)  

>  日期：2019-06-14          
>  类别：vpn系列         
>  标题：通过脚本一键安装ocserv          
>  来源：[github](https://github.com/travislee8964/ocserv-auto)

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |  centos7.3 |  实测通过  |
| 支持平台    |   CentOS/RedHat 7 |    |
| git路径    |   [ocserv-auto.sh](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/ocserv-auto.sh)  |    |
| 脚本名称    |   ocserv-auto.sh  |    |
| 执行方式    |   /bin/bash ocserv-auto.sh  |    |
| 是否需要传参数    |   否  |    |
| 是否有配置参数    |   否  |    |


##### 操作说明
执行`/bin/bash ocserv-auto.sh`即可完成一键安装，安装过程会交互式提示需要输出账号密码
安装完成会自动添加到开启启动项 

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/index.jpg)

相关常用命令如下

创建用户
`ocpasswd -c  /etc/ocserv/ocpasswd user`

删除用户
`ocpasswd -c  /etc/ocserv/ocpasswd -d user`

启动服务
`service ocserv start`

关闭服务器
`service ocserv stop`

重启服务
`service ocserv restart`



##### easyconnect客户端


官方客户端地址: [https://software.cisco.com/download/home/286281283/type/282364313/release/4.7.03052](https://software.cisco.com/download/home/286281283/type/282364313/release/4.7.03052)

安卓版本下载地址: [https://play.google.com/store/apps/details?id=com.cisco.anyconnect.vpn.android.avf&hl=zh](https://play.google.com/store/apps/details?id=com.cisco.anyconnect.vpn.android.avf&hl=zh)

ios下载： 在app store中搜索anyconnect安装即可

如果以上网址打开，可以在我的git下载: [https://gitee.com/lookingdreamer/SPPPOTools/tree/master/centos/vpn/anyconnect/client](https://gitee.com/lookingdreamer/SPPPOTools/tree/master/centos/vpn/anyconnect/client)


##### ios客户端使用示例
- 1.在app store 搜索anyconnect下载安装
- 2.打开客户端在 设置处 关闭阻止不信任的服务器
   因为脚本默认采用的自签名证书,同时第一次的连接时候也会提示不信任的服务器，选择继续即可 
![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/notrust.jpg)

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/notrust1.png)

- 3.新建服务器配置，输入脚本创建用户名和密码即可

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/index.jpg)

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/connect.png)

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/user.jpeg)

![openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/anyconnect/images/pass.jpg)

#### 相关文章
| 序号 | 标题 |
| :--------: | :------ |
| 1 | [通过脚本一键安装ocserv(anyconnect服务端)](https://www.pvcreate.com/index.php/archives/193/) |
| 2 | [CentOS7使用Ocser搭建CiscoAnyconnect服务器(配置使用)](https://www.pvcreate.com/index.php/archives/195/) |
| 3 | [通过脚本一键安装openvpn](https://www.pvcreate.com/index.php/archives/194/) |
| 4 | [OpenVPN同时监听TCP和UDP端口](https://www.pvcreate.com/index.php/archives/196/) |
| 5 | [CentOS 7安装配置PPTP](https://www.pvcreate.com/index.php/archives/197/) |


