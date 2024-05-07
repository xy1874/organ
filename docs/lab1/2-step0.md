# 实验步骤

## 0. 开始之前

&emsp;&emsp;首先，简要介绍基于WSL（<a href="https://docs.microsoft.com/windows/wsl" target="_blank">Windows Subsystem for Linux</a>）的虚拟机使用方法。

### 0.1 如何使用虚拟机？

=== "612、615实验室"
    &emsp;&emsp;在 **612、615实验室** 上课的同学，在桌面上找到Debian虚拟机的快捷方式，双击启动Debian虚拟机，如图3-1所示。

    <center><img src="../assets/3-1-1.png" width = 400></center>
    <center>图3-1 启动虚拟机</center>

=== "506实验室"
    &emsp;&emsp;在 **506实验室** 上课的同学，在桌面、开始屏幕或任务栏搜索框找到并打开wsl2distromanager，点击按钮启动comp2008虚拟机，如图3-1所示。

    <center><img src="../assets/3-1.png" width = 650></center>
    <center>图3-1 启动虚拟机</center>

&emsp;&emsp;启动虚拟机后，可在终端窗口中输入并执行命令。虚拟机的 <span style="background-color: #00FFFF;">**用户密码、root密码均为123**</span>。

### 0.2 如何访问虚拟机文件？

=== "612、615实验室"
    &emsp;&emsp;在 **612、615实验室** 上课的同学，在桌面上找到`rootfs`文件夹的快捷方式，双击打开，即可访问虚拟机的文件系统，如图3-2所示。

    <center><img src="../assets/3-2.png" width = 700></center>
    <center>图3-2 访问虚拟机文件系统</center>

    &emsp;&emsp;我们可以在图3-2所示的资源管理器窗口中直接访问虚拟机的文件夹及文件。双击进入相应目录，即可直接对虚拟机的文件进行访问、创建、编辑、复制等操作。

=== "506实验室"
    &emsp;&emsp;在 **506实验室** 上课的同学，通过快捷键 ++win+e++ 打开文件资源管理器，然后在地址栏输入 `\\wsl$` 并回车，或点击左下方的Linux，即可访问虚拟机文件系统，如图3-2所示。

    <center><img src="../assets/a-2.png" width = 600></center>
    <center>图3-2 访问虚拟机文件系统</center>

    &emsp;&emsp;在图3-2中，每个文件夹均代表一个虚拟机的文件系统，且文件夹与虚拟机同名。双击进入相应的虚拟机文件系统后，即可直接对虚拟机的文件进行访问、创建、编辑、复制等操作。

!!! example "重要说明 :pencil:"
    &emsp;&emsp;要想虚拟机正常使用Windows下创建的文件夹，需在虚拟机中执行`sudo chmod -R 777 <文件夹路径+文件夹名称>`将其访问权限修改为`777`，详见<a href="../B-lnxcmd" target="_blank">附录B第11点</a>。
    
    &emsp;&emsp;类似地，要想虚拟机正常使用Windows下创建的文件，需在虚拟机中执行`sudo chmod 777 <文件路径+文件名称>`。

### 0.3 创建实验目录

=== "612、615实验室"
    &emsp;&emsp;在 **612、615实验室** 上课的同学，双击进入图3-2所示的`home/`目录，然后继续双击进入其中的`usr/`目录，如图3-3所示。

    <center><img src="../assets/3-3-1.png"></center>
    <center>图3-3 双击进入用户目录</center>
    
    &emsp;&emsp;在图3-3所示的用户目录中，右键新建文件夹，命名为`lab1`。随后 **关闭虚拟机窗口并重新打开**，然后在虚拟机终端内输入`sudo chmod -R 777 lab1`命令，回车并输入root密码。注意 **不要改动或删除已有文件**。

=== "506实验室"
    &emsp;&emsp;在 **506实验室** 上课的同学，双击进入图3-2所示的`comp2008`文件夹，然后再依次双击进入`/home/usr/`的用户目录，或在地址栏直接访问`\\wsl$\comp2008\home\usr`，如图3-3所示。

    <center><img src="../assets/3-3.png"></center>
    <center>图3-3 双击进入用户目录</center>

    &emsp;&emsp;在图3-3所示的用户目录中，右键新建文件夹，命名为`lab1`。随后在虚拟机终端内输入`sudo chmod -R 777 lab1`命令，回车并输入root密码。注意 **不要改动或删除已有文件**。

&emsp;&emsp;创建目录时，也可在虚拟机终端内直接执行`mkdir lab1`命令。

&emsp;&emsp;
