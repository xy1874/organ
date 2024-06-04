<style>
    pre {
        overflow-y: auto;
        max-height: 520px;
    }
</style>

# 实验步骤

## 1. 操作步骤

&emsp;&emsp;（1）阅读实验指导书或理论课PPT，理解直接映射Cache的结构及工作原理；

&emsp;&emsp;（2）在Vivado中打开SoC工程`miniRV_axi`，然后打开头文件`defines.vh`，将前2行代码的注释去除后保存文件（若完成附加题，则将前3行代码的注释去掉）。去除注释后`defines.vh`的前3行应如下列代码所示：

``` Verilog title="defines.vh" linenums="1"
`define RANDOM_DELAY
`define ENABLE_ICACHE
// `define ENABLE_DCACHE
```

&emsp;&emsp;（3）打开`ICache.v`，点击下列代码块右上角的复制按钮，然后在`ICache.v`中按下快捷键 ++ctrl+a++ 全选代码，再按下 ++ctrl+v++ 粘贴代码，最后按下 ++ctrl+s++ 保存文件；

``` Verilog
`timescale 1ns / 1ps

// `define BLK_LEN  4
// `define BLK_SIZE (`BLK_LEN*32)

module ICache(
    input  wire         cpu_clk,
    input  wire         cpu_rst,        // high active
    // Interface to CPU
    input  wire         inst_rreq,      // 来自CPU的取指请求
    input  wire [31:0]  inst_addr,      // 来自CPU的取指地址
    output reg          inst_valid,     // 输出给CPU的指令有效信号（读指令命中）
    output reg  [31:0]  inst_out,       // 输出给CPU的指令
    // Interface to Read Bus
    input  wire         mem_rrdy,       // 主存就绪信号（高电平表示主存可接收ICache的读请求）
    output reg  [ 3:0]  mem_ren,        // 输出给主存的读使能信号
    output reg  [31:0]  mem_raddr,      // 输出给主存的读地址
    input  wire         mem_rvalid,     // 来自主存的数据有效信号
    input  wire [`BLK_SIZE-1:0] mem_rdata   // 来自主存的读数据
);

`ifdef ENABLE_ICACHE    /******** 不要修改此行代码 ********/

    wire [?:0] tag_from_cpu   = /* TODO */;    // 主存地址的TAG
    wire [?:0] offset         = /* TODO */;    // 32位字偏移量
    wire       valid_bit      = /* TODO */;    // Cache行的有效位
    wire [?:0] tag_from_cache = /* TODO */;    // Cache行的TAG

    // TODO: 定义ICache状态机的状态变量


    wire hit = /* TODO */;

    always @(*) begin
        inst_valid = hit;
        inst_out   = /* TODO: 根据字偏移，选择Cache行中的某个32位字输出指令 */;
    end

    wire       cache_we     = /* TODO */;     // ICache存储体的写使能信号
    wire [?:0] cache_index  = /* TODO */;     // 主存地址的Cache索引 / ICache存储体的地址
    wire [?:0] cache_line_w = /* TODO */;     // 待写入ICache的Cache行
    wire [?:0] cache_line_r;                  // 从ICache读出的Cache行

    // ICache存储体：Block MEM IP核
    blk_mem_gen_1 U_isram (
        .clka   (cpu_clk),
        .wea    (cache_we),
        .addra  (cache_index),
        .dina   (cache_line_w),
        .douta  (cache_line_r)
    );

    // TODO: 编写状态机现态的更新逻辑
    
    
    // TODO: 编写状态机的状态转移逻辑
    

    // TODO: 生成状态机的输出信号


    /******** 不要修改以下代码 ********/
`else

    localparam IDLE  = 2'b00;
    localparam STAT0 = 2'b01;
    localparam STAT1 = 2'b11;
    reg [1:0] state, nstat;

    always @(posedge cpu_clk or posedge cpu_rst) begin
        state <= cpu_rst ? IDLE : nstat;
    end

    always @(*) begin
        case (state)
            IDLE:    nstat = inst_rreq ? (mem_rrdy ? STAT1 : STAT0) : IDLE;
            STAT0:   nstat = mem_rrdy ? STAT1 : STAT0;
            STAT1:   nstat = mem_rvalid ? IDLE : STAT1;
            default: nstat = IDLE;
        endcase
    end

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            inst_valid <= 1'b0;
            mem_ren    <= 4'h0;
        end else begin
            case (state)
                IDLE: begin
                    inst_valid <= 1'b0;
                    mem_ren    <= (inst_rreq & mem_rrdy) ? 4'hF : 4'h0;
                    mem_raddr  <= inst_rreq ? inst_addr : 32'h0;
                end
                STAT0: begin
                    mem_ren    <= mem_rrdy ? 4'hF : 4'h0;
                end
                STAT1: begin
                    mem_ren    <= 4'h0;
                    inst_valid <= mem_rvalid ? 1'b1 : 1'b0;
                    inst_out   <= mem_rvalid ? mem_rdata[31:0] : 32'h0;
                end
                default: begin
                    inst_valid <= 1'b0;
                    mem_ren    <= 4'h0;
                end
            endcase
        end
    end

`endif

endmodule
```

&emsp;&emsp;（3）独立完成ICache模块的设计（`ICache.v`）；  

!!! danger "注意事项 :warning:"
    &emsp;&emsp;若只完成必做题，除了ICache模块（`ICache.v`），不要修改SoC工程的其他任何文件！

    &emsp;&emsp;若完成必做题和附加题，除了ICache模块（`ICache.v`）和DCache模块（`DCache.v`），不要修改SoC工程的其他任何文件！

&emsp;&emsp;（4）参照下一节的仿真调试说明，运行功能仿真并根据仿真波形完成调试；

&emsp;&emsp;（5）测试并比较无ICache和有ICache时，SoC运行测试程序的时间，并记录ICache命中率；

!!! tip "关闭ICache的方法 :bulb:"
    &emsp;&emsp;将头文件`defines.vh`第2行代码的宏定义“`#define ENABLE_ICACHE`”注释掉即可。

&emsp;&emsp;（6）反思实验过程，总结收获并整理遇到的问题及解决方案，撰写实验报告。



## 2. 仿真调试说明

### 2.1 顶层模块设置

&emsp;&emsp;在`Sources`窗口下找到`Simulation Souces`，展开`sim_1`文件夹，将其内的`soc_simu.v`设置成仿真的顶层文件，如图3-1所示。

<center><img src="../assets/3-1.png" width = 400></center>
<center>图3-1 更改仿真的顶层模块为`soc_simu.v`</center>

!!! note "关于使用Vivado 2018.3以上的版本 :warning:"
    &emsp;&emsp;如果使用Vivado <font color=#3498DB><u>**2019**</u></font>，需将`soc_simu.v`第25行修改为：

    ``` Verilog linenums="1"
    `define MEM_INST DUT.U_mem.U_bram.inst.axi_mem_module.blk_mem_gen_v8_4_4_inst.memory
    ```

    &emsp;&emsp;如果使用Vivado <font color=#3498DB><u>**2022**</u></font>，需将`soc_simu.v`第25行修改为：

    ``` Verilog linenums="1"
    `define MEM_INST DUT.U_mem.U_bram.inst.axi_mem_module.blk_mem_gen_v8_4_5_inst.memory
    ```

    &emsp;&emsp;如果使用Vivado <font color=#3498DB><u>**2023**</u></font>，需将`soc_simu.v`第25行修改为：

    ``` Verilog linenums="1"
    `define MEM_INST DUT.U_mem.U_bram.inst.axi_mem_module.blk_mem_gen_v8_4_7_inst.memory
    ```

### 2.2 测试程序设置

&emsp;&emsp;在Sources窗口下依次找到并展开`soc.v`和`axiram_wrap.v`模块，双击打开存储主存数据的`blk_mem_gen_0`IP核，将`Other Options`下的初始文件更换成`start.dump.coe`，如图3-2所示。

<center><img src="../assets/3-2.png" width = 100%></center>
<center>图3-2 打开Block Memory IP核的配置窗口，更改测试程序</center>

&emsp;&emsp;在图3-2中点击`OK`按钮，并在随后打开的`Generate Output Products`窗口中点击`Skip`。

!!! question "咦，IP核被锁住了，无法操作？ :lock:"
    &emsp;&emsp;本实验提供的模板工程是基于Vivado 2018.3构建的。使用更高版本的Vivado打开模板工程时，工程中的IP核将被锁住，无法直接修改。为此，我们需要升级工程中的IP核。

    &emsp;&emsp;具体操作是，在任意一个被锁住的IP核上右键，点击“Report IP Status”，然后在最下方的IP Status窗口中，点击Upgrade Selected按钮，随后在弹出的对话框中点击OK按钮，即可一键升级所有IP核，如图3-3所示。

    <center><img src="../assets/3-3.png" width = 100%></center>
    <center>图3-3 一键升级所有IP核</center>

    &emsp;&emsp;若升级IP核失败，请检查Vivado工程所在的路径是否有中文、空格，或路径是否过长。


### 2.3 运行功能仿真

&emsp;&emsp;完成上述两处修改后，运行功能仿真，并点击工具栏的“Run All”按钮，如图3-4所示。

<center><img src="../../lab2/assets/3-2.png" width = 380></center>
<center>图3-4 点击“Run All”按钮以运行测试程序</center>

&emsp;&emsp;**TestBench将自动运行直到通过测试或发现错误**。<font color=red><u>如果波形窗口没有任何信号和波形，请首先确保当前查看的是不是`soc_simu_behav.wcfg`的波形配置文件</u></font>，如图3-5所示。

<center><img src="../assets/3-5.png" width = 480></center>
<center>图3-5 仿真波形配置文件</center>

&emsp;&emsp;在图3-5所示的波形配置文件中，`ICache_Interface`下的信号是ICache模块的接口信号，`hit`信号是ICache内部的命中信号，而`ifetch_cnt`则是CPU的取指计数器。

&emsp;&emsp;仿真调试时，请根据实际需要自行添加ICache模块内部的信号到波形窗口中。

&emsp;&emsp;<font color=red><u>若TestBench运行数秒后，仿真波形中的信号仍未有变化，说明CPU未能从ICache中取出指令，此时应当仔细检查ICache逻辑</u></font>。

&emsp;&emsp;仿真时，TestBench将在控制台打印每次取指或访存的调试辅助信息，如图3-6所示。

<center><img src="../assets/3-6.png" width = 350></center>
<center>图3-6 TestBench将在控制台输出调试辅助信息</center>

&emsp;&emsp;成功通过测试程序后，TestBench将在控制台打印测试程序的仿真运行总时间、总取指数量、ICache命中率等信息，如图3-7所示。

<center><img src="../assets/3-7.png" width = 450></center>
<center>图3-7 通过测试时，控制台的提示信息</center>

&emsp;&emsp;若仿真过程中出现错误，TestBench将在控制台给出相应的错误提示，如图3-8所示。

<center><img src="../assets/3-8.png" width = 250></center>
<center>图3-8 测试出错时，控制台的错误提示信息</center>
