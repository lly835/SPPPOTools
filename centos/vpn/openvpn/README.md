#### 通过脚本一键安装openvpn 

>  日期：2019-06-13    
>  类别：vpn系列     
>  标题：通过脚本一键安装openvpn       
>  来源：[github](https://github.com/angristan/openvpn-install)

| 名称      |     结果 |   备注   |
| :------: | :------:| :------: |
| 实测环境    |   centos6.2、centos7.3 |  实测通过  |
| 支持平台    |   Debian, Ubuntu, Fedora, CentOS and Arch Linux |    |
| git路径    |   [openvpn-install.sh](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/openvpn-install.sh)  |    |
| 脚本名称    |   openvpn-install.sh  |    |
| 执行方式    |   /bin/bash openvpn-install.sh  |    |
| 是否需要传参数    |   否  |    |
| 是否有配置参数    |   否  |    |


##### 操作说明
安装完成之后，再次执行`openvpn-install.sh`,可以实现对openvpn账号的管理以及卸载
该操作是交互式操作

- Add a client（添加客户端）
- Remove a client （删除客户端）
- Uninstall OpenVPN （卸载openvpn）

[openvpn](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/images/openvpn.png)

##### openvpn客户端
由于国情的原因,openvpn的官网在国内基本不可用。
通过git暂时保存以下客户端

|    平台          | 路径  | 
| ------------ | ---- | 
|  Linux  |   [openvpn-2.4.7.tar.gz](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/client/openvpn-2.4.7.tar.gz)  |  
|  Win7  |   [openvpn-install-2.4.7-I607-Win10.exe](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/client/openvpn-install-2.4.7-I607-Win10.exe)  |  
|  Win10  |   [openvpn-install-2.4.7-I607-Win7.exe](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/client/openvpn-install-2.4.7-I607-Win7.exe)  |  
|  Mac  |   [Tunnelblick_3.7.6a_build_5080.dmg.tar.gz](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/client/Tunnelblick_3.7.6a_build_5080.dmg.tar.gz)  |  
|  Android  |   [android.apk](https://gitee.com/lookingdreamer/SPPPOTools/raw/master/centos/vpn/openvpn/client/openvpn_v3.0.5_apkpure.com.apk)  |  

##### 支持平台

|              | i386 | amd64 | armhf | arm64 |
| ------------ | ---- | ----- | ----- | ----- |
|  Arch Linux  |   ❔  |  ✅  |   ❔   |   ❔  |
|   CentOS 7   |   ❔  |  ✅  |   ❌   |   ✅  |
|   Debian 8   |   ✅  |  ✅  |   ❌   |   ❌  |
|   Debian 9   |   ❌  |  ✅  |   ✅   |   ✅  |
|   Fedora 27  |   ❔  |  ✅  |   ❔   |   ❔  |
|   Fedora 28  |   ❔  |  ✅  |   ❔   |   ❔  |
| Ubuntu 16.04 |   ✅  |  ✅  |   ❌   |   ❌  |
| Ubuntu 18.04 |   ❌  |  ✅  |   ✅   |   ✅  |
| Ubuntu 19.04 |   ❌  |  ✅  |   ✅   |   ✅  |

