# 实验原理

## 1. SoC架构

&emsp;&emsp;CPU由数据通路和控制器组成，其主要功能是控制和运算。对CPU进行扩展，增加互联总线、存储器和各种各样的I/O接口电路，形成完整的计算机系统，并将整个系统集成到单芯片上，即为SoC。SoC具有集成度高、功耗低、体积小等优点，在嵌入式系统领域中被广泛应用。

&emsp;&emsp;本实验提供的SoC架构如图2-1所示。32位处理器核心`cpu_core`通过内部总线`cpu_bus`连接到`axilite_master`模块。`axilite_master`模块接收并解析`cpu_core`的数据读写请求，并将请求以AXI4-Lite总线协议发送到AXI总线桥模块。AXI总线桥模块根据地址，将来自`axilite_master`模块的数据读写请求转发给相应的从设备（如Block RAM存储器、外设）。

<center><img src="../assets/2-1.png" width = 540></center>
<center>图2-1 SoC架构图</center>



## 2. `ready-valid`握手协议

&emsp;&emsp;为确保地址、数据等信息能在发送端、接收端之间准确无误地传输，需要在传输信息时添加握手信号。握手信号之间的约定即为握手协议。

&emsp;&emsp;`ready-valid`协议是最常用的握手协议之一。`ready`信号表示接收端的就绪状态 —— 当`ready`信号有效，表示接收端已就绪，可以接收新的信息；否则表示接收端在忙，暂时不能接收信息。`valid`信号表示发送端的发送状态 —— 当`valid`信号有效，表示发送端正在发送新的信息，此时信号线上的信息为有效信息；否则表示无信息在发送，此时信号线上的信息是无效信息。

&emsp;&emsp;在`ready-valid`握手协议中，**当且仅当`ready`信号和`valid`信号均为高电平时，才能在时钟信号上升沿传输数据**。`ready-valid`握手协议的典型时序如图2-2所示。

<center><img src="../assets/2-2.PNG" width = 450></center>
<center>图2-2 `ready-valid`握手协议时序图</center>

!!! info "时序解读 :book:"
    &emsp;&emsp;在图2-2中，`data0`、`data3`为无效数据，`data1`、`data2`为有效数据，但只有`data2`被成功发送到接收端。



## 3. AXI-Lite总线协议

&emsp;&emsp;AXI4是基于`ready-valid`握手协议的高性能嵌入式总线协议，AXI4-Lite是AXI4的精简版。

&emsp;&emsp;AXI4-Lite总线包含写地址（AW）、写数据（W）、写响应（B）、读地址（AR）和读数据（R）五个通道，各通道相互独立且可并行工作，AXI4-Lite也因此具备同时传输写请求和读请求的能力。

&emsp;&emsp;AW、W和B通道用于传输写请求，AR和R通道用于传输读请求。各通道的功能、信号定义等如表2-1所示（以32位总线为例）。

<center>表2-1 AXI4-Lite总线通道及信号定义
 <table>
  <col width=60>
  <col width=100>
  <col width=58>
  <col width=50>
  <col width=80>
  <col width=220>
  <tr>
   <th align="center">通道</th>
   <th align="center">功能</th>
   <th align="center">信号</th>
   <th align="center">位宽</th>
   <th align="center">方向</th>
   <th align="center">释义</th>
  </tr>
  <tr>
   <td rowspan=3 align="center" valign="middle">写地址<br>(AW)</td>
   <td rowspan=3 valign="middle">主设备通过AW通道发送被写数据的地址</td>
   <td align="center">awaddr</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>写地址</td>
  </tr>
  <tr>
   <td align="center">awvalid</td>
   <td align="center">1</td>
   <td align="center"><b>主</b>→从</td>
   <td>写地址的有效信号</td>
  </tr>
  <tr>
   <td align="center">awready</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>从设备AW通道的就绪信号</td>
  </tr>
  <tr>
   <td rowspan=4 align="center" valign="middle">写数据<br>(W)</td>
   <td rowspan=4 valign="middle">主设备通过W通道发送被写数据及写使能信号</td>
   <td align="center">wdata</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>写数据</td>
  </tr>
  <tr>
   <td align="center">wstrb</td>
   <td align="center">4</td>
   <td align="center"><b>主</b>→从</td>
   <td>写使能，每位对应1字节</td>
  </tr>
  <tr>
   <td align="center">wvalid</td>
   <td align="center">1</td>
   <td align="center"><b>主</b>→从</td>
   <td>写数据的有效信号</td>
  </tr>
  <tr>
   <td align="center">wready</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>从设备W通道的就绪信号</td>
  </tr>
  <tr>
   <td rowspan=3 align="center" valign="middle">写响应<br>(B)</td>
   <td rowspan=3 valign="middle">从设备通过B通道返回写操作结果</td>
   <td align="center">bready</td>
   <td align="center">1</td>
   <td align="center"><b>主</b>→从</td>
   <td>主设备B通道的就绪信号</td>
  </tr>
  <tr>
   <td align="center">bresp</td>
   <td align="center">2</td>
   <td align="center">从→<b>主</b></td>
   <td>写操作结果（可忽略）</td>
  </tr>
  <tr>
   <td align="center">bvalid</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>写响应的有效信号</td>
  </tr>
  <tr>
   <td rowspan=3 align="center" valign="middle">读地址<br>(AR)</td>
   <td rowspan=3 valign="middle">主设备通过AR通道发送被读数据的地址</td>
   <td align="center">araddr</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>读地址</td>
  </tr>
  <tr>
   <td align="center">arvalid</td>
   <td align="center">1</td>
   <td align="center"><b>主</b>→从</td>
   <td>读地址的有效信号</td>
  </tr>
  <tr>
   <td align="center">arready</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>从设备AR通道的就绪信号</td>
  </tr>
  <tr>
   <td rowspan=4 align="center" valign="middle">读数据<br>(R)</td>
   <td rowspan=4 valign="middle">从设备通过R通道返回被读取数据</td>
   <td align="center">rready</td>
   <td align="center">1</td>
   <td align="center"><b>主</b>→从</td>
   <td>主设备R通道的就绪信号</td>
  </tr>
  <tr>
   <td align="center">rdata</td>
   <td align="center">32</td>
   <td align="center">从→<b>主</b></td>
   <td>读数据</td>
  </tr>
  <tr>
   <td align="center">rresp</td>
   <td align="center">2</td>
   <td align="center">从→<b>主</b></td>
   <td>读操作结果（可忽略）</td>
  </tr>
  <tr>
   <td align="center">rvalid</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>读响应的有效信号</td>
  </tr>
 </table>
</center>

### 3.1 AXI4-Lite写时序

&emsp;&emsp;AXI4-Lite总线的写操作时序如图2-3所示。

<center><img src="../assets/2-3.png"></center>
<center>图2-3 AXI4-Lite总线写时序</center>

&emsp;&emsp;只要有写请求需要发送，主设备就可以将写地址、写数据分别发送到AW通道和W通道。对于AW通道，主设备需在拉高`awvalid`的同时将写地址发送到`awaddr`，且 **主设备必须维持`awvalid`和`awaddr`有效，直到从设备拉高`awready`**。从设备拉高`awready`后，主设备才能撤掉AW通道上的写请求。W通道同理。

&emsp;&emsp;特别注意，**即使`awvalid`和`wvalid`同时拉高，`awready`和`wready`也不一定同时有效**。但只要`awready`有效，就表示AW通道的写地址成功被从设备接收；只要`wready`有效，就表示W通道的写数据和写使能成功被从设备接收。**当AW通道和W通道的信息都成功被从设备接收后，主设备的写请求才算发送完成**。
	
&emsp;&emsp;主设备写请求发送完成后，从设备开始进行写操作。写操作完成后，若主设备的`bready`信号有效，则从设备将拉高`bvalid`信号。主设备检测到`bvalid`有效时，即可发送新的写请求。

&emsp;&emsp;为简化设计，在本实验中，可令`bready`一直有效，并忽略`bresp`信号。

### 3.2 AXI4-Lite读时序

&emsp;&emsp;AXI4-Lite总线的读操作时序如图2-4所示。

<center><img src="../assets/2-4.png"></center>
<center>图2-4 AXI4-Lite总线读时序</center>

&emsp;&emsp;只要有读请求需要发送，主设备就可以将读地址发送到AR通道。主设备需在拉高`arvalid`的同时将读地址发送到`araddr`，且 **主设备必须维持`arvalid`和`araddr`有效，直到从设备拉高`arready`**。

&emsp;&emsp;`arready`有效，表示主设备的读地址成功被从设备接收。从设备接收读地址后，开始进行读操作。读操作完成后，若主设备的`rready`信号有效，则从设备将拉高`rvalid`信号，同时将读到的数据发送到`rdata`。**`rvalid`和`rdata`只有效一个时钟周期**。

&emsp;&emsp;为简化设计，在本实验中，可令`rready`信号一直有效，并忽略`rresp`信号。



## 4. `cpu_bus`总线

&emsp;&emsp;`cpu_bus`是处理器核心`cpu_core`与`axilite_master`模块之间的数据传输总线，包含写数据（W）、读数据（R）两个相互独立的通道，各通道的信号定义如表2-2所示。

<center>表2-2 `cpu_bus`信号定义
 <table>
  <col width=80>
  <col width=58>
  <col width=50>
  <col width=80>
  <col width=220>
  <tr>
   <th align="center">通道</th>
   <th align="center">信号</th>
   <th align="center">位宽</th>
   <th align="center">方向</th>
   <th align="center">释义</th>
  </tr>
  <tr>
   <td rowspan=4 align="center" valign="middle">写数据<br>(W)</td>
   <td align="center">wrdy</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>从设备W通道的就绪信号</td>
  </tr>
  <tr>
   <td align="center">wen</td>
   <td align="center">4</td>
   <td align="center"><b>主</b>→从</td>
   <td>写使能，支持写字、半字和字节</td>
  </tr>
  <tr>
   <td align="center">waddr</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>写地址</td>
  </tr>
  <tr>
   <td align="center">wdata</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>写数据</td>
  </tr>
  <tr>
   <td rowspan=5 align="center" valign="middle">读数据<br>(R)</td>
   <td align="center">rrdy</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>从设备R通道的就绪信号</td>
  </tr>
  <tr>
   <td align="center">ren</td>
   <td align="center">4</td>
   <td align="center"><b>主</b>→从</td>
   <td>读使能，支持读字、半字和字节</td>
  </tr>
  <tr>
   <td align="center">raddr</td>
   <td align="center">32</td>
   <td align="center"><b>主</b>→从</td>
   <td>读地址</td>
  </tr>
  <tr>
   <td align="center">rvalid</td>
   <td align="center">1</td>
   <td align="center">从→<b>主</b></td>
   <td>读数据的有效信号</td>
  </tr>
  <tr>
   <td align="center">rdata</td>
   <td align="center">32</td>
   <td align="center">从→<b>主</b></td>
   <td>读数据</td>
  </tr>
 </table>
</center>

&emsp;&emsp;`cpu_bus`的写操作时序如图2-5所示。

<center><img src="../assets/2-5.png" width = 600></center>
<center>图2-5 `cpu_bus`写时序</center>

&emsp;&emsp;从设备的`wrdy`信号有效时，主设备的写请求（`wen`、`waddr`、`wdata`）才会被从设备接收。从设备接收写请求后，将`wrdy`拉低，并开始处理写请求。当写请求处理完毕后，`wrdy`信号被再次拉高。

&emsp;&emsp;`cpu_bus`的读操作时序如图2-6所示。

<center><img src="../assets/2-6.png" width = 650></center>
<center>图2-6 `cpu_bus`读时序</center>

&emsp;&emsp;从设备的`rrdy`信号有效时，主设备的读请求（`ren`、`raddr`）才会被从设备接收。从设备接收读请求后，将`rrdy`拉低，并开始处理读请求。**数据被取回后，从设备根据`ren`信号按需进行符号扩展**，然后在拉高`rvalid`信号的同时将数据发送到`rdata`信号上。`rvalid`和`rdata`只有效1个周期。当读请求处理完成后，`rrdy`信号被再次拉高。

!!! tip "信号分析 :wavy_dash:"
    &emsp;&emsp;事实上，`cpu_bus`总线协议可看作`ready-valid`协议的简化版变体。在`cpu_bus`总线中，使能信号（包括`wen`和`ren`）兼有`valid`信号的作用 —— 使能信号为`4'b0000`时既不写也不读，相当于表示此时的数据是无效数据。
