## 实验目的

&emsp;&emsp;1. 掌握直接映射Cache的基本结构及工作原理；

&emsp;&emsp;2. 掌握直接映射Cache的HDL实现方法；

&emsp;&emsp;3. 认识Cache对计算机系统性能的影响。


## 实验内容

&emsp;&emsp;在SoC工程`miniRV_axi`中，设计实现直接映射方式的指令Cache，即ICache。

&emsp;&emsp;要求及说明：

&emsp;&emsp;（1）完成SoC工程中的ICache模块，即`ICache.v`，如图1-1所示。

<center><img src="../assets/1-1.png" width = 350></center>
<center>图1-1 完成SoC工程的ICache模块</center>

&emsp;&emsp;（2）主存是大小为32KB的带有随机访问延迟的Block Memory存储器；

&emsp;&emsp;（3）Cache采用Block Memory作为存储介质，其大小为1KB，块大小为4个32位字；

&emsp;&emsp;（4）ICache对CPU是只读的，即只需处理读命中、读缺失两种情形；

&emsp;&emsp;（5）测试并比较无ICache和有ICache时，SoC运行测试程序的时间，并记录ICache命中率。
