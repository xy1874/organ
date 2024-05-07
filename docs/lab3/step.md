# 实验步骤

## 1. 操作步骤

&emsp;&emsp;（1）阅读实验指导书或理论课PPT，掌握IEEE754单精度浮点数的格式以及运算过程；

&emsp;&emsp;（2）打开Vivado模板工程，完成浮点运算器设计：如果采用组合电路方案，完成`fpu.v`；  
&emsp;&emsp;&emsp;&emsp;&ensp;如果采用时序电路方案，完成`fpu_clk.v`；二选一完成即可；

&emsp;&emsp;（3）运行功能仿真，根据仿真波形完成调试；

&emsp;&emsp;（4）反思实验过程，总结收获并整理遇到的问题及解决方案，撰写实验报告。



## 2. 模板工程简介

&emsp;&emsp;模板工程包含4个源文件，如表3-1所示。

<center>表3-1 模板工程源文件说明</center>
<center>

| 序号 | 文件名 | 说明 |
| :-: | :-: | :-: |
| 1 | `fpu.v` | 组合电路实现方案（<u><font color=red>需要完成</font></u>） |
| 2 | `fpu_tb.sv` | 组合电路Testbench |
| 3 | `fpu_clk.v` | 时序电路实现方案（<u><font color=red>需要完成</font></u>） |
| 4 | `fpu_tb_clk.sv` | 时序电路Testbench |

</center>

&emsp;&emsp;简言之，如果使用组合电路实现运算器，则完成`fpu.v`，并使用`fpu_tb.sv`作为仿真文件；如果使用时序电路实现运算器，则完成`fpu_clk.v`，并使用`fpu_tb_clk.sv`作为仿真文件。



## 3. 仿真调试说明

### 3.1 顶层模块设置

&emsp;&emsp;模板工程默认以`fpu_clk.v`作为顶层模块，默认以`fpu_tb_clk.sv`作为仿真的顶层模块。如果你使用的是组合电路实现运算器，则在仿真之前，需要先更改顶层模块，如图3-1所示。

<center><img src="../assets/3-1a.png" width = 450></center>
<center>图3-1 a) 更改设计的顶层模块</center>

<center><img src="../assets/3-1b.png" width = 450></center>
<center>图3-1 b) 更改仿真的顶层模块</center>

### 3.2 仿真设置

&emsp;&emsp;Vivado仿真波形中的信号值默认采用16进制显示。为了方便观察，我们可以将它设置成以IEEE754浮点数显示，如图3-2所示。

<center><img src="../assets/3-2.png" width = 450></center>
<center>图3-2 更改仿真波形显示数据的格式</center>

&emsp;&emsp;在随后打开的`Real Settings`窗口中选择`Single Precision`即可，如图3-3所示。

<center><img src="../assets/3-3.png" width = 380></center>
<center>图3-3 设置仿真显示数据位单精度浮点数</center>

### 3.3 仿真波形说明

&emsp;&emsp;对于组合电路的实现方案，仿真时，查看`answer`信号与运算器输出的运算结果是否相同。如果相同，表示运算结果正确，如图3-4所示。

<center><img src="../assets/3-4.png" width = 500></center>
<center>图3-4 查看组合方案的运算结果是否正确</center>

&emsp;&emsp;对于时序电路的实现方案，仿真时，查看`ready`信号有效时，`answer`信号与运算器输出的运算结果是否相同。如果相同，表示运算结果正确，如图3-5所示。

<center><img src="../assets/3-5.png" width = auto></center>
<center>图3-5 查看时序方案的运算结果是否正确</center>
