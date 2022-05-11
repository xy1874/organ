# 实验准备

### 1. 熟悉存储系统模型

本次实验采用的<span style="border-bottom:2px dashed blue;">存储系统大小为8K，地址宽度为13，字长为1字节</span>。

存储器模块为mem_wrap.v，为简化实验流程，我们已将Cache缺失时连续读取4个字并拼接的工作完成，具体时序图如下：

 <center><img src="../s5-1.png" width = 420></center>  

在主存空闲阶段，Cache将地址放在raddr口上，并将rreq信号拉高，代表一次的读请求。等待若干个周期，主存将返回4个字拼接而成的数据，并将rvalid信号拉高，代表数据已经准备好，此时可以取走数据。

 <center><img src="../s5-2.png" width = 350></center>  

类似地，需要向内存中写入数据时，Cache将写地址、写数据分别从waddr、wdata端口输出，同时将wreq信号拉高1个时钟周期，即可完成写内存操作。

### 2. 项目框架概览

Ø 设计文件

driver (driver.sv) ----- 顶层模块，模拟CPU的访存行为，并进行数据正确性检查，可以看作是CPU

trace (IP核) ----- 存储标准答案

cache (cache.v) ----- Cache模块（需要完成）

mem_wrap(mem_wrap.v) ----- 主存存储器模型

模块间的关系如下图所示：

 <center><img src="../s5-3.png" width = 450></center>

Ø 仿真文件

使用说明

完成设计后，可以运行testbench.v文件中的仿真，运行仿真时，下方的Tcl Console也会打印相应的调试信息，帮助你定位出错点。

 <center><img src="../s5-4.png" width = 280></center>  

如果测试全部通过，控制台会显示相应字样，同时仿真将会停止在对应位置。

 <center><img src="../s5-5.png"></center>  

提供的Testbench将对Cache的读命中、读缺失、写命中、写缺失进行测试。对于写缺失的情形，Testbench将检测发生写缺失时，主存中的相应数据是否被不正确地修改。

另外，仿真波形应使用cache工程目录下的testbench_behav.wcfg文件。一般情况下，进行仿真时，Vivado将自动选取该文件以显示波形，故不需额外的操作。但如果发现仿真时，Vivado没有使用该文件，则需要手动导入。

### 3. 模块接口规范

| 序号 | 属性 |      名称       |          含义           | 位宽 |
| :-:  | :--: | :-------------: | :---------------------: | :--: |
|   1  | 输入 |       clk       |          时钟           |  1   |
|   2  | 输入 |      reset      |   复位（高电平有效）    |  1   |
|   3  | 输入 |  addr_from_cpu  |     CPU的读/写地址      |  13  |
|   4  | 输入 |  rreq_from_cpu  |       CPU的读请求       |  1   |
|   5  | 输入 |  wreq_from_cpu  |       CPU的写请求       |  1   |
|   6  | 输入 |  wdata_from_cpu |       CPU的写数据       |  8   |
|   7  | 输出 |  rdata_to_cpu   |     Cache读出的数据     |  8   |
|   8  | 输出 |   hit_to_cpu    |        命中标记         |  1   |
|   9  | 输入 | rdata_from_mem  | 主存模块读取的连续4字节 |  32  |
|  10  | 输入 | rvalid_from_mem |    主存读取完毕标记     |  1   |
|  11  | 输出 |   rreq_to_mem   |       读主存请求        |  1   |
|  12  | 输出 |  raddr_to_mem   |      读主存首地址       |  13  |
|  13  | 输出 |   wreq_to_mem   |       写主存请求        |  1   |
|  14  | 输出 |  waddr_to_mem   |       写主存地址       |  13  |
|  15  | 输出 |  wdata_to_mem   |       写主存数据       |  8  |

### 4. Cache模块时序规范

Cache存储体调用Block RAM的IP核实现，因此，我们需要了解Block RAM的读时序。IP核的使用见后文附录。

- **Block RAM的读写时序：**

 <center><img src="../s5-6.png" width = 700></center>

Ø 读时序：上一周期给出地址，下一周期输出数据，可连续读取。（周期1，2，3）

Ø 写时序：上一周期给数据、写地址，拉高wea信号，下一周期成功写入数据，刚刚写入的数据出现在douta口上。

- **Cache的读时序**

 <center><img src="../s5-7.png" width = 600></center>  

下面以 Cyc# 代表周期号，详细叙述Cache和CPU之间的通信约定。

Ø CPU发来rreq信号，同时把地址放在addr端口上(Cyc #0)，代表启动一次读操作。在得到Cache的hit响应(Cyc #1)之前，CPU会保证：rreq_from_cpu信号不会撤下，且地址线addr_from_cpu上的地址不会改变。

Ø 在得到Cache的hit响应之后(Cyc #1)，CPU会保证：在hit信号到来的下一个周期(Cyc #2)，rreq信号马上撤下。Cache需要做到：hit响应信号和读出的数据只需持续一个周期(Cyc #1 - Cyc #2)，同时有效。

Ø CPU未发rreq信号的时候，Cache需要做到：hit信号始终为0，不得置高，数据输出可以是任意值。

- **Cache的写时序**

 <center><img src="../s5-8.png" width = 530></center>

Ø CPU发来wreq信号，同时把写地址和写数据分别放在addr和data端口上(Cyc #0)，代表启动一次写操作。与读操作不同的是：不管Cache是否写命中，CPU的写请求信号wreq_from_cpu、写数据信号wdata_from_cpu以及地址信号addr_from_cpu都只会有效2个周期(Cys #0 - Cyc #2、Cys #3 - Cyc #5)。

Ø 如果Cache写命中，则Cache将在收到wreq的下一个周期输出hit响应信号(Cyc #1)。由于采用写直达的写策略，此时Cache还需按照Block RAM的写时序，向内存输出写数据信号。

Ø 如果Cache写缺失，则Cache需要保证hit信号始终保持低电平(Cyc #4)，并且此时Cache不得修改主存的数据。
