# 实验原理

&emsp;&emsp;存储器的访问性能很大程度上受限于物理介质。随着CPU性能的不断提高，CPU与存储器之间的速度差异越来越大，形成了“存储墙”（Memory Wall）。为缓解存储器速度对计算机系统整体性能的影响，并考虑到成本问题，现代计算机普遍使用了多级存储系统，如图2-1所示。

<center><img src="../assets/2-1.png" width = 550></center>
<center>图2-1 现代计算机系统的多级存储系统</center>

&emsp;&emsp;高速缓存器（Cache）是现代计算机系统中常用的用于提高访存性能的缓存器。Cache的大小、结构均与主存不同，而CPU发出的访存地址均为主存地址。为使得CPU能访问Cache，需要建立主存地址与Cache地址的映射关系。常用的映射方式有全相联映射、直接映射和组相联映射。

## 1. 直接映射方式

&emsp;&emsp;直接映射是一种完全依据主存地址来分配存储单元在Cache中的存放位置的映射方式。在直接映射Cache中，每一个主存地址都被映射到Cache中的一个固定的位置。这种确定的映射方式使得Cache中的数据能够被快速检索，实现了较低的访问延迟。

&emsp;&emsp;在直接映射Cache中，主存在逻辑上被划分成若干个区，每个区的大小等于Cache的大小，并且每个区中的所有数据块都能 <u>**按照其块序号**</u> 缓存在Cache中的对应位置。

&emsp;&emsp;直接映射方式及相应的主存地址、Cache地址格式如表2-1所示。

<center>表2-1 主存大小为4MB、Cache大小为32KB、块大小为128B的直接映射Cache示例</center>
<center><img src="../assets/t2-1.png" width = 550></center>

&emsp;&emsp;由表2-1可知，主存地址在逻辑上被划分成 <u>**区号**</u>、<u>**区内块号**</u> 和 <u>**块内偏移地址**</u> 三部分。其中，区号用于记录数据块的主存地址信息，<u>**在访问Cache时作为块标签使用**</u>；区内块号用于在Cache中检索数据块；块内偏移地址则用于从Cache块中取出CPU所需的数据。Cache地址则仅由块序号和块内偏移地址组成。

!!! info "主存的地址分解 :books:"
    &emsp;&emsp;在表2-1所示的示例中，主存大小为4MB，Cache大小为32KB，数据块大小为128B，故可知：

    &emsp;&emsp;（1）主存地址位宽是22bit；  
    &emsp;&emsp;（2）Cache地址位宽是15bit  
    &emsp;&emsp;（3）块内地址位宽是7bit；
    
    &emsp;&emsp;已知Cache地址由块号和块内地址组成，故块号的位宽等于Cache地址位宽减去块内地址位宽，即15bit - 7bit = 8bit。

    &emsp;&emsp;类似地，主存地址中，区号的位宽等于主存地址位宽减去块号位宽和块内地址位宽，即22bit - 8bit - 7bit = 7bit。

&emsp;&emsp;事实上，表2-1左侧的Cache仅描述Cache的数据缓存部分。为实现Cache数据块的访问，通常需要为每个数据块添加有效位（valid）和标签（tag）等辅助信息。

## 2. 直接映射Cache结构

### 2.1 Cache存储体结构

&emsp;&emsp;Cache存储体的典型结构如图2-2所示。

<center><img src="../assets/2-2.png" width = 320></center>
<center>图2-2 Cache存储体结构</center>

&emsp;&emsp;由图2-2可知，Cache存储体由有效位（valid）、标签（tag）和数据（data）三部分组成：

- **有效位（valid）**：表示当前Cache块是否有效 —— “有效”指的是Cache块的数据是否可用。  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;初始状态下，所有Cache块均为无效，当内存中的数据块装入了Cache后，  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;该Cache块的数据将变成有效的。

- **标签（tag）**&emsp;&ensp;：表示Cache块所存储数据的主存地址信息。Cache的容量远小于主存，因此  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;多个主存数据块将被映射到同一个Cache块。为了加以区分，需将主存地址  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;中的区号作为块标签记录在Cache中。

- **数据（data）**&emsp;：存储被装入的主存数据块。一个数据块包含多个地址连续的存储单元。

### 2.2 Cache访问原理

&emsp;&emsp;访问Cache的电路原理如图2-3所示。

<center><img src="../assets/2-3.png" width = 350></center>
<center>图2-3 访问直接映射Cache的电路原理图</center>

&emsp;&emsp;在图2-3中，访问直接映射Cache的基本过程是：

&emsp;&emsp;（1）**地址划分**：将主存地址划分成块标签（即表2-1中的区号）、块号、块内偏移3个字段；

&emsp;&emsp;（2）**Cache块寻址**：使用主存地址的块号作为索引访问Cache存储体，取出一个Cache块；

&emsp;&emsp;（3）**命中判断**：判断取出的Cache块是否有效，并判断Cache块中的tag是否等于主存地址的  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;块标签；若两个条件均为真，则表示Cache命中，否则表示Cache缺失；

&emsp;&emsp;（4）**取出数据**：使用主存地址的块内偏移从Cache块的数据域中取出相应的数据单元，  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;并将数据单元返回给CPU；在本实验中，每个数据单元均是32位的字；

&emsp;&emsp;（5）**缺失处理**：若Cache缺失，则Cache将<u>以当前的主存地址</u>通过总线<u>向主存发出读请求</u>，  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;并将主存返回的数据块，连同<u>有效位</u>和当前<u>主存地址的块标签</u>，形成新的  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;Cache块，并将其存储到Cache存储体中，最后将读取的数据返回给CPU。

&emsp;&emsp;Cache的访问过程具有一定的逻辑先后顺序关系，并且访问过程还需判断命中信号的取值从而决定后续的操作。在工程实践中，具有类似特点的电路均可使用状态机实现。



## 3. Cache设计原理

### 3.1 Cache访问的状态机

&emsp;&emsp;分析2.2节所述的Cache访问过程，不难设计出类似于图2-4所示的Cache访问状态机。

<center><img src="../assets/2-4.png" width = 300></center>
<center>图2-4 直接映射Cache的读访问状态机</center>

&emsp;&emsp;图2-4所示的状态机具有3个状态：

- **IDLE** 状态：&emsp;&emsp;&emsp;&ensp; 等待CPU的访问请求，并在收到请求后进入TAG_CHECK状态。  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;在该状态下，Cache需要给各个信号赋默认值。

- **TAG_CHECK** 状态： 判断CPU的访问请求是否命中。若命中，返回数据并回到IDLE状态；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;若缺失，则进入REFILL状态以重填相应的Cache块。

- **REFILL** 状态：&emsp;&emsp;&ensp;  以CPU的访存地址向总线发出读请求，并在接收到主存返回的数据后，  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;回到TAG_CHECK状态。

&emsp;&emsp;实际在设计Cache的状态机时，需要结合具体工程中的模块和时序要求，对图2-4所示的状态机进行相应的调整。在此基础上，进一步分析Cache访问过程，得出每个状态下的输入输出信号，最后再使用数字逻辑实验中的“三段式”实现状态机即可。

### 3.2 ICache接口信号

&emsp;&emsp;本实验与上一个实验使用同一个SoC工程。在SoC中，Cache一方面需要接收和处理CPU的访问请求，另一方面需要通过总线访问主存储器，如图2-5所示。

<center><img src="../assets/2-5.png" width = 320></center>
<center>图2-5 SoC中的Cache</center>

&emsp;&emsp;由图2-5可知，Cache的接口信号可分为两组，一组是面向CPU的接口信号，另一组是面向总线的接口信号。特别地，ICache对CPU是只读的，其接口信号如表2-2所示。

<center>表2-2 ICache模块接口信号</center>
<center>

| 序号 | 名称 | 位宽 | 属性 | 功能描述 |
| :-: | :-: | :-: | :-: | :-: |
| 1 | `cpu_clk` | `1` | 输入 | 时钟信号 |
| 2 | `cpu_rst` | `1` | 输入 | 复位信号（高电平复位） |
| 3 | `inst_rreq` | `1` | 输入 | 取指请求信号：高电平表示CPU需要取指 |
| 4 | `inst_addr` | `32` | 输入 | 取指的地址 |
| 5 | `inst_valid` | `1` | 输出 | 指令是否有效/ICache命中信号 |
| 6 | `inst_out` | `32` | 输出 | 取到的指令 |
| 7 | `mem_rrdy` | `1` | 输入 | 就绪信号：高电平表示内存就绪 |
| 8 | `mem_ren` | `4` | 输出 | 向内存读数据的掩码/读使能信号 |
| 9 | `mem_raddr` | `32` | 输出 | 向内存发出的读地址 |
| 10 | `mem_rvalid` | `1` | 输入 | 读内存的数据有效信号 |
| 11 | `mem_rdata` | `128` | 输入 | 从内存读取的数据块 |

</center>

&emsp;&emsp;在表2-2中，前缀为“`inst_`”的信号是ICache面向CPU的接口信号；前缀为“`mem_`”的信号则是ICache面向总线的接口信号。

&emsp;&emsp;ICache面向CPU的接口信号时序如图2-6所示。

<center><img src="../assets/2-6.png" width = 610></center>
<center>图2-6 ICache面向CPU的接口信号时序</center>

!!! info "时序解读 :teacher:"
    - 【*clk0*】CPU需要取指时拉高`inst_req`信号，同时给出指令地址`inst_addr`。  
    - 【*clk1*】`inst_req`信号 **仅有效一个时钟周期**，但`inst_addr`信号将保持不变直到CPU发出下一个取指请求。  
    - 【*clk2*】ICache在命中或处理完缺失后，向CPU发出命中信号`inst_valid`和指令编码`inst_out`。  
    - 【*clk3*】`inst_valid`和`inst_out`**仅有效一个时钟周期**。  
    - 【*clk4*】`inst_valid`恢复低电平后，若CPU有新的取指请求，将继续拉高`inst_req`信号。

&emsp;&emsp;ICache面向总线的接口信号时序如图2-7所示。

<center><img src="../assets/2-7.png" width = 620></center>
<center>图2-7 ICache面向总线的接口信号时序</center>

!!! info "时序解读 :teacher:"
    - 【*clk0*】总线就绪后，拉高`mem_rrdy`信号。**只有当`mem_rrdy`信号有效时，ICache才能发出读访存请求。**  
    - 【*clk1*】ICache检测到`mem_rrdy`信号有效后，向总线发出读使能信号`mem_ren`和读地址信号`mem_raddr`。  
    &emsp;&emsp;&emsp;&ensp; 对于ICache，**`mem_ren`信号的取值只可能是`4'b0000`或`4'b1111`**。     
    - 【*clk2*】读使能信号`mem_ren`和读地址信号`mem_raddr`**仅有效一个时钟周期**。
    - 【*clk3*】总线模块接收到ICache的读请求后，在一个时钟周期后拉低`mem_rrdy`信号，并开始读主存。  
    - 【*clk4*】总线读内存完毕后，拉高`mem_rvalid`信号并返回读取的数据`mem_rdata`，同时拉高`mem_rrdy`信号。  
    - 【*clk5*】`mem_rvalid`信号 **仅有效一个时钟周期**。

### 3.3 ICache工作时序

&emsp;&emsp;综合图2-4所示的状态机，以及图2-6和图2-7所示的ICache接口时序，可得如图2-8所示的ICache工作时序图。

<center><img src="../assets/2-8.png" width = 100%></center>
<center>图2-8 ICache工作时序</center>

!!! info "时序解读 :teacher:"
    （1）命中时（clk0 ~ clk2）  
    &emsp;&emsp;**·**【*clk0*】CPU向ICache发出取指请求（拉高`inst_req`信号，同时给出指令地址`inst_addr`）。ICache接收到  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;取指请求后，将从`IDLE`状态转移到`TAG_CHECK`状态。  
    &emsp;&emsp;**·**【*clk1*】ICache在`TAG_CHECK`状态下判断命中，故拉高`inst_valid`信号，同时输出指令给CPU。  
    &emsp;&emsp;**·**【*clk2*】ICache拉低`inst_valid`信号，代表当前取指请求已处理完毕。此时ICache回到`IDLE`状态。

    （2）缺失时（clk3 ~ clk10）  
    &emsp;&emsp;**·**【*clk3*】CPU向ICache发出取指请求。ICache接收到取指请求后，将从`IDLE`状态转移到`TAG_CHECK`状态。  
    &emsp;&emsp;**·**【*clk4*】ICache在`TAG_CHECK`状态下判断不命中，需要通过总线读取主存数据，从而重填Cache块。此时ICache  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;将从`TAG_CHECK`状态转移到`REFILL`状态。  
    &emsp;&emsp;**·**【*clk5~7*】在`REFILL`状态下，ICache等待主存就绪（即`mem_rrdy`信号有效）之后，向主存发出读请求（读使能  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;`mem_ren`和读地址`mem_raddr`）。此时，ICache将停留在`REFILL`状态从而等待主存返回数据。  
    &emsp;&emsp;**·**【*clk8*】总线返回被读取的主存数据块。ICache检测到`mem_rvalid`有效后，读取`mem_rdata`上的数据块，添加  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;有效位和块标签，形成新的Cache块，并将其存储到ICache的存储体中。此时，ICache将从`REFILL`状态  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;回到`TAG_CHECK`状态。  
    &emsp;&emsp;**·**【*clk9*】ICache在`TAG_CHECK`状态下判断命中，故拉高`inst_valid`信号，同时输出指令给CPU。  
    &emsp;&emsp;**·**【*clk10*】当前取指请求已处理完毕，此时ICache回到`IDLE`状态。

### 3.4 ICache和主存的存储介质

&emsp;&emsp;本实验使用Block Memory作为ICache和主存的物理存储介质。Block Memory是FPGA内部的分散到各个可编程逻辑区域的微型存储器，具有访问速度快、容量较大、不占用额外可编程逻辑资源等优点。

&emsp;&emsp;在现代计算机系统中，主存通常采用DRAM作为存储介质，而Cache则一般采用速度更高但价格更贵的SRAM存储介质。SRAM的访问速度通常是DRAM的数十倍甚至上百倍。本实验通过给主存模块添加随机访问延迟来模拟主存和Cache之间的访问速度差异。

&emsp;&emsp;通过在HDL工程中创建并实例化“Block Memory Generator” IP核，即可使用FPGA片内的Block Memory存储资源。在本实验中，ICache模块已经完成了此IP核的创建和实例化（详见<a href="../2-step/#1" target=_blank>实验步骤 - 1.操作步骤&ensp;之（3）</a>）。

&emsp;&emsp;Block Memory的接口信号如表2-3所示。

<center>表2-3 Block Memory IP核的接口信号</center>
<center>

| 序号 | 名称 | 属性 | 功能描述 |
| :-: | :-: | :-: | :-: |
| 1 | `clka` | 输入 | 时钟信号 |
| 2 | `addra` | 输入 | 地址信号（读、写共用） |
| 3 | `wea` | 输入 | 写使能信号 |
| 4 | `dina` | 输入 | 写数据信号 |
| 5 | `douta` | 输出 | 读数据信号 |

</center>

&emsp;&emsp;Block Memory的读写时序如图2-9所示。

<center><img src="../assets/2-9.png" width = 420></center>
<center>图2-9 Block Memory IP核的读写时序</center>

!!! info "时序解读 :teacher:"
    - 【*clk0、clk2*】时钟上升沿在`addra`端口给出读地址，并在下一个时钟从`douta`端口读取数据。**读操作时，写使能**  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;**信号wea需为低电平。**  
    - 【*clk1*】&emsp;&emsp;&ensp; 时钟上升沿在`addra`端口给出写地址，拉高写使能信号`wea`，同时在`dina`端口给出写数据。**写使**  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;**能信号`wea`仅有效一个时钟**。此外，进行写操作时，**`douta`端口将在下一个时钟输出写数据的值**。
