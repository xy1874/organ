## 实验目的

&emsp;&emsp;1. 了解C语言从编译到汇编的过程，了解C程序和汇编程序的对应关系；

&emsp;&emsp;2. 熟悉子程序工作流程，理解子程序工作原理；

&emsp;&emsp;3. 熟悉RISC-V汇编程序语法，掌握基本汇编程序的编写；

&emsp;&emsp;4. 掌握RISC-V汇编工具RARS的使用方法。


## 实验内容

&emsp;&emsp;1. 用C语言编写程序，实现字符串匹配功能；

&emsp;&emsp;2. 在RV32汇编环境中，完成C程序的预编译、编译、汇编、链接及执行的过程；

&emsp;&emsp;3. 编写RV32汇编程序，实现字符串匹配功能。要求如下：

&emsp;&emsp;（1）母串和子串均存放在数据段，且<u>母串长度固定为16</u>，<u>子串长度固定为4</u>，比如：

``` asm  linenums="1"
.data
    str1:   .string "1qab9a0bcabcds13"
    str2:   .string "bcds"

.text
    ......
```

&emsp;&emsp;（2）只需任意匹配到一个子串，即可输出其位置并结束；否则输出-1后结束；

&emsp;&emsp;（3）<u>**正确使用子程序**</u>，且<u>**不可使用伪指令**</u>。

!!! tip "小提示 :bulb:"
    &emsp;&emsp;可以使用RARS帮助你判断一条指令是否伪指令 —— 对程序进行汇编后，查看`Text Segment`窗口下的`Basic`指令和`Source`指令是否相同，如果不相同，则是伪指令，如图1-1所示。

    <center><img src="../assets/1-1.png" width = 600></center>
    <center>图1-1 借助RARS查看指令是否是伪指令</center>

    &emsp;&emsp;由图1-1可知，`li t0, 0x00002000`和`jal FUNC`都是伪指令。
