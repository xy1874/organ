# 实验步骤

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