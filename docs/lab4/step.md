# 实验步骤

## 1. 操作步骤

&emsp;&emsp;（1）阅读实验指导书，掌握AXI4-Lite总线协议，熟悉模板工程；

&emsp;&emsp;（2）打开Vivado模板工程，完成`axilite_master.v`中的<u>AW、W、AR和R四个通道</u>；

&emsp;&emsp;（3）运行功能仿真，根据仿真文件打印在Tcl Console中的调试信息完成调试；

&emsp;&emsp;（4）反思实验过程，总结收获并整理遇到的问题及解决方案，撰写实验报告。



## 2. 模板工程简介

&emsp;&emsp;Vivado模板工程的整体架构如<a href="../theory/#1-soc" target="_blank">图2-1</a>所示，各模块的含义如表3-1所示。

<center>表3-1 模板工程模块列表
 <table>
  <col width=50>
  <col width=250>
  <col width=330>
  <tr>
   <th align="center">序号</th>
   <th align="center">模块</th>
   <th align="center">释义</th>
  </tr>
  <tr><td align="center">1</td><td align="center">soc（soc.v）</td><td>SoC顶层模块</td></tr>
  <tr><td align="center">2</td><td align="center">cpu_model（cpu_model.v）</td><td>带AXI4-Lite主接口的CPU模型</td></tr>
  <tr><td align="center">3</td><td align="center">cpu_core（cpu_core.v）</td><td>模拟CPU读写存储器、拨码开关和LED</td></tr>
  <tr><td align="center">4</td><td align="center">axilite_master（axilite_master.v）</td><td>发出AXI4-Lite访问请求（<u><font color=red>需要完成</font></u>）</td></tr>
  <tr><td align="center">5</td><td align="center">axi_bridge（IP核）</td><td>AXI总线桥，按地址转发读/写请求到从设备</td></tr>
  <tr><td align="center">6</td><td align="center">blk_mem_gen_0（IP核）</td><td>SoC带AXI4-Lite从接口的<u>Block RAM存储器</u>顶层模块</td></tr>
  <tr><td align="center">7</td><td align="center">axi_gpio_0（IP核）</td><td>带AXI4-Lite从接口的<u>拨码开关</u>接口电路</td></tr>
  <tr><td align="center">8</td><td align="center">axi_gpio_1（IP核）</td><td>带AXI4-Lite从接口的<u>LED</u>接口电路</td></tr>
 </table>
</center>

&emsp;&emsp;Block RAM存储器和外设统一编址，如表3-2所示。

<center>表3-2 模板工程模块列表
 <table>
  <col width=80>
  <col width=80>
  <tr>
   <th align="center">设备</th>
   <th align="center">基址</th>
  </tr>
  <tr><td align="center">Block RAM</td><td align="center">0x0000_0000</td></tr>
  <tr><td align="center">拨码开关</td><td align="center">0xFFFF_0000</td></tr>
  <tr><td align="center">LED</td><td align="center">0xFFFF_1000</td></tr>
 </table>
</center>

&emsp;&emsp;此外，模板工程根目录下的`init.coe`为Block RAM存储器的初始数据；`top_tb_behav.wcfg`为提供的仿真波形配置文件。



## 3. 仿真调试说明

&emsp;&emsp;仿真包含三个阶段：写Block RAM存储器、读Block RAM存储器、读拨码开关写LED。

&emsp;&emsp;运行功能仿真时，仿真文件`soc_tb.v`将在Tcl Console打印数据访问请求的地址、数据等信息。当数据读写出错时，将打印出错点的相关信息，如图3-1所示。

<center><img src="../assets/3-1.png" width = 600></center>
<center>图3-1 控制台调试信息</center>

&emsp;&emsp;若通过了所有测试用例，应当在Tcl Console看到如图3-2所示的提示信息。

<center><img src="../assets/3-2.png" width = 600></center>
<center>图3-2 通过所有测试用例的提示信息</center>

&emsp;&emsp;此外，模板工程提供了波形配置文件`top_tb_behav.wcfg`，如图3-3所示。该配置文件默认显示`axilite_master`模块接收到的`cpu_bus`信号、产生的AXI4-Lite信号、关键信号`has_wr_req`和`has_rd_req`，以及顶层模块的拨码开关输入信号和LED输出信号。调试时，可根据需要自行添加其他信号。

<center><img src="../assets/3-3.png"></center>
<center>图3-3 波形配置文件</center>

&emsp;&emsp;运行仿真时，正常情况下Vivado将自动打开`top_tb_behav.wcfg`的波形配置文件。若未自动打开，可在仿真界面下，依次点击菜单栏`File`->`Simulation Waveform`->`Open Configuration…`来打开模板工程根目录下的`top_tb_behav.wcfg`文件。

&emsp;&emsp;模板工程在仿真时，遇到以下三种情况将自动停止：通过所有测试时、测试出现错误时、仿真至`100us`时。如果你实现的`axilite_master`在仿真`100us`时仍未结束测试，可点击菜单栏的`Run All`按钮或按下快捷键`F3`，Testbench将继续运行，直到通过所有测试或测试出现错误，如图3-4所示。

<center><img src="../assets/3-4.png" width = 350></center>
<center>图3-4 继续运行测试直到结束或停止</center>
