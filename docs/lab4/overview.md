## 实验目的

&emsp;&emsp;1. 了解CPU与SoC的关系，熟悉SoC的基本架构；

&emsp;&emsp;2. 了解基于ready-valid握手协议的总线工作原理；

&emsp;&emsp;3. 熟悉AXI4-Lite总线协议，掌握其总线接口的实现方法。


## 实验内容

&emsp;&emsp;本实验要求在提供的SoC模板工程上，**完成axilite_master模块的实现**，从而使得CPU能够通过AXI4-Lite总线协议读写存储器和I/O设备。

&emsp;&emsp;要求及说明：

&emsp;&emsp;（1）完成模板工程中，axilite_master模块的AW、W、AR和R四个通道；

&emsp;&emsp;（2）为简化设计，要求实现的axilite_master模块总是<u>先处理完一个请求，再处理下一个请求</u>，即不考虑连续数据访问、读写请求重叠的情况；

&emsp;&emsp;（3）运行功能仿真，通过模板工程自带的所有测试用例。

