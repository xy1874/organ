# 附录A 实验环境安装

!!! abstract "写在前面 :tea:"
    &emsp;&emsp;实验室的电脑均已提前安装好实验环境。本附录仅供自行安装环境使用。
    
    &emsp;&emsp;本附录仅以WSL2为例介绍实验环境的安装方法，但实际也可参考本附录将RV32 GNU安装在现成的Linux环境中。

## 1. 安装WSL2

&emsp;&emsp;首先，确保已在BIOS中开启了CPU虚拟化功能。开启后，可在任务管理器中看到如图A-1所示的信息。

<center><img src="../assets/a-1.png" width = 550></center>
<center>图A-1 在任务管理器查看是否已开启CPU虚拟化功能</center>

!!! info "关于开启CPU虚拟化 :books:"
    &emsp;&emsp;不同型号电脑的BIOS可能不同，开启虚拟化的具体操作可能也不相同，请自行<a href="https://cn.bing.com/search?pglt=643&q=BIOS+%E5%BC%80%E5%90%AF%E8%99%9A%E6%8B%9F%E5%8C%96&cvid=0e45517f8984469ab6604af9656b1879&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCjEwOTA3MGowajGoAgCwAgA&FORM=BESBTB&PC=U531" target="_blank">使用搜索引擎搜索</a>或自行探索具体的开启方法。

&emsp;&emsp;在任务栏搜索框搜索“PowerShell”，或在开始菜单找到PowerShell，右键选择 **以管理员权限** 打开，并在其中执行以下命令：

- 命令1：  
``` powershell
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```  
- 命令2：  
``` powershell
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

&emsp;&emsp;命令较长，容易输入错误。建议点击代码块右侧的复制按钮以复制命令，并在PowerShell中单击鼠标右键粘贴后再执行。

!!! info "命令说明 :pencil:"
    &emsp;&emsp;命令1用于开启Windows系统的Linux子系统功能（<a href="https://docs.microsoft.com/windows/wsl" target="_blank">Windows Subsystem for Linux</a>，WSL）。
    
    &emsp;&emsp;命令2用于开启Windows系统的虚拟机功能。若命令2执行出错，则可以尝试执行命令3：  
    ```
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    ```

&emsp;&emsp;上述2条命令执行成功后，**重启** 系统。

&emsp;&emsp;再次 **以管理员权限** 打开PowerShell，执行命令`wsl --set-default-version 2`，从而将WSL的默认版本设置成WSL2。

&emsp;&emsp;上述命令均执行成功后，下载并安装WSL2的Linux内核更新包 <a href="https://aka.ms/wsl2kernel" target="_blank">wsl_update_x64.msi</a> 。

## 2. 安装Linux发行版

&emsp;&emsp;在任务栏搜索框搜索“Store”，或在开始菜单找到Microsoft Store。在Microsoft Store中搜索关键词“Linux”，选择你喜好的Linux发行版进行安装。

&emsp;&emsp;若使用最新版本的Windows（内部版本号 $\geq$ 20262），则也可在PowerShell中执行 `wsl --install` 命令。该命令将下载安装最新的Linux内核及Ubuntu发行版。


## 3. 安装RV32 GNU

&emsp;&emsp;本课程实验提供已经编译好的RV32 GNU工具包 <a href="https://pan.baidu.com/s/1abDx6yOLrX_E2fJhai-IDQ?pwd=fnhs" target="_blank">rv32_gnu.tar.gz</a> ，内含RV32编译器、<a href="https://github.com/riscv-software-src/riscv-isa-sim" target="_blank">Spike</a>仿真器和<a href="https://github.com/riscv-software-src/riscv-pk" target="_blank">riscv-pk</a>代理内核。该工具包可以直接安装在Linux环境中使用。感兴趣的同学们也可以访问GitHub上的官方仓库<a href="https://github.com/riscv-collab/riscv-gnu-toolchain" target="_blank">riscv-collab/riscv-gnu-toolchain</a>，并按照README文档自行编译安装。

&emsp;&emsp;首先，需要将`rv32_gnu.tar.gz`文件拷贝到虚拟机中。

&emsp;&emsp;通过快捷键 ++win+e++ 打开文件资源管理器，然后在地址栏输入 `\\wsl$` 并回车，或点击左下方的Linux，即可访问虚拟机文件系统，如图A-2所示。

<center><img src="../assets/a-2.png" width = 600></center>
<center>图A-2 访问虚拟机文件系统</center>

&emsp;&emsp;在图A-2中，每个文件夹均代表一个Linux发行版的文件系统，且文件夹与发行版同名。
    
&emsp;&emsp;双击进入相应文件夹，然后再依次双击进入`/home/XXX/`的用户目录。将`rv32_gnu.tar.gz`拷贝到其中，如图A-3所示。

<center><img src="../assets/a-3.png" width = 400></center>
<center>图A-3 拷贝`rv32_gnu.tar.gz`至用户目录</center>

&emsp;&emsp;在开始菜单找到安装好的Linux发行版，单击启动之。
    
!!! tip "如果已安装了其他发行版"
    &emsp;&emsp;推荐使用WSL2发行版管理器 <a href="https://github.com/bostrot/wsl2-distro-manager" target="_blank">wsl2-distro-manager</a> 对已安装的多个发行版进行管理。该工具具有可视化界面，不仅操作方便，而且体积小、解压即用。

    &emsp;&emsp;也可在PowerShell中执行`wsl -l -v`查看所有已安装的发行版，然后执行`wsl -d <发行版名称>`命令以启动相应的发行版，如图A-4所示。

    <center><img src="../assets/a-4.png" width = 700></center>
    <center>图A-4 查看并启动WSL中已安装的Linux发行版</center>

&emsp;&emsp;启动发行版后，在其终端执行解压命令：
    
``` bash
sudo tar -zxvf rv32_gnu.tar.gz -C /opt
```
    
&emsp;&emsp;接着，需要添加环境变量。

&emsp;&emsp;在Windows文件资源管理器中，进入发行版的用户目录，找到`.bashrc`文件，如图A-5所示。
    
<center><img src="../assets/a-5.png"></center>
<center>图A-5 找到`.bashrc`文件以添加环境变量</center>
    
&emsp;&emsp;双击打开`.bashrc`文件，在最后增加两行代码：

``` bash linenums="1"
export PATH=$PATH:/opt/riscv_gnu/riscv32-unknown-elf/bin/
export PATH=$PATH:/opt/riscv_gnu/riscv64-unknown-elf/bin/
```

&emsp;&emsp;保存文件后，回到Linux发行版的终端，执行`source .bashrc`命令，从而使环境变量生效。

&emsp;&emsp;在终端中输入`ris`并按下 ++tab++ 键，观察命令是否被自动补全。若自动补全，说明RV32的GNU环境已安装成功。

&emsp;&emsp;为运行编译后的RV32程序，还需输入命令`sudo apt install device-tree-compiler`以安装设备树编译器。

&emsp;&emsp;最后，对所安装的RV32交叉编译环境进行测试。

&emsp;&emsp;编写HelloWorld程序，执行命令`riscv32-unknown-elf-gcc helloworld.c`对其进行编译，然后执行命令`spike --isa=rv32g pk a.out`对其进行仿真运行，如图A-6所示。

<center><img src="../assets/a-6.png" width = 600></center>
<center>图A-6 测试RV32交叉编译环境</center>
