# 宏定义和参数

## 宏定义 

### 1. ``` `define```语句

- ``define`语句用于指定某个标识符来代表一个数字或字符串，如：

``` Verilog
 1|`define WIDTH 8
 2|
 3|module some_module(...);
 4|    reg [`WIDTH-1 : 0] cnt;   // 等同于: reg [7:0] cnt;
 5|endmodule
```

### 2. ``` `ifdef - `else - `endif```语句

- Verilog中的``` `ifdef - `else - `endif```语句与C/C++中的```#ifdef-#else-#endif```类似，起条件综合的作用，如：

``` Verilog
 1|`ifdef DEBUG
 2|    // 若定义了DEBUG，则此处的语句将会被综合
 3|`else
 4|    // 若未定义DEBUG，则此处的语句将会被综合
 5|`endif
 6|
 7|`ifndef DEBUG
 8|    // 若未定义DEBUG，则此处的语句将会被综合
 9|`else
10|    // 若定义了DEBUG，则此处的语句将会被综合
11|`endif
```

## 参数

- Verilog的参数分为局部参数和全局参数2种。

- 全局参数既可以在模块内部使用，也可以在实例化模块时修改全局参数。全局参数用关键字```parameter```定义。通常建议将全局参数定义在模块的输入/输出信号列表前面，如：

``` Verilog
 1|module some_module #(
 2|    parameter PARAM1 = 8,
 3|    parameter PARAM2 = 2
 4|)(
 5|    input               clk_i,
 6|    input               rstn_i,
 7|    ......
 8|);
 9|    ......
10|endmodule
```

- 在实例化上述模块时，可修改`PARAM1`和`PARAM2`，如：

``` Verilog
 1|some_module #(
 2|    .PARAM1      (16),
 3|    .PARAM2      (4)
 4|) U_smodule_0 (
 5|    .clk_i       (clk),
 6|    .rstn_i      (rst_n),
 7|    ......
 8|);
```

- 局部参数只能在模块内部使用，不可在实例化模块时修改局部参数。

- 不需在模块实例化时设置的参数，应将其定义为局部参数。局部参数用关键字```localparam```定义，如：

``` Verilog
 1|module some_module (...);
 2|    localparam IDLE   = 3'h1;
 3|    localparam STAT0  = 3'h2;
 4|endmodule
```
