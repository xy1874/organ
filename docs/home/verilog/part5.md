 

# 赋值语句和块语句

- 在Verilog中，变量是不能随意赋值的，需要使用连续赋值语句和过程赋值语句。

- assign称为连续赋值，对应于线网类型变量wire；

- initial或always称为过程赋值，对应于寄存器类型变量reg。


## 1. 连续赋值语句

- 语法格式：`assign <线网型变量名> = <赋值表达式>;` 

- 示例：

```Verilog
 1|    wire a;
 2|    assign a = 1’b1;
 3|    // 有时出于简便，也可以写成下面的语句 —— 等价于“wire b; assign b = ~a;”
 4|    wire b = ~a;
```

- 左侧数据类型必须是线网型数据（`wire`）。

- 不能放在过程块（`initial`、`always`）之内。

- 对应到实际电路，就是<u>用导线将等号两侧的信号直接连接起来</u>，属于组合逻辑电路。
  
    - 等号右端赋值表达式的值会持续对被赋值变量产生连续驱动，而且只要等号右端赋值表达式的值改变，左端被赋值变量的值就会立即改变。
  
    - 从语句的角度理解，就是所有右值都是敏感信号，右侧任何信号的变化都会激活该语句，使其被立即执行一次。

- 各个assign赋值语句之间是并行的。

- 每条assign赋值语句相当于一个逻辑单元，等价于门级描述。

<center><img src="../part5.assets/assign.png" style="zoom:55%;"/></center>



## 2. 过程块

- 过程块是行为模型的基础，主要有`always`块和`initial`块两种。

### 2.1 `always`块

- `always`块的格式：

```verilog
 1|    always @（<敏感信号列表>）begin
 2|        // 过程赋值
 3|        // if-else、case选择语句
 4|        // for、while等循环块
 5|    end
```

- `always`语句都有触发条件 —— 触发条件被写在敏感信号列表中。只有当触发条件满足时（敏感信号发生变化），“`begin`-`end`”内的语句才能被执行。

- 敏感信号分两种：电平敏感、边沿敏感。由此引发的电路执行分别称为电平触发和边沿触发。

- 电平触发的`always`块通常用于描述组合逻辑和带锁存器的组合逻辑。

- 边沿触发的`always`块通常用于描述时序逻辑。
    
    - 对于边沿敏感的信号，用关键字`posedge`和`negedge`来限定信号敏感边沿。

- 敏感信号列表中的多个信号，用关键字`or`连接。

- `always`块的特点：

    - 循环多次执行；

    - `always`语句通常带触发条件，满足触发条件才执行；

    - 一个模块中有多个`always`块时，各`always`块可以并行工作。

- `always`块代码实例：

```verilog
 1|module reg_adder (
 2|    input  wire          clk_i,
 3|    input  wire [2:0]    a_i,
 4|    input  wire [2:0]    b_i,
 5|    output reg  [3:0]    c_o
 6|);
 7|
 8|    reg [3:0] sum;
 9|    
10|    // 若a或b发生任何变化，执行begin-end中的语句块
11|    always @(a_i or b_i) begin
12|	       sum = a_i + b_i;
13|    end
14|    
15|    // 在clk_i下降沿时，执行begin-end中的语句块
16|    always @(negedge clk_i) begin
17|		   c_o <= sum;
18|    end
19|
20|endmodule
```

### 2.2 `initial`块

- `initial`块的格式：

```verilog
 1|    initial begin
 2|        语句1;
 3|        语句2;
 4|        ……
 5|    end
```

- 与`always`块不同，`inital`块没有触发条件。

- `initial`块只能执行一次。

- `initial`块通常用于仿真（Simulation）。

- `initial`块代码实例：

```verilog
 1|module reg_adder_sim ();
 2|
 3|    reg  clk;
 4|    reg  [2:0] a, b;
 5|    wire [3:0] c;
 6|
 7|    // begin-end中的语句顺序执行
 8|    initial begin
 9|        #20 begin a = 0; b = 0; end    
10|        #20 begin a = 0; b = 1; end   
11|        #20 begin a = 1; b = 0; end    
12|        #20 begin a = 1; b = 1; end    
13|    end
14|
15|    ……
16|
17|    reg_adder DUT (clk, a, b, c);
18|
19|endmodule
```



## 3. 过程赋值语句

- 在`always`/`initial`块中的赋值语句称为过程赋值语句；

- `always`块的执行条件是敏感信号列表里的信号发生变化。

- `initial`块中的语句只会被执行一次。

- 过程赋值语句左侧的类型必须是`reg`类型的变量。

    - `reg`类型的变量不一定就是寄存器，<u>要看过程块本身描述的是时序电路还是组合电路</u>。

### 3.1 阻塞/非阻塞赋值

- 过程赋值分为阻塞赋值（`=`）和非阻塞赋值（`<=`）。

    - 阻塞赋值：赋值完成后才能执行下条语句；被赋值变量的值在赋值语句完成后立马改变。

    - 非阻塞赋值：所在语句块结束时才进行赋值；被赋值变量的值并非立即改变。

    - 非阻塞赋值是比较常用的赋值方式，特别是在编写可综合模块时。

<center><img src="../part5.assets/clip_image004.jpg" style="zoom:100%;"/></center>

### 3.2 区分阻塞/非阻塞赋值

- 对于 **时序逻辑**：

&emsp;&emsp;一定用非阻塞赋值“`<=`” —— 只要看到敏感列表有`posedge`或者`negedge`就用“`<=`”。

- 对于 **组合逻辑**：

&emsp;&emsp;一定用阻塞赋值“`=`” —— 只要敏感列表没有`posedge`或`negedge`就用“`=`”。

- 一个`always`块内部只能出现一种赋值方式，即“`<=`”和“`=`”不能同时出现。

- 请通过下列代码及其生成的电路，体会两种赋值方式的区别。

<img src = "../part5.assets/block_nonblock.png">


## 4. 连续赋值与过程赋值的比较

<center>

| | 过程赋值 | 连续赋值 |
| :-: | :- | :- |
| assign | 无assign  （过程性连续赋值除外） | 有assign |
| 符号 | 使用“=”，“<=”  | 只使用“=” |
| 位置 | 在always语句或initial语句中均可出现 | 不可出现于always语句和initial语句 |
| 执行条件 | 与周围其他语句有关 | 等号右端操作数的值发生变化时 |
| 用途     | 驱动寄存器 | 驱动线网 |

</center>
