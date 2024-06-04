<style>
    pre {
        overflow-y: auto;
        max-height: 520px;
    }
</style>

# 附加题

## 题目：DCache设计（<font color=green>**+2**</font>分）

### 1. 设计内容及要求

&emsp;&emsp;在SoC工程`miniRV_axi`中，设计实现直接映射方式的数据Cache，即DCache。

&emsp;&emsp;要求及说明：

&emsp;&emsp;（1）完成SoC工程中的DCache模块，即`DCache.v`；

&emsp;&emsp;（2）DCache采用Block Memory作为存储介质，其大小为1KB，块大小为4个32位字；

&emsp;&emsp;（3）DCache对CPU可读可写，故不仅要处理读命中、读缺失，还需处理写命中、写缺失；

&emsp;&emsp;（4）自由选择个人喜好的写策略、替换策略进行实现；

&emsp;&emsp;（5）实现CPU通过Uncached方式访问外设；

&emsp;&emsp;（6）按要求完成实验报告。

### 2. DCache设计说明

#### 2.1 DCache接口信号

&emsp;&emsp;DCache模块的接口信号可分为4组，分别是面向CPU的读接口、面向CPU的写接口、面向总线的读接口、面向总线的写接口，如表4-1所示。

<center>表4-1 DCache模块接口信号</center>
<center>

| 序号 | 名称 | 位宽 | 属性 | 功能描述 |
| :-: | :-: | :-: | :-: | :-: |
| 1 | `cpu_clk` | `1` | 输入 | 时钟信号 |
| 2 | `cpu_rst` | `1` | 输入 | 复位信号（高电平复位） |
| 3 | `data_ren` | `4` | 输入 | 读使能信号（**支持读字、半字、字节**） |
| 4 | `data_addr` | `32` | 输入 | 读/写地址 |
| 5 | `data_valid` | `1` | 输出 | 读数据是否有效/DCache读命中信号 |
| 6 | `data_rdata` | `32` | 输出 | 读数据 |
| 7 | `data_wen` | `4` | 输入 | 写使能信号（**支持写字、半字、字节**） |
| 8 | `data_wdata` | `32` | 输入 | 写数据 |
| 9 | `data_wresp` | `1` | 输出 | 写响应 |
| 10 | `dev_wrdy` | `1` | 输入 | 设备写就绪信号：高电平表示就绪 |
| 11 | `dev_wen` | `4` | 输出 | 写使能信号（**支持写字、半字、字节**） |
| 12 | `dev_waddr` | `32` | 输出 | 向设备发出的写地址 |
| 13 | `dev_wdata` | `32` | 输出 | 向设备发出的写数据 |
| 14 | `dev_rrdy` | `1` | 输入 | 设备读就绪信号：高电平表示就绪 |
| 15 | `dev_ren` | `4` | 输出 | 读使能信号 |
| 16 | `dev_raddr` | `32` | 输出 | 向设备发出的读地址 |
| 17 | `dev_rvalid` | `1` | 输入 | 读设备的数据有效信号 |
| 18 | `dev_rdata` | `128` | 输入 | 从设备读取的数据块 |

</center>

&emsp;&emsp;DCache模块的读接口时序与ICache类似，故此处不再赘述，详见<a href = "../1-theory/#32-icache" target = _blank>实验原理 - 3.2 ICache接口信号</a>中的图2-6和图2-7。特别地，对于读访问操作，<u>DCache与ICache的区别是支持通过4bit的读使能信号`data_ren`实现按字节、半字或字读取的功能</u> —— 使能信号的第x位对应32位存储字的第x个字节。

&emsp;&emsp;DCache模块面向CPU的写接口时序如图4-1所示。

<center><img src="../assets/4-1.png" width = 600></center>
<center>图4-1 DCache面向CPU的写接口时序</center>

!!! info "时序解读 :teacher:"
    - 【*clk0*】CPU写主存时，发出写使能信号`data_wen`、写地址信号`data_addr`和写数据信号`data_wdata`。  
    - 【*clk1*】写使能信号`data_wen` **仅有效一个时钟周期**。  
    - 【*clk3*】DCache在写命中或处理完写缺失后，向CPU发出写响应信号`data_wresp`。  
    - 【*clk4*】`data_wresp`信号 **仅有效一个时钟周期**。当DCache拉低`data_wresp`后，CPU可以发出新的写请求。

&emsp;&emsp;DCache模块面向总线的写接口时序如图4-2所示。

<center><img src="../assets/4-2.png" width = 535></center>
<center>图4-2 DCache面向总线的写接口时序</center>

!!! info "时序解读 :teacher:"
    - 【*clk0*】总线就绪后，拉高`dev_wrdy`信号。**只有当`dev_wrdy`信号有效时，DCache才能发出写请求**。  
    &emsp;&emsp;&emsp;&ensp; 此时，DCache向总线发出写使能信号`dev_wen`、写地址信号`dev_waddr`和写数据信号`dev_wdata`。
    - 【*clk1*】总线模块接收到DCache的写请求后，拉低`dev_wrdy`信号，并开始写主存或写外设。  
    &emsp;&emsp;&emsp;&ensp; 写使能信号`dev_wen` **仅有效一个时钟周期**。  
    - 【*clk3*】总线模块完成写操作后，将`dev_wrdy`信号重新拉高，此时DCache可发出新的写请求。

#### 2.2 Uncached访问

&emsp;&emsp;尽管Cache可以有效提升计算机系统的性能，但数据可能同时在Cache和主存（或外设）之间存在副本，从而造成数据一致性问题。Cache的写策略在一定程度上维护了数据一致性，但在某些场景下（比如外设访问、内存调试等等），我们希望排除Cache带来的数据一致性影响，使得CPU能够直接访问主存或外设的数据，从而保证相关操作的准确性。

&emsp;&emsp;Uncached访问指的是不经过Cache直接访问主存或外设。请在SoC工程中实现CPU通过Uncached方式访问外设。

!!! question "如何区分Uncached访问和Cached访问 :bulb:"
    &emsp;&emsp;在本实验提供的SoC中，主存和外设采用统一编址方式。主存的地址范围是`0x00000000` ~ `0xFFFEFFFF`，外设的地址范围是`0xFFFF0000` ~ `0xFFFFFFFF`。因此，可通过访存地址区分访问方式。

### 3. 操作步骤

&emsp;&emsp;（1）打开SoC工程`miniRV_axi`，去除头文件`defines.vh`前3行代码的注释。去除注释后`defines.vh`的前3行应如下列代码所示：

``` Verilog title="defines.vh" linenums="1"
`define RANDOM_DELAY
`define ENABLE_ICACHE
`define ENABLE_DCACHE
```

&emsp;&emsp;（2）打开`DCache.v`，用下列代码替换掉`DCache.v`中的原始代码；

``` Verilog
`timescale 1ns / 1ps

// `define BLK_LEN  4
// `define BLK_SIZE (`BLK_LEN*32)

module DCache(
    input  wire         cpu_clk,
    input  wire         cpu_rst,        // high active
    // Interface to CPU
    input  wire [ 3:0]  data_ren,       // 来自CPU的读使能信号
    input  wire [31:0]  data_addr,      // 来自CPU的地址（读、写共用）
    output reg          data_valid,     // 输出给CPU的数据有效信号
    output reg  [31:0]  data_rdata,     // 输出给CPU的读数据
    input  wire [ 3:0]  data_wen,       // 来自CPU的写使能信号
    input  wire [31:0]  data_wdata,     // 来自CPU的写数据
    output reg          data_wresp,     // 输出给CPU的写响应（高电平表示DCache已完成写操作）
    // Interface to Write Bus
    input  wire         dev_wrdy,       // 主存的写就绪信号（高电平表示主存可接收DCache的写请求）
    output reg  [ 3:0]  dev_wen,        // 输出给主存的写使能信号
    output reg  [31:0]  dev_waddr,      // 输出给主存的写地址
    output reg  [31:0]  dev_wdata,      // 输出给主存的写数据
    // Interface to Read Bus
    input  wire         dev_rrdy,       // 主存的读就绪信号（高电平表示主存可接收DCache的读请求）
    output reg  [ 3:0]  dev_ren,        // 输出给主存的读使能信号
    output reg  [31:0]  dev_raddr,      // 输出给主存的读地址
    input  wire         dev_rvalid,     // 来自主存的数据有效信号
    input  wire [`BLK_SIZE-1:0] dev_rdata   // 来自主存的读数据
);

    // Peripherals access should be uncached.
    wire uncached = (data_addr[31:16] == 16'hFFFF) & (data_ren != 4'h0 | data_wen != 4'h0) ? 1'b1 : 1'b0;

`ifdef ENABLE_DCACHE    /******** 不要修改此行代码 ********/

    wire [?:0] tag_from_cpu   = /* TODO */;    // 主存地址的TAG
    wire [?:0] offset         = /* TODO */;    // 32位字偏移量
    wire       valid_bit      = /* TODO */;    // Cache行的有效位
    wire [?:0] tag_from_cache = /* TODO */;    // Cache行的TAG

    // TODO: 定义DCache读状态机的状态变量


    wire hit_r = /* TODO */;        // 读命中
    wire hit_w = /* TODO */;        // 写命中
    
    always @(*) begin
        data_valid = hit_r;
        data_rdata = /* TODO: 根据字偏移，选择Cache行中的某个32位字输出数据 */; 
    end

    wire       cache_we     = /* TODO */;     // DCache存储体的写使能信号
    wire [?:0] cache_index  = /* TODO */;     // 主存地址的Cache索引 / DCache存储体的地址
    wire [?:0] cache_line_w = /* TODO */;     // 待写入DCache的Cache行
    wire [?:0] cache_line_r;                  // 从DCache读出的Cache行

    // DCache存储体：Block RAM IP核
    blk_mem_gen_1 U_dsram (
        .clka   (cpu_clk),
        .wea    (cache_we),
        .addra  (cache_index),
        .dina   (cache_line_w),
        .douta  (cache_line_r)
    );

    // TODO: 编写DCache读状态机现态的更新逻辑
    
    
    // TODO: 编写DCache读状态机的状态转移逻辑（注意处理uncached访问）

    
    // TODO: 生成DCache读状态机的输出信号





    ///////////////////////////////////////////////////////////
    // TODO: 定义DCache写状态机的状态变量
    
    
    // TODO: 编写DCache写状态机的现态更新逻辑


    // TODO: 编写DCache写状态机的状态转移逻辑（注意处理uncached访问）


    // TODO: 生成DCache写状态机的输出信号
    

    // TODO: 写命中时，只需修改Cache行中的其中一个字。请在此实现之。
    
    
    /******** 不要修改以下代码 ********/
`else

    localparam R_IDLE  = 2'b00;
    localparam R_STAT0 = 2'b01;
    localparam R_STAT1 = 2'b11;
    reg [1:0] r_state, r_nstat;
    reg [3:0] ren_r;

    always @(posedge cpu_clk or posedge cpu_rst) begin
        r_state <= cpu_rst ? R_IDLE : r_nstat;
    end

    always @(*) begin
        case (r_state)
            R_IDLE:  r_nstat = (|data_ren) ? (dev_rrdy ? R_STAT1 : R_STAT0) : R_IDLE;
            R_STAT0: r_nstat = dev_rrdy ? R_STAT1 : R_STAT0;
            R_STAT1: r_nstat = dev_rvalid ? R_IDLE : R_STAT1;
            default: r_nstat = R_IDLE;
        endcase
    end

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            data_valid <= 1'b0;
            dev_ren    <= 4'h0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    data_valid <= 1'b0;

                    if (|data_ren) begin
                        if (dev_rrdy)
                            dev_ren <= data_ren;
                        else
                            ren_r   <= data_ren;

                        dev_raddr <= data_addr;
                    end else
                        dev_ren   <= 4'h0;
                end
                R_STAT0: begin
                    dev_ren    <= dev_rrdy ? ren_r : 4'h0;
                end   
                R_STAT1: begin
                    dev_ren    <= 4'h0;
                    data_valid <= dev_rvalid ? 1'b1 : 1'b0;
                    data_rdata <= dev_rvalid ? dev_rdata : 32'h0;
                end
                default: begin
                    data_valid <= 1'b0;
                    dev_ren    <= 4'h0;
                end 
            endcase
        end
    end

    localparam W_IDLE  = 2'b00;
    localparam W_STAT0 = 2'b01;
    localparam W_STAT1 = 2'b11;
    reg  [1:0] w_state, w_nstat;
    reg  [3:0] wen_r;
    wire       wr_resp = dev_wrdy & (dev_wen == 4'h0) ? 1'b1 : 1'b0;

    always @(posedge cpu_clk or posedge cpu_rst) begin
        w_state <= cpu_rst ? W_IDLE : w_nstat;
    end

    always @(*) begin
        case (w_state)
            W_IDLE:  w_nstat = (|data_wen) ? (dev_wrdy ? W_STAT1 : W_STAT0) : W_IDLE;
            W_STAT0: w_nstat = dev_wrdy ? W_STAT1 : W_STAT0;
            W_STAT1: w_nstat = wr_resp ? W_IDLE : W_STAT1;
            default: w_nstat = W_IDLE;
        endcase
    end

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            data_wresp <= 1'b0;
            dev_wen    <= 4'h0;
        end else begin
            case (w_state)
                W_IDLE: begin
                    data_wresp <= 1'b0;

                    if (|data_wen) begin
                        if (dev_wrdy)
                            dev_wen <= data_wen;
                        else
                            wen_r   <= data_wen;
                        
                        dev_waddr  <= data_addr;
                        dev_wdata  <= data_wdata;
                    end else
                        dev_wen    <= 4'h0;
                end
                W_STAT0: begin
                    dev_wen    <= dev_wrdy ? wen_r : 4'h0;
                end
                W_STAT1: begin
                    dev_wen    <= 4'h0;
                    data_wresp <= wr_resp ? 1'b1 : 1'b0;
                end
                default: begin
                    data_wresp <= 1'b0;
                    dev_wen    <= 4'h0;
                end
            endcase
        end
    end

`endif

endmodule
```

&emsp;&emsp;（3）独立完成DCache模块的设计（`DCache.v`）；

&emsp;&emsp;（4）运行功能仿真并根据仿真波形完成调试；

&emsp;&emsp;（5）记录实验结果并按要求完成实验报告。
