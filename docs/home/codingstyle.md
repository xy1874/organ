## 1. 命名规范

### 1.1 文件命名规范

- 仿真文件应使用后缀“_sim”，如modulename_sim；

- 测试文件应使用后缀“_tb”，如modulename_tb。

### 1.2 模块命名规范

- 一个文件只定义一个module；

- module名应与文件名一致；

- module名用小写英文表示。

### 1.3 信号命名规范

- 用小写字母定义wire、reg和input、inout、output信号；

- 用大写字母定义parameter、localparam和宏定义；

- 信号名应反映信号的含义/用途，不建议使用单个字母命名；

- 变量名若含有多个单词，用下划线分开，如ram_addr；

- 输入信号应使用后缀“_i”，如addr_i；

- 输出信号应使用后缀“_o”，如data_o；

- 时钟信号应使用前缀“clk”，如clk_i；

- 复位信号应使用前缀“rst”，如rst_n_i；

- 低电平有效的信号应使用后缀“_n”，如cs_n；

- 使用降序排列定义向量有效位顺序，最低位为0。

## 2. 代码编写规范
	
### 2.1 模块定义规范

- 每个模块加timescale，Vivado默认为“`timescale 1ns / 1ps”；

- 一般可采用如图1、图2所示的两种写法来定义模块。建议使用如图2所示的写法。

``` Verilog
 1|module some_module (clk_i, rst_n_i, sel_i, addr_i, data_o);
 2|
 3|    input               clk_i;
 4|    input               rst_n_i;
 5|
 6|    input       [1:0]   sel_i;
 7|    input       [7:0]   addr_i;
 8|    output reg  [7:0]   data_o;
 9|
10|    // 模块代码
11|    ......
12|
13|endmodule
```
<center>图1 模块定义写法1</center>

``` Verilog
 1|module some_module (
 2|    input               clk_i,
 3|    input               rst_n_i,
 4|
 5|    input       [1:0]   sel_i,
 6|    input       [7:0]   addr_i,
 7|    output reg  [7:0]   data_o
 8|);
 9|
10|    // 模块代码
11|    ......
12|
13|endmodule
```
<center>图2 模块定义写法2</center>

### 2.2 参数规范

- 不需在模块实例化时设置的参数，应将其定义为局部参数（localparam）；

- 全局参数建议放在I/O端口前面，如图3所示。

``` Verilog
1|module some_module #(
2|    parameter PARAM1 = 8,
3|    parameter PARAM2 = 2
4|)(
5|    input               clk_i,
6|    input               rst_n_i,
7|    ......
8|);
```
<center>图3 全局参数规范</center>

### 2.3 模块实例化规范

- 模块实例应用U_xx_x表示（多次例化用序号0、1、2等表示）；

- 一般可采用如图4、图5所示的两种写法来实例化模块。建议使用如图5所示的写法。

``` Verilog
1|    some_module U_some_module_0 #(
2|        clk_fpga,
3|        rst_fpga_n,
4|        ......
5|    );
```
<center>图4 模块实例化写法1</center>

``` Verilog
1|    some_module U_some_module_0 #(
2|        .clk_i      (clk_fpga),
3|        .rst_n_i    (rst_fpga_n),
4|        ......
5|    );
```
<center>图5 模块实例化写法2</center>

### 2.4 通用规范

- 尽量采用参数化设计；

- 所有的if语句应有与之对应的else；

- case语句应考虑default情况；

- if语句尽量不要嵌套太多；

- if-else嵌套时使用图6所示的方式，尽量不使用图7所示的方式。

``` Verilog
1|    if (...) begin
2|        ...
3|    end else if (...) begin
4|        ...
5|    end else begin
6|        ...
7|    end
```
<center>图6 推荐的if-else嵌套方式</center>

``` Verilog
1|    if (...) begin
2|        if (...)
3|            ...
4|        else
5|            ...
6|    end else begin
7|        ...
8|    end
```
<center>图7 不推荐的if-else嵌套方式</center>

- 在RTL级代码中不能含有initial结构，也不可对任何信号进行初始化赋值。若需要初始化，应采用复位的方式；

- 尽量不产生未连接的端口；

- 数据位宽要匹配；

- 顶层模块的输出信号必须被寄存；

- 常量应标注其位宽，如1’b0；

- 不要使用include、wait、forever、repeat、while等语句；

- 如非必要，不使用integer类型；

- 尽量不使用复杂的表达式，可以使用三目运算符“?:”。

### 2.5 组合逻辑规范

- 尽量不使用always语句，除非需要使用case语句；

### 2.6 时序逻辑规范

- 采用同步设计，避免使用异步逻辑（全局信号复位除外）；

- 同步时序逻辑的always块中有且只有一个时钟信号，并且在同一个沿动作（如上升沿）；

- 在时序always块的敏感信号列表中必须都是沿触发，不允许出现电平触发；

- 敏感信号列表中不允许出现表达式；

- 除异步复位之外，敏感信号列表中不允许同时出现posedge和negedge；

- 时序逻辑语句块中统一使用非阻塞型赋值；

- 建议一个always块只对一个变量赋值；

- 建议多使用中间变量。
