# 实验原理

## 1. C程序与汇编、机器码的关系

&emsp;&emsp;编写好的C程序通常要经过 **编译** 和 **汇编** 过程才能变成机器码，而汇编得到的机器码还需经过 **链接** 和 **加载运行** 才能变成真正可运行的程序，如图2-1所示。

<center><img src="../assets/2-1.png" width = 280></center>
<center>图2-1 C程序从编译到执行的过程</center>

### 1.1 编译阶段

&emsp;&emsp;在编译阶段，编译器（Compiler）将C程序（`.c`）经过编译，生成汇编程序（`.s`或`.asm`）。进一步地，编译阶段分为预编译和编译两个步骤。

#### 1.1.1 预编译

&emsp;&emsp;预编译即预处理，主要执行以下操作：

&emsp;&emsp;1）**宏定义处理**：

&emsp;&emsp;&emsp;&emsp;删除`#define`语句，并展开相应的宏定义。  
&emsp;&emsp;&emsp;&emsp;处理条件预编译指令，如`#if`、`#ifdef`、`#elif`、`#else`、`#endif`等。

&emsp;&emsp;2）**预编译指令处理**：

&emsp;&emsp;&emsp;&emsp;处理`#include`预编译指令，将被包含的文件插入到该预编译指令的位置。

&emsp;&emsp;3）**删除注释**：

&emsp;&emsp;&emsp;&emsp;删除所有注释，包括单行注释“`//`”和多行注释“`/* */`”。

&emsp;&emsp;4）**添加行号和文件标识**：

&emsp;&emsp;&emsp;&emsp;在源文件中添加行号和文件标识，以便编译时产生调试用的行号及编译错误警告行号。

&emsp;&emsp;5）**保留编译器指令**：

&emsp;&emsp;&emsp;&emsp;保留所有的`#pragma`编译器指令，后续编译过程需要使用它们。

#### 1.1.2 编译

&emsp;&emsp;编译器对预处理后的文件进行<u>词法分析</u>、<u>语法分析</u>、<u>语义分析</u>、<u>中间代码生成及优化</u>、<u>目标代码生成</u>等，最终生成汇编程序。

### 1.2 汇编阶段

&emsp;&emsp;在汇编阶段，汇编器（Assembler）将汇编程序（`.s`或`.asm`）翻译生成<a href="https://wiki.osdev.org/ELF" target="_blank">ELF格式</a>（Executable and Linkable Format）的目标文件（`.o`）。目标文件由机器码组成。

&emsp;&emsp;汇编时，每一条汇编语句几乎都对应一条机器码指令。因此，汇编比编译简单许多 —— 汇编器只需要根据指令的编码格式，将汇编指令逐条翻译成机器码指令。

&emsp;&emsp;若源程序由多个源文件构成，则每个源文件都要先经过编译和汇编生成相应的目标文件。

&emsp;&emsp;目标文件内的程序是以机器码的形式存放的，且<u>每一个目标文件都是最终程序的一部分</u>。只有将它们链接起来形成完整的程序，才能被CPU执行。

!!! info "小拓展 :book:"

    &emsp;&emsp;一个ELF文件通常包含以下内容：

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **ELF Header**：一个`16B`的字节序列，描述系统字（`Word`）的大小、字节顺序等；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.text**：代码段（Text Segment），即程序的机器代码；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.data**：数据段（Data Segment），存放代码中具有非零初始值的全局变量；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.rodata**：只读数据段，存放代码中的常量，如字符串常量、全局常量等；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.bss**：存放未被初始化或初始值为0的全局变量和静态变量；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.symtab**：符号表，存放代码中定义和引用的符号信息，如函数、变量、常量等；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.debug**：存放调试信息，包含源代码、行号等。只有编译时添加“`-g`”选项才会生成；

    &emsp;&emsp;:diamond_shape_with_a_dot_inside: **.strtab**：字符串表，包含定义的字符串和节（section）的名字。

### 1.3 链接阶段

&emsp;&emsp;汇编生成的目标文件不能直接运行。为了得到能够被操作系统加载运行的可执行文件，必须在目标文件中包含固定格式的信息头，还必须将目标文件与系统提供的启动代码链接起来。这些工作都是由链接器完成的。

&emsp;&emsp;在链接阶段，链接器将ELF格式的目标文件（`.o`）链接起来，形成可执行文件。

&emsp;&emsp;链接一般需要完成以下操作：

&emsp;&emsp;1）**获取重定向表**：

&emsp;&emsp;&emsp;&emsp;从目标文件取出重定向表，获取需要重定向的符号、重定向的类型、重定向的地址等等。

&emsp;&emsp;2）**重定向**：

&emsp;&emsp;&emsp;&emsp;根据符号表和重定向表信息，将程序中引用的符号替换成绝对地址或偏移地址。

&emsp;&emsp;3）**合并节**：

&emsp;&emsp;&emsp;&emsp;合并各目标文件的代码段和数据段，形成可执行文件。

&emsp;&emsp;4）**合并符号**：

&emsp;&emsp;&emsp;&emsp;若多个目标文件定义了相同的符号，将这些符号合并。

### 1.4 加载运行阶段

&emsp;&emsp;在加载阶段，通常由操作系统加载可执行文件并运行程序。

&emsp;&emsp;加载时通常需要完成以下操作：

&emsp;&emsp;1）**加载ELF头**：

&emsp;&emsp;&emsp;&emsp;操作系统读取可执行文件，检查文件有效性，并从文件头获取各个节的数量和大小。

&emsp;&emsp;2）**分配地址空间**：

&emsp;&emsp;&emsp;&emsp;根据节的大小信息分配虚拟地址空间。地址空间内含代码段、数据段、堆栈段等。

&emsp;&emsp;3）**装入目标程序**：

&emsp;&emsp;&emsp;&emsp;将目标程序的代码段和数据段装入到所分配的虚拟地址空间。

&emsp;&emsp;4）**设置入口地址**：

&emsp;&emsp;&emsp;&emsp;将系统调用的返回地址设置为目标程序的入口地址。

&emsp;&emsp;&emsp;&emsp;若目标程序采用静态链接方式，则入口地址为ELF头中`e_entry`所指向的地址；

&emsp;&emsp;&emsp;&emsp;若目标程序采用动态链接方式，则入口地址是动态链接程序的入口地址。

&emsp;&emsp;5）**设置参数和环境**：

&emsp;&emsp;&emsp;&emsp;将必要的参数、环境变量等复制到栈上，供程序运行使用。

&emsp;&emsp;6）**执行目标程序**：

&emsp;&emsp;&emsp;&emsp;设置程序指针寄存器、堆栈指针寄存器等，开始执行目标程序。



### 1.5 反汇编

&emsp;&emsp;汇编是将汇编代码翻译成机器码，反汇编则是将机器码重新翻译成汇编代码，是汇编过程的反过程。

&emsp;&emsp;反汇编是用于调试和定位CPU问题的最常用的手段之一。有时候我们无法获取到可执行文件对应的高级语言程序代码，因为ELF文件无法当做普通的文本文件打开。此时，我们可以使用反汇编工具，将ELF文件中的机器码翻译成汇编指令。此外，反汇编工具还能打印ELF文件的其他信息，如数据段。

## 2. RISC-V汇编程序设计

### 2.1 子程序

&emsp;&emsp;子程序是一段具有特定功能的、能被重复调用的代码。在程序设计中使用子程序，有利于增加代码可读性和可维护性。

&emsp;&emsp;RISC-V的子程序并不像X86那样需要使用专门的关键字来定义。从形式上看，RISC-V汇编的子程序可以看作是一段带有标签的、可重复执行的代码。

&emsp;&emsp;下列代码是一个在主程序中使用子程序的例子。

``` asm linenums="1"
.data
    ......

.macro push %a
    addi sp, sp, -4
    sw   %a, 0(sp) 
.end_macro

.macro pop %a
    lw   %a, 0(sp) 
    addi sp, sp, 4
.end_macro

.text
MAIN:
    ......
    jal  ra, SOME_FUNC       # Call a sub-routine.
    ......                   # Here is where the sub-routine returns.
    ori  a7, zero, 10        # Set system call number(10 for termination).
    ecall                    # This program terminates here.

SOME_FUNC:
    push t0
    push t1
    ......                   # Assume that t0 and t1 are modified here.
    pop  t1
    pop  t0
    jalr zero, 0(ra)         # The sub-routine returns.
```

- 第4-7行：`push`宏定义将一个寄存器压入栈中。

- 第9-12行：`pop`宏定义将栈顶的数据弹出到指定寄存器。

- 第17行：主程序通过`jal  ra, FUNC`指令进入子程序，并将返回地址保存至`ra`寄存器。

- 第19-20行：停机指令。

- 第23-24行：**保护现场** —— 除去用于传递返回值的寄存器之外，子程序在修改任意寄存器之前，都需要先将其压入栈中，防止子程序返回后造成主程序执行出错。

- 第26-27行：**恢复现场** —— 子程序返回之前，从栈中恢复那些被子程序修改过的寄存器。

- 第28行：子程序通过`jalr zero, 0(ra)`指令返回到主程序第18行继续执行。

!!! tip "压栈和弹栈的顺序 :books:"
    &emsp;&emsp;因为栈内的数据是后进先出的，所以保护现场时压栈的顺序应和恢复现场时弹栈的顺序相反。



### 2.2 输入与打印

&emsp;&emsp;RARS通过系统调用语句提供了输入输出功能。用户需要按照约定，设置参数寄存器，然后执行`ecall`指令即可。

&emsp;&emsp;在RARS中，`a7`寄存器用于传递系统调用的编号，具体参数则通过`a0`、`a1`等寄存器设置。详见表2-1。

<center>表2-1 RARS常用系统调用</center>
<center>

| 用途 | `a7`的值 | 参数设置 | 返回值 |
| :-: | :-: | :- | :- |
| 打印整数 | 1 | `a0`存放待打印数据 | 无 |
| 打印字符串 | 4 | `a0`存放待打印字符串（字符串需以空字符结尾） | 无 |
| 输入整数 | 5 | 无 | 读取的整数将存放在`a0` |
| 输入字符串 | 8 | `a0`存放字符串缓存的地址，`a1`存放最大允许输入的字符数 | 无 |
| 退出程序 | 10 | 无 | 无 |
| 退出程序 | 93 | `a0`存放退出参数 | 无 |

</center>

!!! example "举个栗子 :chestnut:"
    &emsp;&emsp;若想打印寄存器`t0`，则可通过以下语句实现：

    ``` asm linenums="1"
        ori   a0, t0, 0
        ori   a7, zero, 1
        ecall
    ```

!!! tip "小提示 :bulb:"
    &emsp;&emsp;若有多个信息需要打印，可通过自定义宏来实现：

    ``` asm linenums="1"
    .macro print %reg, %mode
        ori   a0, %reg, 0
        ori   a7, zero, %mode
        ecall
    .end_macro
    
    .text
        ......
        print t0, 1      # 打印t0寄存器的值
        print t1, 4      # 打印字符串（字符串地址存储在t1寄存器）
        ......
    ```
