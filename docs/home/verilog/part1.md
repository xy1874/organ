# 模块的基本结构

### 模块声明

```verilog
 1|module module_name(port_list);      // 模块名（端口声明列表）
```

### 端口定义

```verilog
 1|input  [WIDTH-1:0] sw_i;            // 输入声明
 2|output [WIDTH-1:0] led_o;           // 输出声明
 3|……
```

### 数据类型说明

```verilog
 1|reg  [WIDTH-1:0] data_r;            // 寄存器类型声明
 2|wire [WIDTH-1:0] cpu2ram;           // 线网类型声明
 3|parameter  WIDTH = 16'd32;          // 此处声明的WID参数可在实例化IP核时传入其他值
 4|localparam BASE  = 32'hFFFFF000;    // 此处声明的ABC是局部参数，不可在实例化IP时传入
 5|……
```

### 功能描述

```verilog
 1|assign a = b + c;
 2|……
 3|always @ (posedge clk_i or negedge resetn_i)
 4|    if (!resetn_i) begin
 5|        // reset signals
 6|    end else begin
 7|        // other operations
 8|    end
 9|endmodule
```

### 例：2路多选器

```verilog
 1|// 2选1多路选择器
 2|module mux2 (
 3|    input  wire [15:0]  a_i,
 4|    input  wire [15:0]  b_i,
 5|    input  wire         sel_i,
 6|    output reg  [15:0]  c_o
 7|);
 8|    
 9|    always @ (*) begin
10|        if (!sel_i) begin
11|            c_o = a_i;   
12|        end else begin
13|            c_o = b_i;
14|        end
15|    end
16|
17|endmodule
```

- “模块名”是模块唯一的标识符，区分大小写。
- “端口列表”是由模块各个输入、输出和双向端口组成的列表（input、output、inout）。
- 端口用来与其它模块进行连接，括号中的列表以“,”来区分，列表的顺序没有规定，先后自由。

- 模块中用到的所有信号都必须进行数据类型的定义。
- 声明变量的数据类型后，不能再进行更改。
- 在VerilogHDL中只要在使用前声明即可。
- 声明后的变量、参数不能再次重新声明。
- 声明后的数据使用时的配对数据必须和声明的数据类型一致。
