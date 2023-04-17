# 逻辑门的描述

<center>

| 逻辑门 | <div align=center>Verilog描述</div> | <div align=center>逻辑表达式</div> |
| :-: | :- | :- |
| 与门 | `F = A & B;` | $F=AB$ |
| 或门 | `F = A | B;` | $F=A+B$ |
| 非门 | `F = ~A;` | $F=\overline{A}$ |
| 与非门 | `F = ~(A & B);` | $F=\overline{AB}$ |
| 或非门 | `F = ~(A | B);` | $F=\overline{A+B}$ |
| 与或非门 | `F = ~(A & B | C & D);` | $F=\overline{AB+CD}$ |
| 异或门 | `F = A ^ B;` <br>或 `F = ~A & B | A & ~B;` | $F=A\bigoplus B$ <br>或 $F=\overline{A}B+A\overline{B}$ |
| 同或门 | `F = A ~^ B;` <br>或 `F = ~(A ^ B);` <br>或 `F = A & B | ~A & ~B;` | $F=\overline{A\bigoplus B}$ <br>或 $F=AB+\overline{A}\cdot \overline{B}$ |

</center>
