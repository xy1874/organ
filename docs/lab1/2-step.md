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




## 1. C语言到汇编

&emsp;&emsp;下面用一个简单的C程序为例，简单说明C程序从编译到执行的过程。

### 1.1 编写样例程序

&emsp;&emsp;打开`lab1`文件夹，新建两个文本文件，将其分别重命名为`main.c`和`func.h`。

!!! warning "小提醒 :loudspeaker:"
    &emsp;&emsp;在Windows下重命名文件时，首先在文件资源管理器中，打开 “查看” -> “文件扩展名” 选项，如下图所示。

    <center><img src="../assets/3-x1.png" width = 100%></center>

&emsp;&emsp;点击下列代码右上角的复制按钮，将示例程序分别粘贴到`main.c`和`func.h`。该程序的功能是字符串匹配。

=== "main.c"

    ``` c linenums="1"
    // #include <stdio.h>
    #include "func.h"   // (1)!

    #define STR_A   "1qab9a0bcabcds13"  // (2)!
    #define STR_B   "bcds"  // (3)!

    int main()
    {
        int pos = find_substr(STR_A, STR_B, 16, 4);     // (4)!
        /* printf("%d\n", pos); */

        return pos;     // (5)!
    }
    ```

    1.  包含头文件
    2.  宏定义
    3.  宏定义
    4.  使用宏定义；调用头文件中的函数
    5.  将找到的子串位置返回
=== "func.h"

    ``` c linenums="1"
    int find_substr(char* str, char* pattern, int len1, int len2)
    {
        int pos = -1;
        for (int i = 0; i < len1; i++)
        {
            for (int j = 0; j < len2; j++)
                if (str[i + j] != pattern[j])
                    break;
                else if (j == len2 - 1)
                {
                    pos = i;
                    break;
                }
            if (pos != -1) break;
        }

        return pos;
    }
    ```

&emsp;&emsp;在`main.c`中，

- 第1、10行含有注释；  
- 第2行包含了头文件；  
- 第4、5行定义了宏定义；  
- 第9行使用了宏定义，并调用了头文件内的函数。

&emsp;&emsp;请关注下一步预编译后，这些地方都发生了什么变化。

### 1.2 预编译

&emsp;&emsp;执行`cd lab1`命令以进入`lab1`文件夹，然后执行预编译命令`riscv32-unknown-elf-gcc -E main.c -o main.i`，从而生成预编译文件`main.i`，如图3-4所示。

<center><img src="../assets/3-4.png" width = 600></center>
<center>图3-4 预编译</center>

!!! warning "小提醒 :loudspeaker:"
    &emsp;&emsp;在612、615上课的同学，如果在Windows下给虚拟机新建了文件，但在虚拟机终端执行以上命令时，报错提示找不到文件，则 **关闭虚拟机窗口并重新打开** 后再重试。

&emsp;&emsp;在Windows下访问`lab1`文件夹，双击打开并查看预编译文件`main.i`，将其与源文件作对比，如图3-5所示。

=== "对比观察注释"
    <center><img src="../assets/3-5a.png" width = 100%></center>

=== "对比观察头文件"
    <center><img src="../assets/3-5b.png" width = 100%></center>

=== "对比观察宏定义"    
    <center><img src="../assets/3-5c.png" width = 100%></center>

<center>图3-5 对比预编译文件与源文件</center>

### 1.3 编译

&emsp;&emsp;在终端内执行命令`riscv32-unknown-elf-gcc -S main.i -o main.s`，从而编译预编译文件`main.i`，生成汇编文件`main.s`。

&emsp;&emsp;在Windows下双击打开并查看汇编文件`main.s`，将其与预编译文件`main.i`作对比，如图3-6所示。**注意观察汇编程序中，函数（子程序）内部的执行流程**。

<center><img src="../assets/3-6.png" width = 100%></center>
<center>图3-6 对比汇编文件和预编译文件</center>

!!! tip "注解1：子程序流程 :pencil:"
    &emsp;&emsp;图3-6是一个典型的使用函数（子程序）的汇编程序例子，可知子程序的流程为：  
    ``` mermaid
    graph LR
    A[开始] --> B[<font color=#FF00FF><b><u>保护现场</u></b></font>];
    B --> C[取出参数];
    C --> D[处理参数];
    D --> E[保存返回值];
    E --> F[<font color=#FF00FF><b><u>恢复现场</u></b></font>];
    F --> G[函数返回];
    G --> H[结束];
    ```

!!! tip "注解2：子程序传参 :pencil:"
    &emsp;&emsp;在RISC-V汇编语言编程规范中，`a0`-`a7`寄存器通常在函数（子程序）调用时用于存放和传递整型参数。其中，`a0`、`a1`还可用于传递函数（子程序）的返回值。因此，观察图3-6右侧`main.s`第43-48行可以发现，`main()`在调用`find_substr()`前，将4个参数分别保存到了`a0`-`a3`寄存器当中；而`main()`和`find_substr()`在返回前，都将返回值保存到了`a0`寄存器。

    &emsp;&emsp;需要注意的是，图3-6右侧的汇编程序是由编译器生成的。编译器需要考虑函数调用规范、指令集规范等多方面因素，因此生成的汇编代码看起来可能存在一些“多余”的操作。比如在`find_substr()`中，明明参数已经存放在`a0`-`a3`寄存器，可以直接使用了，但偏偏要先把它们压栈，然后使用时再从栈里取出。实际上，我们在自己编写子程序时，可以直接使用`a0`-`a3`寄存器，不需像编译器这般加入额外的压栈和弹栈操作。

### 1.4 汇编

&emsp;&emsp;在终端内执行命令`riscv32-unknown-elf-gcc -c main.s -o main.o`，从而对汇编文件`main.s`进行汇编，得到ELF格式的目标文件`main.o`。

&emsp;&emsp;在终端内执行命令`riscv32-unknown-elf-objdump -d main.o > main.o.txt`可将目标文件的机器码保存到`main.o.txt`文件中。

!!! info "关于重定向符 `>` :books:"
    &emsp;&emsp;`>`是重定向符号，其作用是将符号左侧命令的输出内容重定向到符号右侧的文件并保存下来。

&emsp;&emsp;打开`main.o.txt`，查看目标程序机器码，将其与汇编文件`main.s`作对比，如图3-7所示。

<center><img src="../assets/3-7.png" width = 750></center>
<center>图3-7 查看目标程序的机器码</center>

### 1.5 生成可执行文件

&emsp;&emsp;在终端内执行命令`riscv32-unknown-elf-gcc main.c -o main`，从而将目标文件`main.o`和库文件进行链接，得到ELF格式的可执行文件`main`。

&emsp;&emsp;在终端内执行命令`spike --isa=rv32g pk main`，即可执行`main`程序。由于该程序没有`printf`语句，因此将看不到输出信息。观察`main.c`的代码，可以发现计算结果`c`是`main`函数的返回值。因此，可在终端内执行`echo $?`查看程序的返回值，如图3-8所示。

<center><img src="../assets/3-8.png" width = 500></center>
<center>图3-8 执行`main`程序并查看其返回值</center>

### 1.6 反汇编

&emsp;&emsp;汇编是指将汇编程序翻译成机器码的过程，反汇编则是其反过程。

&emsp;&emsp;在终端内执行命令`riscv32-unknown-elf-objdump -d main > main.txt`，即可将可执行文件`main`的反汇编结果保存到`main.txt`文件。

&emsp;&emsp;打开`main.txt`，查看可执行程序的机器码，将其与链接前的目标程序机器码`main.o.txt`作对比，如图3-9所示。

<center><img src="../assets/3-9.png" width = 100%></center>
<center>图3-9 查看反汇编文件</center>



## 2. 编写汇编程序

### 2.1 RARS操作流程

&emsp;&emsp;（1）**编写程序**：在RARS中，新建`.asm`文件，并编写汇编程序；也可使用代码编辑器编写汇编程序，保存后再用RARS调试和运行程序；

&emsp;&emsp;（2）**对程序汇编**：点击菜单栏按钮，进行汇编，如图3-10所示；

<center><img src="../assets/3-10.png" width = 450></center>
<center>图3-10 点击按钮进行汇编</center>

&emsp;&emsp;（3）**运行和调试程序**：点击运行按钮直接运行程序；点击调试按钮可每次执行一条指令，如图3-11所示；

<center><img src="../assets/3-11.png" width = 500></center>
<center>图3-11 运行或调试程序</center>

!!! tip "调试技巧 :bulb:"
    &emsp;&emsp;为了提高调试效率，可在RARS中设置断点。具体方法是，在`Text Segment`窗口的`Bkpt`列下面，给相应的指令打断点；然后点击运行按钮，即可直接执行到断点处的指令，如图3-12所示。

    <center><img src="../assets/3-12.png" width = 460></center>
    <center>图3-12 设置断点</center>

&emsp;&emsp;（4）**查看运行结果**：在 <u>运行结果区</u>、<u>数据区</u> 和 <u>寄存器区</u> 观察结果，如图3-13所示。

<center><img src="../assets/3-13.png" width = 100%></center>
<center>图3-13 查看汇编程序的运行结果</center>

### 2.2 数据段访问方法

&emsp;&emsp;打开RARS的存储配置，如图3-14所示。

<center><img src="../assets/3-14.png" width = 100%></center>
<center>图3-14 从RARS菜单打开存储配置</center>

&emsp;&emsp;由图3-14右侧的存储配置窗口可知，在RARS的默认配置下，数据段基地址为`0x10010000`。

&emsp;&emsp;以下给出访问数据段的参考代码：

``` asm linenums="1"
.data
    array: .word   0xA, 0x123, 0xFF
    str:   .string "Hello World!\n"

.text
MAIN:
    lui  s0, 0x10010     # 将数据段基地址赋值给s0寄存器
    lw   t0, 0x0(s0)     # 读取array[0]到t0寄存器
    lw   t1, 0x4(s0)     # 读取array[1]到t1寄存器
    lw   t2, 0x8(s0)     # 读取array[2]到t2寄存器
    addi a0, s0, 12      # 将字符串str的基地址赋值给a0寄存器  
```

&emsp;&emsp;在RARS中运行上述程序，可在数据区查看数据段中的变量的值，如图3-15所示。

<center><img src="../assets/3-15.png" width = 700></center>
<center>图3-15 在RARS中查看数据段中的变量的值</center>

!!! note "关于数据段中的字符串 :microscope:"
    &emsp;&emsp;（1）字符串中的每个字符均以ASCII码的形式存储在数据段中；  
    &emsp;&emsp;（2）数据段中的数据均以小端方式存储。

&emsp;&emsp;执行程序后，可在RARS右侧查看`s0`、`t0`、`t1`、`t2`和`a0`寄存器的值，如图3-16所示。

<center><img src="../assets/3-16.png" width = 200></center>
<center>图3-16 查看程序执行结果</center>