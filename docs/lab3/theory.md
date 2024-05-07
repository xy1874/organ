# 实验原理

&emsp;&emsp;在CPU的数据通路中，运算器用于实现指令执行所需的数据运算，包括算术运算、移位运算、逻辑运算等等。整型数据的运算通常由ALU（Arithmetic Logic Unit，算术逻辑单元）完成，而浮点数据的运算则由FPU（Floating Point Unit）完成。在现代处理器中，FPU内部往往具有专用的控制电路、译码电路和浮点寄存器等，能够执行浮点指令。

## 1. IEEE754浮点数格式

&emsp;&emsp;<a href="https://ieeexplore.ieee.org/document/8766229" target="_blank">IEEE754-2019标准</a>中定义了16位的半精度、32位的单精度、64位的双精度以及更高精度的浮点数格式。这些浮点数的格式具有相同的模式，如图2-1所示。

<center><img src="../assets/2-1.png" width = 550></center>
<center>图2-1 IEEE754浮点数通用格式</center>

&emsp;&emsp;图2-1中，各参数的含义如表2-1所示。

<center>表2-1 IEEE754浮点数参数释义</center>
<center><img src="../assets/t2-1.png" width = auto></center>

&emsp;&emsp;本实验只涉及32位的单精度浮点数。

&emsp;&emsp;由表2-1可知，32位单精度浮点数具有1bit符号（$Sign$）、8bit阶码（$Exponent$）和23bit尾数（$Mantissa$），其能够表示的数如表2-2所示。

<center>表2-2 32位单精度浮点数表示的数据</center>
<center>

| $Exponent$ | $Mantissa$ | 表示的数据 | 换算方法 |
| :-: | :-: | :-: | :-: |
| `8'h0` | `23'h0` | $\pm 0$ | - |
| `8'h0` | 除`23'h0`外 | 非规格化数 | $(-1)^S \cdot (Mantissa)_2 \cdot 2^{-126}$ |
| `8'h1` ~ `8'hFE` | 任意 | 规格化数 | $(-1)^S \cdot (\{1, Mantissa\})_2 \cdot 2^{Exponent-127}$  |
| `8'hFF` | `23'h0` | $\pm Inf$ | $\pm \infty$ |
| `8'hFF` | 除`23'h0`外 | $NaN$ | $N$ot $a$ $N$umber |

</center>

!!! info "补充说明 :book:"
    &emsp;&emsp;在表2-2中，$\{\}$是位拼接符，例如$\{$`1'b1`$,$ `3'b010`$\}$ == `4'b1010`。



## 2. IEEE754浮点数加减法

&emsp;&emsp;IEEE754浮点数加减法运算的基本步骤为：求阶差、对阶、尾数运算、规格化。

&emsp;&emsp;根据运算时采用的编码是补码还是原码，可将浮点数加减法分成两种。

### 2.1 基于补码运算的浮点加减法

&emsp;&emsp;与原码相比，补码最大的优点是可以将加减法统一转换成加法，因此补码运算非常适合使用硬件实现；其缺点是不如原码直观。

&emsp;&emsp;在IEEE754标准中，阶码和尾数分别采用移码和原码的编码方式。因此，本方法需在浮点运算基本步骤之上，额外增加编码转换的操作。

&emsp;&emsp;设有被加/减数$x$，加/减数$y$，运算结果为$z$，且：  
<center>$x = (-1)^{S_x} \cdot M_x \cdot 2^{E_x-127}$ $\Leftrightarrow$ $\{S_x, E_x, M_x\}$，</center>  
<center>$y = (-1)^{S_y} \cdot M_y \cdot 2^{E_y-127}$ $\Leftrightarrow$ $\{S_y, E_y, M_y\}$，</center>  
<center>$z = (-1)^{S_z} \cdot M_z \cdot 2^{E_z-127}$ $\Leftrightarrow$ $\{S_z, E_z, M_z\}$，</center>  
&emsp;&emsp;若$x$/$y$/$z$是规格化数，则尾数$M_{x/y/z} = \{1, (x/y/z)[22:0]\}$；若$x$/$y$/$z$是非规格化数，则尾数$M_{x/y/z} = (x/y/z)[22:0]$。

!!! info "符号说明 :scroll:"
    &emsp;&emsp;$S_{x/y/z}$、$E_{x/y/z}$、$M_{x/y/z}$分别表示$x$/$y$/$z$的符号、阶码、尾数。

&emsp;&emsp;基于补码运算的浮点加减法步骤为：

&emsp;&emsp;（1）**求补码**：阶码：<u>不妨设$y$的阶码更小</u>，则求$[-E_y]_补$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;尾数：求$x$和$y$的尾数的补码，注意要设置双符号位；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;对于$x$，求尾数的补码$[M_x]_补$ = {$S_x$, $[\{S_x, M_x\}]_补$}；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;对于$y$，若是加法运算，则求$[M_y]_补$ = {$S_y$, $[\{S_y, M_y\}]_补$}；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;若是减法运算，则求$[-M_y]_补$ = {$!S_y$, $[\{!S_y, M_y\}]_补$}；  

&emsp;&emsp;（2）**求阶差**：$\Delta E = [E_x]_补 + [-E_y]_补$；

&emsp;&emsp;（3）**对阶**：小阶对大阶。若是加法运算，令$[M_y]_补$<u>算术右移</u>$\Delta E$位，得到$[{M_y}']_补$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;若是减法运算，令$[-M_y]_补$<u>算术右移</u>$\Delta E$位，得到$[{M_y}']_补$；

&emsp;&emsp;（4）**尾数运算**：计算$Sum = [M_x]_补 + [{M_y}']_补$；得到$z$的符号$S_z$ = $Sum[MSB]$；

&emsp;&emsp;（5）**规格化**：若$Sum$双符号位不同，则需右规；若符号位与最高数据位相同，则需左规；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;右规：$Sum$<u>算术右移</u>1位；$z$的阶码$E_z$ = $E_x$ + 1；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的尾数的补码$[M_z]_补$ = $Sum[MSB-1:MSB-25]$，  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;左规：$Sum$的数据单独左移$a$位；$z$的阶码$E_z$ = $E_x$ - $a$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的尾数的补码$[M_z]_补$ = $Sum[MSB-1:MSB-25]$；

&emsp;&emsp;（6）**求尾数原码**：求$[M_z]_补$的原码$M_z$；

&emsp;&emsp;最终得到$z = \{S_z, E_z, M_z[22:0]\}$。

!!! example "【补码运算-例1 :chestnut:】 已知$x = -0.345$，$y = -0.845$，求$z = x + y$。"
    &emsp;&emsp;已知：$x$ = $-0.345$ $\Leftrightarrow$ `32'hBEB0_A3D7` = `{1'b1, 8'h7D, 23'h30_A3D7}`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$y$ = $-0.845$ $\Leftrightarrow$ `32'hBF58_51EC` = `{1'b1, 8'h7E, 23'h58_51EC}`；

    &emsp;&emsp;故有：$S_x$ = 1，$E_x$ = `8'h7D`，$M_x$ = `{1'b1, 23'h30_A3D7}` = `24'hB0_A3D7`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$S_y$ = 1，$E_y$ = `8'h7E`，$M_y$ = `{1'b1, 23'h58_51EC}` = `24'hD8_51EC`；

    &emsp;&emsp;<b>*Step1*</b>：求补码：$x$的阶码更小，故求：  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[-E_x]_补$ = $[\{1'b1$，$E_x\}]_补$ = `9'h183`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[E_y]_补$ = $[\{1'b0$，$E_y\}]_补$ = `9'h7E`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[M_x]_补$ = $\{S_x$，$[\{S_x$，$M_x\}]_补\}$ = `{2'b11, 24'h4F_5C29}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[M_y]_补$ = $\{S_y$，$[\{S_y$，$M_y\}]_补\}$ = `{2'b11, 24'h27_AE14}`；

    &emsp;&emsp;<b>*Step2*</b>：求阶差：$\Delta E$ = $[-E_x]_补 + [E_y]_补$ = `9'h183` + `9'h7E` = `9'h1`；

    &emsp;&emsp;<b>*Step3*</b>：对阶：$x$的阶码更小，故将$[M_x]_补$右移$\Delta E$位，得到$[{M_x}']_补$ = `{2'b11, 24'h4F_5C29}` >>~s~ `9'h1`  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;= `{2'b11, 24'hA7_AE14}`；

    &emsp;&emsp;<b>*Step4*</b>：尾数运算：$Sum$ = $[{M_x}']_补$ + $[M_y]_补$ = `{2'b11, 24'hA7_AE14}` + `{2'b11, 24'h27_AE14}`  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;= `26'h3A7_AE14` + `26'h327_AE14` = `26'h2CF_5C28`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;= `{2'b10, 24'hCF5C28}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的符号$S_z$ = $Sum[MSB]$ = $Sum[25]$ = `1'b1`；

    &emsp;&emsp;<b>*Step5*</b>：规格化：$Sum$的双符号位不同，故需右规；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$Sum$ >>~s~ 1 = `{2'b10, 24'hCF_5C28}` >>~s~ 1 = `{2'b11, 24'h67_AE14}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的阶码$E_z$ = $E_y$ + 1 = `8'h7E` + 1 = `8'h7F`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的尾数的补码$[M_z]_补$ = $Sum[MSB-1:MSB-25]$ = $Sum[24:0]$ = `{1'b1, 24'h67_AE14}`；

    &emsp;&emsp;<b>*Step6*</b>：求尾数原码：由$[M_z]_补$ = `{1'b1, 24'h67_AE14}`，可得$M_z$ = `{1'b1, 24'h98_51EC}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;故$z$ = {$S_z$, $E_z$, $M_z$[22:0]} = `{1'b1, 8'h7F, 23'h18_51EC}` = `32'hBF98_51EC` $\Leftrightarrow$ $-1.19$。

!!! example "【补码运算-例2 :chestnut:】 已知$x = 3.14$，$y = 2.71828$，求$z = x - y$。"
    &emsp;&emsp;已知：$x$ = $3.14$ $\Leftrightarrow$ `32'h4048_F5C3` = `{1'b0, 8'h80, 23'h48_F5C3}`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$y$ = $2.71828$ $\Leftrightarrow$ `32'h402D_F84D` = `{1'b1, 8'h80, 23'h2D_F84D}`；

    &emsp;&emsp;故有：$S_x$ = 0，$E_x$ = `8'h80`，$M_x$ = `{1'b1, 23'h48_F5C3}` = `24'hC8_F5C3`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$S_y$ = 0，$E_y$ = `8'h80`，$M_y$ = `{1'b1, 23'h2D_F84D}` = `24'hAD_F84D`；

    &emsp;&emsp;<b>*Step1*</b>：求补码：$[E_x]_补$ = $[\{1'b0$，$E_x\}]_补$ = `9'h80`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[-E_y]_补$ = $[\{1'b1$，$E_y\}]_补$ = `9'h180`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[M_x]_补$ = $\{S_x$，$[\{S_x$，$M_x\}]_补\}$ = `{2'b00, 24'hC8_F5C3}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$[-M_y]_补$ = $\{!S_y$，$[\{!S_y$，$M_y\}]_补\}$ = `{2'b11, 24'h52_07B3}`；

    &emsp;&emsp;<b>*Step2*</b>：求阶差：$\Delta E$ = $[E_x]_补 + [-E_y]_补$ = `9'h80` + `9'h180` = `9'h0`；

    &emsp;&emsp;<b>*Step3*</b>：对阶：阶差为0，不需对阶；

    &emsp;&emsp;<b>*Step4*</b>：尾数运算：$Sum$ = $[M_x]_补$ + $[-M_y]_补$ = `{2'b00, 24'hC8_F5C3}` + `{2'b11, 24'h52_07B3}`  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;= `26'h0C8_F5C3` + `26'h352_07B3` = `26'h01A_FD76`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;= `{2'b00, 24'h1A_FD76}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的符号$S_z$ = $Sum[MSB]$ = $Sum[25]$ = `1'b0`；

    &emsp;&emsp;<b>*Step5*</b>：规格化：$Sum$的符号位为0，而最高3位数据位也为0，故需左规3位；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$Sum$ << 3 = `{2'b00, 24'h1A_FD67}` << 3 = `{2'b00, 24'hD7_EBB0}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的阶码$E_z$ = $E_x$ - 3 = `8'h80` - 3 = `8'h7D`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的尾数的补码$[M_z]_补$ = $Sum[MSB-1:MSB-25]$ = $Sum[24:0]$ = `{1'b0, 24'hD7_EBB0}`；

    &emsp;&emsp;<b>*Step6*</b>：求尾数原码：$[M_z]_补$为正数，故$M_z$ = $[M_z]_补$ = `{1'b0, 24'hD7_EBB0}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;故$z$ = {$S_z$, $E_z$, $M_z$[22:0]} = `{1'b0, 8'h7D, 23'h57_EBB0}` = `32'h3ED7_EBB0` $\Leftrightarrow$ $0.42172$。

!!! info "小扩展 :books:"
    &emsp;&emsp;（1）<a href="https://www.h-schmidt.net/FloatConverter/IEEE754.html" target="_blank">IEEE754编码转换器</a>可帮助你在IEEE754编码和真值之间进行转换。

    &emsp;&emsp;（2）求补运算可通过在Verilog中自定义`function`来实现：

    ``` Verilog  linenums="1"
    function signed [8:0] cpl2_9;            // 位宽需为常数
        input signed [8:0] data;
        integer cpl2;
        begin
            cpl2   = (~data[7:0]) + 1;       // “扫描法”求补码
            cpl2_9 = data[8] ? {data[8], cpl2[7:0]} : data;
        end
    endfunction
    ......
    assign num_complement = cpl2_9(num);     // “调用”function
    ```

    &emsp;&emsp;（3）算术移位运算可通过Verilog的`>>>`运算符实现：

    ``` Verilog linenums="1"
    assign num_right_shifted = $signed(num) >>> bits;
    ```

### 2.2 基于原码运算的浮点加减法

&emsp;&emsp;得益于Verilog HDL的行为级描述方式，我们在设计电路时可以直接使用减号实现减法，从而“省去”求补的步骤。尽管如此，需要明确的是，底层电路仍然是通过求补来实现减法的。因此事实上，<u>求补的操作仍然存在，只不过被转交到底层电路来隐式地实现，而不是由开发者实现</u>。也就是说，从底层电路的角度讲，本小节所介绍的方法与上一小节的方法其实没有本质上的区别。

&emsp;&emsp;设有被加/减数$x$，加/减数$y$，运算结果为$z$，且：  
<center>$x = (-1)^{S_x} \cdot M_x \cdot 2^{E_x-127}$ $\Leftrightarrow$ $\{S_x, E_x, M_x\}$，</center>  
<center>$y = (-1)^{S_y} \cdot M_y \cdot 2^{E_y-127}$ $\Leftrightarrow$ $\{S_y, E_y, M_y\}$，</center>  
<center>$z = (-1)^{S_z} \cdot M_z \cdot 2^{E_z-127}$ $\Leftrightarrow$ $\{S_z, E_z, M_z\}$，</center>  
&emsp;&emsp;若$x$/$y$/$z$是规格化数，则尾数$M_{x/y/z} = \{1, (x/y/z)[22:0]\}$；若$x$/$y$/$z$是非规格化数，则尾数$M_{x/y/z} = (x/y/z)[22:0]$。

!!! info "符号说明 :scroll:"
    &emsp;&emsp;$S_{x/y/z}$、$E_{x/y/z}$、$M_{x/y/z}$分别表示$x$/$y$/$z$的符号、阶码、尾数。

&emsp;&emsp;基于原码运算的浮点加减法步骤为：

&emsp;&emsp;（1）**求阶差**：$\Delta E = |E_x - E_y|$；

&emsp;&emsp;（2）**对阶**：小阶对大阶。<u>不妨设$y$的阶码更小</u>，则令$y$的尾数$M_y$右移$\Delta E$位，得到${M_y}'$；

&emsp;&emsp;（3）**尾数运算**：若是加法运算，化简并计算$(-1)^{S_x} \cdot M_x + (-1)^{S_y} \cdot {M_y}'$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;若是减法运算，化简并计算$(-1)^{S_x} \cdot M_x - (-1)^{S_y} \cdot {M_y}'$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;（<u>**注意：如果实际进行的是减法运算，需保证被减数大于减数**</u>）  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;根据运算结果，得到$z$的符号$S_z$和尾数$M_z$；

&emsp;&emsp;（4）**规格化**：若$M_z$的有效位宽大于24位，则需右规；有效位宽小于24位，则需左规；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;右规：$M_z$右移$1$位，使其有效位宽缩小至24位；阶码$E_z = E_x + 1$；  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;左规：$M_z$左移$a$位，使其有效位宽增大至24位；阶码$E_z = E_x - a$；  

&emsp;&emsp;最终得到$z = \{S_z, E_z, M_z[22:0]\}$。

!!! example "【原码运算-例1 :chestnut:】 已知$x = 12.567$，$y = 6.321$，求$z = x + y$。"
    &emsp;&emsp;已知：$x$ = $12.567$ $\Leftrightarrow$ `32'h4149_126F` = `{1'b0, 8'h82, 23'h49_126F}`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$y$ = $6.321$ $\Leftrightarrow$ `32'h40CA_45A2` = `{1'b0, 8'h81, 23'h4A_45A2}`；

    &emsp;&emsp;故有：$S_x$ = 0，$E_x$ = `8'h82`，$M_x$ = `{1'b1, 23'h49_126F}` = `24'hC9_126F`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$S_y$ = 0，$E_y$ = `8'h81`，$M_y$ = `{1'b1, 23'h4A_45A2}` = `24'hCA_45A2`；

    &emsp;&emsp;<b>*Step1*</b>：求阶差：$\Delta E$ = $E_x - E_y$ = `8'h82` - `8'h81` = `8'h1`；

    &emsp;&emsp;<b>*Step2*</b>：对阶：$y$的阶码更小，故将$M_y$右移$\Delta E$位，得到${M_y}'$ = `24'hCA_45A2` >> `8'h1` =`24'h65_22D1`；

    &emsp;&emsp;<b>*Step3*</b>：尾数运算：$(-1)^{S_x} \cdot M_x + (-1)^{S_y} \cdot {M_y}'$ = `24'hC9_126F` + `24'h65_22D1` = `25'h12E_3540`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;运算结果为正数，故$S_z$ = `1'b0`，尾数$M_z$ = `25'h12E_3540`；  

    &emsp;&emsp;<b>*Step4*</b>：规格化：$M_z$的有效位宽为25位，比24大1位，故需右规；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$M_z$ >> 1 = `25'h12E_3540` >> 1 = `24'h97_1AA0` = `{1'b1, 23'h17_1AA0}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的阶码$E_z$ = $E_x$ + 1 = `8'h82` + 1 = `8'h83`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;故$z$ = {$S_z$, $E_z$, $M_z$[22:0]} = `{1'b0, 8'h83, 23'h17_1AA0}` = `32'h4197_1AA0` $\Leftrightarrow$ $18.888$。

!!! example "【原码运算-例2 :chestnut:】 已知$x = -3.14$，$y = -2.71828$，求$z = x - y$。"
    &emsp;&emsp;已知：$x$ = $-3.14$ $\Leftrightarrow$ `32'hC048_F5C3` = `{1'b1, 8'h80, 23'h48_F5C3}`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$y$ = $-2.71828$ $\Leftrightarrow$ `32'hC02D_F84D` = `{1'b1, 8'h80, 23'h2D_F84D}`；

    &emsp;&emsp;故有：$S_x$ = 1，$E_x$ = `8'h80`，$M_x$ = `{1'b1, 23'h48_F5C3}` = `24'hC8_F5C3`，  
    &emsp;&emsp;&emsp;&emsp;&emsp;$S_y$ = 1，$E_y$ = `8'h80`，$M_y$ = `{1'b1, 23'h2D_F84D}` = `24'hAD_F84D`；

    &emsp;&emsp;<b>*Step1*</b>：求阶差：$\Delta E$ = $E_x - E_y$ = `8'h0`；

    &emsp;&emsp;<b>*Step2*</b>：对阶：阶差为0，不需对阶；

    &emsp;&emsp;<b>*Step3*</b>：尾数运算：$(-1)^{S_x} \cdot M_x - (-1)^{S_y} \cdot M_y$ = `-24'hC8_F5C3` - `-24'hAD_F84D`  
    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp; = `24'hAD_F84D` - `24'hC8_F5C3`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;此时，**被减数`24'hAD_F84D`小于减数`24'hC8_F5C3`，直接相减将出现补码，故需变换被减数和减数**；
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;变换后，原式 = - (`24'hC8_F5C3` - `24'hAD_F84D`) = `-24'h1A_FD76`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;运算结果为负数，故$S_z$ = `1'b1`，尾数$M_z$ = `24'h1A_FD76` = `{3'h0, 21'h1A_FD76}`；  

    &emsp;&emsp;<b>*Step4*</b>：规格化：$M_z$的有效位宽为21位，比24小3位，故需左规3位；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$M_z$ << 3 = `24'h1A_FD76` << 3 = `24'hD7_EBB0` = `{1'b1, 23'h57_EBB0}`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;$z$的阶码$E_z$ = $E_x$ - 3 = `8'h80` - 3 = `8'h7D`；  
    &emsp;&emsp;&emsp;&emsp;&emsp;&ensp;故$z$ = {$S_z$, $E_z$, $M_z$[22:0]} = `{1'b1, 8'h7D, 23'h57_EBB0}` = `32'hBED7_EBB0` $\Leftrightarrow$ $-0.42172$。

### 2.3 关于舍入

&emsp;&emsp;在对阶和右规的过程中，尾数的末尾可能丢失，从而引起误差。正常情况下，需要采用“**0舍1入法**”或“**恒置1法**”进行舍入。在本实验中，出于简单性考虑，可不进行舍入。



## 3. 设计概述

### 3.1 组合电路方案

&emsp;&emsp;分析浮点运算的过程不难知道，输入数据的分解、求阶差、对阶、尾数运算等操作都可以通过`assign`语句或`always @(*)`语句快速实现。

&emsp;&emsp;组合电路方案的难点在于规格化。如果是右规，最多需要右规1位；如果是左规，则左规的位数不定。对于时序电路方案，可以让状态机循环进入同一个状态N次，每次左规1位，这样就能实现任意位数的左规。对于组合电路方案，可以通过位操作和多路选择器相结合的方法实现任意位数的左规。

&emsp;&emsp;若采用组合逻辑电路实现浮点运算器，需采用如表2-3所示的接口信号。

<center>表2-3 组合电路方案的接口信号</center>
<center>

| 序号 | 接口信号 | 位宽 | 属性 | 释义 |
| :-: | :-: | :-: | :-: | :-: |
| 1 | `op` | `1` | 输入 | 0表示加法，1表示减法 |
| 2 | `A` | `32` | 输入 | 被加/减数 |
| 3 | `B` | `32` | 输入 | 加/减数 |
| 4 | `C` | `32` | 输出 | 运算结果 |

</center>

&emsp;&emsp;组合电路方案的Testbench是模板工程中的`fpu_tb.sv`文件。该Testbench每次向运算器提供一个测试用例。

### 3.2 时序电路方案

&emsp;&emsp;浮点数的加减法运算具有清晰明确的步骤，这种时序上的先后关系非常适合使用状态机实现。

&emsp;&emsp;状态机的三要素是 **状态**、**状态转移**、**输入输出**。因此设计时需要分析浮点运算的步骤和过程，结合实际工程的接口信号时序，设计相应的状态、状态转移条件以及每个状态的输入输出。

&emsp;&emsp;若采用时序逻辑电路实现浮点运算器，需采用如表2-4所示的接口信号。

<center>表2-4 时序电路方案的接口信号</center>
<center>

| 序号 | 接口信号 | 位宽 | 属性 | 释义 |
| :-: | :-: | :-: | :-: | :-: |
| 1 | `rst` | `1` | 输入 | 复位信号（高电平复位） |
| 2 | `clk` | `1` | 输入 | 时钟信号 |
| 3 | `start` | `1` | 输入 | 有效时表示有新的数据输入 |
| 4 | `op` | `1` | 输入 | 0表示加法，1表示减法 |
| 5 | `A` | `32` | 输入 | 被加/减数 |
| 6 | `B` | `32` | 输入 | 加/减数 |
| 7 | `ready` | `1` | 输出 | 有效时表示运算器就绪，可以接收新的数据 |
| 8 | `C` | `32` | 输出 | 运算结果 |

</center>

&emsp;&emsp;时序电路方案的Testbench是模板工程中的`fpu_tb_clk.sv`文件。在该Testbench中，接口信号遵循如图2-2所示的时序。

<center><img src="../assets/2-2.png" width = 600></center>
<center>图2-2 时序Testbench的接口信号时序</center>

!!! note "时序解读 :teacher:"
    &emsp;&emsp;在图2-2中，`ready`信号需要运算器生成，它表示运算器当前是否就绪。**在复位之后，`ready`默认有效**，表示运算器已经复位完成，可以接收数据并进行运算了。
    
    &emsp;&emsp;**Testbench只会在检测到`ready`信号有效时，才拉高`start`信号**，并同时将运算符`op`和两个数据`A`、`B`提供给运算器。需要注意的是，`start`信号只会有效一个时钟周期，因此运算器应当在检测到`start`有效后，及时将`op`、`A`和`B`缓存起来。

    &emsp;&emsp;**运算器检测到`start`有效后，除了需要将输入的`op`、`A`和`B`缓存起来，还需要将`ready`拉低** —— 表示当前正在运算过程中，暂不能接收新的数据。

    &emsp;&emsp;运算完成后，运算器应将`ready`拉高，同时将运算结果输出。Testbench检测到`ready`再次有效后，即可拉高`start`信号，以输入下一组测试数据。

&emsp;&emsp;按照以上的时序约定，所设计的状态机应形如图2-3所示。

<center><img src="../assets/2-3.png" width = 250></center>
<center>图2-3 浮点运算器状态机设计</center>

&emsp;&emsp;由图2-3可知，当Testbench的`start`信号无效时，状态机将一直徘徊在`IDLE`状态。当`start`信号有效时，状态机应当缓存输入的`op`、`A`和`B`，拉低`ready`信号，然后进入下一个状态开始进行运算。虚线框内是浮点运算器的核心逻辑，请同学们自行完成设计。运算完成后，状态机进入`END`状态，并拉高`ready`信号，同时输出运算结果`C`，并回到`IDLE`状态。
