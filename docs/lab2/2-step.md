# 实验步骤

## 1. 除法器设计

### 1.1 测试用例说明

&emsp;&emsp;TestBench提供了8个测试用例，如表3-1所示。

<center>表3-1 lab2_div工程中的测试用例</center>
<center>

| 序号 | 测试用例(DEC) | 测试用例(HEX) |
| :-: | :-: | :-: |
| 0 | $14 \div 3 = 4 \cdots 2$ | `0x0E` $\div$ `0x03` = `0x04` $\cdots$ `0x02` |
| 1 | $111 \div 31 = 3 \cdots 18$ | `0x6F` $\div$ `0x1F` = `0x03` $\cdots$ `0x12` |
| 2 | $-73 \div 6 = -12 \cdots -1$ | `0xC9` $\div$ `0x06` = `0x8C` $\cdots$ `0x81` |
| 3 | $-49 \div 11 = -4 \cdots -5$ | `0xB1` $\div$ `0x0B` = `0x84` $\cdots$ `0x85` |
| 4 | $120 \div -33 = -3 \cdots 21$ | `0x78` $\div$ `0xA1` = `0x83` $\cdots$ `0x15` |
| 5 | $23 \div -15 = -1 \cdots 8$ | `0x17` $\div$ `0x8F` = `0x81` $\cdots$ `0x08` |
| 6 | $-19 \div -10 = 1 \cdots -9$ | `0x93` $\div$ `0x8A` = `0x01` $\cdots$ `0x89` |
| 7 | $-53 \div -25 = 2 \cdots -3$ | `0xB5` $\div$ `0x99` = `0x02` $\cdots$ `0x83` |

</center>

### 1.2 操作步骤

&emsp;&emsp;（1）从实验包下载并打开模板工程 lab2_div，基于恢复余数法或加减交替法，**完成`divider`模块**。

&emsp;&emsp;（2）运行功能仿真，通过分析波形对所设计的原码除法器进行调试和验证。必要时可将除法器内部关键信号添加到波形窗口，如图3-1所示。

<center><img src="../assets/3-1.png" width = 100%></center>
<center>图3-1 添加模块内部信号到仿真波形窗口</center>

!!! info "仿真信号说明 :page_facing_up:"
    &emsp;&emsp;在图3-1中，带有“`dut_`”前缀的信号是除法器模块的接口信号，而带有`tb_`前缀的信号则表示TestBench的信号。其中，`tb_i`表示测试用例的编号；`tb_ans_z`和`tb_ans_r`分别表示当前测试用例的商和余数的正确值；`tb_z_err`和`tb_r_err`分别表示除法器的商和余数是否有错误的标志信号。

&emsp;&emsp;**运行功能仿真时，点击工具栏的“Run All”按钮**，如图3-2所示。此时，TestBench将一直运行，直到发现错误，或通过了所有测试用例。

<center><img src="../assets/3-2.png" width = 380></center>
<center>图3-2 点击“Run All”按钮，一键运行所有测试用例</center>

&emsp;&emsp;TestBench在复位后，将遵照<a href="../1-theory/#22" target="_blank">实验原理-2.2节</a>图2-4所示的时序，发出第一个测试用例。当TestBench检测到`divider`模块的`busy`信号变成低电平后，将检查除法结果的正确性，如果发现错误，将在Vivado控制台报错并结束仿真，如图3-3所示；如果除法结果正确，则继续发出下一个测试用例。

<center><img src="../assets/3-3.png" width = 430></center>
<center>图3-3 TestBench检查到除法结果错误</center>

&emsp;&emsp;若成功通过了所有的测试用例，则TestBench将在控制台打印通过TestBench的提示信息，如图3-4所示。

<center><img src="../assets/3-4.png" width = 430></center>
<center>图3-4 通过所有测试用例后的提示信息</center>



## 2. 除法器集成

### 2.1 测试用例说明

&emsp;&emsp;SoC工程包含32位的多周期RISC-V CPU，能够执行部分常用的整数指令。因此，SoC工程的测试用例是以汇编程序的形式提供的。

&emsp;&emsp;从实验包下载测试程序 mul_div_test.asm，其部分代码如图3-5所示。

``` asm linenums="1"
.text
MAIN:
	lui a7, 0xFFFF1         # 将LED外设的地址0xFFFF1000赋值到a7寄存器

	# test0
	lui  t0, 0x40000
	ori  t0, t0, 0x7B       # 将被除数x赋值到t0寄存器
	ori	 t1, zero, 0x165    # 将除数y赋值到t1寄存器
	mul  a0, t0, t1		# 计算x*y并将乘积的 **低32位** 赋值给a0寄存器
	sw   a0, 0(a7)          # 将a0寄存器的值写入到LED外设，从而在LED上显示a0的值
	mulh a1, t0, t1		# 计算x*y并将乘积的 **高32位** 赋值给a1寄存器
	sw   a1, 0(a7)          # 在LED上显示a1的值
	div  a2, t0, t1		# 计算x/y并将商赋值给a2寄存器
	sw   a2, 0(a7)          # 在LED上显示a2的值
	rem  a3, t0, t1		# 计算x%y并将余数赋值给a3寄存器
	sw   a3, 0(a7)          # 在LED上显示a3的值

	......
	
END_LOOP:
	addi zero, zero, 0
	jal  zero, END_LOOP
```
<center>图3-5 SoC工程的乘除法测试程序</center>

&emsp;&emsp;测试程序 mul_div_test.asm 共提供了4组测试用例，如表3-2所示。

<center>表3-2 SoC工程中的乘除法测试用例</center>
<center>

| $x$ | $y$ | $x \times y$ | $x \div y$ |
| :-: | :-: | :-: | :-: |
| `0x4000_007B` | `0x165` | `0x59_4000_AB87` |  `0x2D_E4C0` ... `0xBB` |
| `-26` | `5` | `0xFFFF_FFFF_FFFF_FF7E` | `0xFFFF_FFFB` ... `0xFFFF_FFFF` |
| `0x4567_0064` | `-13` | `0xFFFF_FFFC_79C4_FAEC` | `0xFAA9_4EBE` ... `0xA` |
| `-306` | `-28` | `0x2178` | `0xA` ... `0xFFFF_FFE6` |

</center>



### 2.2 操作步骤

&emsp;&emsp;从实验包下载SoC工程 miniRV_AXI，解压后阅读readme文档。

&emsp;&emsp;打开SoC工程后，依次展开`soc`->`U_cpu`->`U_core`->`U_ALU`，找到最内层的乘法器模块`U_mul`和除法器模块`U_div`。其中，<u>乘法器模块是附加题的内容</u>。

&emsp;&emsp;双击打开乘除法器模块的代码，可见其内部是用运算符实现乘除法功能的，如图3-5所示。

``` verilog title="divider.v" linenums="1"
`timescale 1ns / 1ps

module divider (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] x,
    input  wire [31:0] y,
    input  wire        start,
    output reg  [31:0] z,       // 只需保证接口信号的输入输出属性不变、位宽不变、
    output reg  [31:0] r,       // 信号名不变。接口信号的数据类型可根据实际需要，
    output reg         busy     // 自行修改成wire型或reg型。
);

    // ****************************************************
    // Delete this block of code and write your own
    reg [31:0] x_r, y_r;
    always @(posedge clk or posedge rst) begin
        busy <= rst ? 1'b0 : start;
        if (start) begin
            x_r <= x;
            y_r <= y;
        end
    end
    always @(*) z = {x_r[31] ^ y_r[31], x_r[30:0] / y_r[30:0]};     // (1)!
    always @(*) r = {x_r[31], x_r[30:0] % y_r[30:0]};           // (2)!
    // ****************************************************



    // TODO



endmodule
```

1. 用除法符号“`/`”实现商的计算
2. 用求余符号“`%`”实现余数的计算

<center>图3-5 SoC工程中的除法器模块</center>

&emsp;&emsp;同学们首先需要将自己设计的8位原码除法器扩展到32位，然后替换掉图3-5所示的除法器模块，并运行功能仿真。注意，需要 **将`divider.v`的第14-26行代码删除或注释掉**。

!!! info "关于ALU集成除法器 :books:"
    &emsp;&emsp;整型数据在计算机硬件系统内部通常采用补码的形式进行运算和存储。因此，对于原码除法器，ALU需要先将补码形式的数据转换成原码，才能把数据提供给除法器进行运算；同理，ALU也需要先将除法器的运算结果转换成补码，才能将运算结果输出。详见`ALU.v`第36-37行，及第74-75行的代码。

&emsp;&emsp;完成除法器模块后，运行功能仿真。类似地，如图3-2所示点击“Run All”按钮。

&emsp;&emsp;若除法运算出错，则TestBench将在Vivado控制台打印错误提示信息，如图3-6所示。出错时，请自行将除法器内部的信号拉到波形中进行分析和调试，具体操作如图3-1所示。

<center><img src="../assets/3-6.png" width = 100%></center>
<center>图3-6 SoC工程乘除法运算的错误提示信息</center>

&emsp;&emsp;若顺利通过了所有测试用例，将在控制台看到测试通过的提示信息，如图3-7所示。

<center><img src="../assets/3-7.png" width = 500></center>
<center>图3-7 SoC工程乘除法测试通过的提示信息</center>
