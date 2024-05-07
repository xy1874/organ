# 附加题

## 题目：Booth乘法器设计（<font color=green>**+1**</font>分）

### 1. 设计内容及要求

&emsp;&emsp;基于Booth乘法算法，为SoC工程设计32位的整型补码乘法器。

&emsp;&emsp;要求：

&emsp;&emsp;（1）被乘数、乘数是32位有符号整数（补码表示）；乘积是64位有符号整数（补码表示）；

&emsp;&emsp;（2）乘法器的接口信号及接口信号的工作时序均与除法器相同；

&emsp;&emsp;（3）只需保证接口信号的输入输出属性不变、位宽不变、信号名不变。接口信号的数据类型  
&emsp;&emsp;&emsp;&emsp;&ensp;可根据实际需要，自行修改成wire型或reg型；

&emsp;&emsp;（4）不允许使用`*`运算符。



### 2. Booth算法回顾

&emsp;&emsp;对于小数乘法，若被乘数 $[x]_补 = x_0.x_1 \cdots x_{n}$ ，乘数 $[y]_补 = y_0.y_1 \cdots y_{n}$ ，则有：

$$
\begin{aligned}
\hspace{0pt}
    [x \times y]_\text{补} &= (y_1 - y_0)[x]_补 + [z_n]_补 \\
    [z_n]_补 &= 2^{-1} \cdot \{(y_2 - y_1)[x]_补 + [z_{n-1}]_补\} \\
    & \,\,\, \vdots \\
    [z_{n-i+1}]_补 &= 2^{-1} \cdot \{(y_{i+1} - y_i)[x]_补 + [z_{n-i}]_补\} \\
    & \,\,\, \vdots \\
    [z_1]_补 &= 2^{-1} \cdot \{(y_{n+1} - y_n)[x]_补 + [z_0]_补\} \\
    [z_0]_补 &= 0, \,\,\, y_{n+1} = 0.
\end{aligned}
$$

&emsp;&emsp;整数乘法同理。若被乘数 $[x]_补 = x_0x_1 \cdots x_{n}$ ，乘数 $[y]_补 = y_0y_1 \cdots y_{n}$，则有：

$$
\begin{aligned}
\hspace{0pt}
    [x \times y]_补 &= 2^n \cdot (y_1 - y_0)[x]_补 + 2^n \cdot [z_n]_补 \\
    [z_n]_补 &= 2^{-1} \cdot \{(y_2 - y_1)[x]_补 + [z_{n-1}]_补\} \\
    & \,\,\, \vdots \\
    [z_{n-i+1}]_补 &= 2^{-1} \cdot \{(y_{i+1} - y_i)[x]_补 + [z_{n-i}]_补\} \\
    & \,\,\, \vdots \\
    [z_1]_补 &= 2^{-1} \cdot \{(y_{n+1} - y_n)[x]_补 + [z_0]_补\} \\
    [z_0]_补 &= 0, \,\,\, y_{n+1} = 0.
\end{aligned}
$$

!!! note "递推式推导 :pencil:"
    &emsp;&emsp;整数乘法部分积的递推式推导如下：

    $$
    \begin{aligned}
    \hspace{0pt}
        [x \times y]_补 &= [x]_补 \cdot [y_0y_1 \cdots y_n] \\
                        &= [x]_补 \cdot [y_0 \cdot 2^n + y_1y_2 \cdots y_n] \\
                        &= [x]_补 \cdot (-y_0 \cdot 2^n + y_1y_2 \cdots y_n)    \\
                        &= [x]_补 \cdot (-y_0 \cdot 2^n + y_1 \cdot 2^{n-1} + y_2 \cdot 2^{n-2} + \cdots + y_n \cdot 2^0)   \\
                        &= [x]_补 \cdot \{-y_0 \cdot 2^n + y_1 \cdot (2^n - 2^{n-1}) + y_2 \cdot (2^{n-1} - 2^{n-2}) + \cdots + y_n \cdot (2^1 - 2^0)\}   \\
                        &= [x]_补 \cdot \{2^n(y_1 - y_0) + 2^{n-1}(y_2 - y_1) + \cdots + 2^1(y_n - y_{n-1}) + 2^0(y_{n+1} - y_n)\}  \\
                        &= 2^n[x]_补 \cdot \{(y_1 - y_0) + 2^{-1} (y_2 - y_1) + \cdots + 2^{-(n-1)}(y_n - y_{n-1}) + 2^{-n}(y_{n+1} - y_n)\} \\
                        &= 2^n \cdot (y_1 - y_0)[x]_补 \, +    \\
                        &\quad\,\, 2^n \cdot 2^{-1}\{(y_2 - y_1)[x]_补 + \cdots + 2^{-1}\{(y_n - y_{n-1}) + 2^{-1}\{(y_{n+1}-y_n)[x]_补 + 0\} \cdots \}\}
    \end{aligned}
    $$

    &emsp;&emsp;其中，$y_{n+1} = 0$.

&emsp;&emsp;由部分积的递推式 $[z_{n-i+1}]_补 = 2^{-1} \cdot \{(y_{i+1} - y_i)[x]_补 + [z_{n-i}]_补\}$ 可知：

- 若 $y_{i+1} - y_i = 0$，则 $[z_{n-i+1}]_补 = 2^{-1} \cdot [z_{n-i}]_补$，即部分积右移一位；  
- 若 $y_{i+1} - y_i = 1$，则 $[z_{n-i+1}]_补 = 2^{-1} \cdot ([x]_补 + [z_{n-i}]_补)$，即部分积先加上 $[x]_补$ 再右移一位；
- 若 $y_{i+1} - y_i = -1$，则 $[z_{n-i+1}]_补 = 2^{-1} \cdot ([z_{n-i}]_补 - [x]_补)$，即部分积先减去 $[x]_补$ 再右移一位。

&emsp;&emsp;因此，$y_iy_{i+1}$ 对部分积操作的影响可总结为如表4-1所示的规则。

<center>表4-1 $y_iy_{i+1}$ 对部分积操作的影响</center>
<center>

| $y_iy_{i+1}$ | $y_{i+1} - y_i$ | 对应的部分积操作 |
| :-: | :-: | :-: |
| `2'b00` | 0 | 部分积右移一位 |
| `2'b01` | 1 | 部分积$+[x]_补$，再右移一位 |
| `2'b10` | -1 | 部分积$-[x]_补$，再右移一位 |
| `2'b11` | 0 | 部分积右移一位 |

</center>

!!! example "栗子+1 :chestnut:"
    &emsp;&emsp;设被乘数 $x$ = `0110`，乘数 $y$ = `0101`。$x$ 的补码 $[x]_补$ = `0110`，而 $-[x]_补 = [-x]_补$ = `1010`，$y$ 的补码 $[y]_补$ = `0101`，则有：

    <center><img src="../assets/4-1.png" width = 400></center>
    <center>图4-1 整数Booth乘法示例</center>



### 3. 操作步骤

（1）实现Booth乘法器

&emsp;&emsp;打开SoC工程后，依次展开 `soc` -> `U_cpu` -> `U_core` -> `U_ALU`，找到最内层的乘法器模块`U_mul`。双击打开后，可见其内部是用运算符实现乘法功能的。请将`multiplier.v`的第13-24行代码删除或注释掉，然后在其中实现Booth乘法器。

（2）仿真调试

&emsp;&emsp;实现完成后，直接运行功能仿真，利用仿真波形对所设计的Booth乘法器进行调试和验证。

（3）撰写报告

&emsp;&emsp;按要求撰写实验报告。
