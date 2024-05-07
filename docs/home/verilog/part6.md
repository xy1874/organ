# 条件语句和循环语句

- 条件语句和循环语句都必须在过程块中使用


- 条件语句
  - `if`语句、`case`语句

- 循环语句
  - `forever`语句、`repeat`语句、`while`语句、`for`语句

## `if`语句

- 基本语法：

```Verilog
 1|if (/*condition*/)
 2|    /* operation1 */
 3|else
 4|    /* operation2 */
```

!!! example "代码实例 :chestnut:"
    ```Verilog
     1|module max (
     2|    input  wire [7:0] a_i,
     3|    input  wire [7:0] b_i,
     4|    output reg  [7:0] max_o
     5|);
     6|
     7|    always@(*) begin
     8|        if (a_i > b_i) begin
     9|            max_o = a_i;
    10|        end else begin
    11|            max_o = b_i;
    12|        end
    13|    end
    14|
    15|endmodule
    ```

- 即使用不到`else`分支，语句中`else`分支也最好加上，否则电路有可能生成不稳定的电路，造成结果的错误。


## 条件语句-`case`语句

- 基本语法：

```Verilog
 1|case (/*condition*/)
 2|    `VAL1:   /* operation1 */
 3|    `VAL2:   /* operation2 */
 4|    `VAL3:   /* operation3 */
 5|    default: /* default operation */
 6|endcase
```

!!! example "代码实例 :chestnut:"
    ```Verilog
     1|module mux4 (
     2|    input  wire [1:0] sel_i,
     3|    input  wire [7:0] d0_i,
     4|    input  wire [7:0] d1_i,
     5|    input  wire [7:0] d2_i,
     6|    input  wire [7:0] d3_i,
     7|    output reg  [7:0] d_o
     8|);
     9|
    10|    always@(*) begin
    11|        case (sel_i)
    12|            2'b00:   begin d_o = d0_i; end
    13|            2'b01:   begin d_o = d1_i; end
    14|            2'b10:   begin d_o = d2_i; end
    15|            2'b11:   begin d_o = d3_i; end
    16|            default: begin d_o = 8'h0; end
    17|        endcase
    18|    end
    19|
    20|endmodule
    ```

- `case`语句的所有表达式值的位宽必须相等

- 语句中`default`一般不要缺省。在`always`块内，如果给定条件下变量没有赋值，这个变量将保持原值（生成一个锁存器）

- 分支表达式中可以存在不定值<font color="red">**X**</font>和高阻值<font color="purple">**Z**</font>，如`2'b0X`，或`2'b0Z`。

## 条件语句if与case的区别

- `if`生成的电路是串行，是有优先级的编码逻辑；

- `case`生成的电路是并行的，各种判定情况的优先级相同。

- 因此，`if`生成的电路延时较大，占用硬件资源少；`case`生成的电路延时短，但占用硬件资源多。


## 循环语句

- Verilog的循环语句是依靠电路的重复生成实现的。

- 4种循环语句：  
    - `for` 循环：执行给定的循环次数；
    - `while` 循环：执行语句直到某个条件不满足；
    - `repeat` 循环：连续执行语句N次；
    - `forever` 循环：连续执行某条语句。

- `for`、`while`是可综合的，但循环的次数需要在编译之前就确定，动态改变循环次数的语句则是不可综合的

- `repeat`语句在有些工具中可综合，有些不可综合

- `forever`语句是不可综合的，常用于产生各类仿真激励


