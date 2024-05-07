&emsp;&emsp;在Vivado中，除了编写HDL，还可以使用模块图进行开发。该项功能称为Block Design。

&emsp;&emsp;实现AXI总线接口的好处是可以使用库里许多现成的IP核。下面简要介绍如何使用Block Design为CPU构建基于AXI总线的SoC。

&emsp;&emsp;首先，在Vivado左侧的`IP INTEGRATOR`下，新建一个Block Design，如图A-1所示。

<center><img src="../assets/a-1.png" width = 500></center>
<center>图A-1 新建Block Design</center>

&emsp;&emsp;将编写好的AXI接口的CPU模块添加到Block Design当中，如图A-2所示。

<center><img src="../assets/a-2.png" width = auto></center>
<center>图A-2 添加HDL模块到Block Design</center>

&emsp;&emsp;点击Block Design菜单栏上的“+”号，搜索所需的IP核，如图A-3所示。可以看到，Vivado库自带了许多AXI接口的IP核。这里我们选择`AXI GPIO`、`Block RAM`作为例子。

<center><img src="../assets/a-3.png" width = 400></center>
<center>图A-3 添加IP核到Block Design</center>

&emsp;&emsp;将所需的IP核添加完成后，可按实际需要双击IP核进行配置。配置完成后，点击`OK`按钮关闭配置窗口。

&emsp;&emsp;接下来，点击`Run Connnection Automation`，Vivado将自动连接这些IP核，如图A-4所示。

<center><img src="../assets/a-4.png" width = auto></center>
<center>图A-4 自动连接IP核</center>

!!! danger "【注意】 :fire:"
    &emsp;&emsp;Vivado自动连接形成的电路有可能跟我们预想的设计不同。因此，待自动连接完成后，应当检查各模块之间的连线是否需要手动调整。

&emsp;&emsp;自动连接后，得到的电路模块图一般比较乱，可点击菜单栏的`Regenerate Layout`按钮以调整布局，如图A-5所示。

<center><img src="../assets/a-5.png" width = auto></center>
<center>图A-5 调整和美化布局</center>

&emsp;&emsp;接下来，我们需要手动连接剩余的端口和信号。在本例子中，我们需要手动连接时钟信号和复位信号。

&emsp;&emsp;单击时钟IP核的输入端，为其添加外部输入/输出端口，如图A-6所示。

<center><img src="../assets/a-6.png" width = 400></center>
<center>图A-6 设置输入/输出端口</center>

&emsp;&emsp;单击外部端口，即可在左侧的`Property`窗口中更改外部端口的名称，如图A-7所示。

<center><img src="../assets/a-7.png" width = 500></center>
<center>图A-7 更改输入/输出端口的名称</center>

&emsp;&emsp;接下来，将鼠标移动到待连接端口上方，直到鼠标变成铅笔图标后长按鼠标左键，拖动鼠标到连接目标处松开鼠标，即可完成连线，如图A-8所示。

<center><img src="../assets/a-8.png" width = 450></center>
<center>图A-8 手动完成剩余连线</center>

&emsp;&emsp;用类似的方法，将`cpu_model`的时钟信号连接到`clk_wiz`的输出时钟，将`rst_clk_wiz_100M`的`ext_reset_in`连接到`fpga_rst`。需要注意的是，由图A-8可知，`ext_reset_in`是低电平复位信号。因此，如果FPGA板上的复位信号是高电平复位，则需添加一个非门。

&emsp;&emsp;完成所有的电路连接后，点击Block Design菜单栏的`Validate`按钮，Vivado将对连接好的电路进行检查，如图A-9所示。如果检查结果提示当前电路存在`error`或`critical warning`，则需要根据提示信息，将对应的问题修正。

<center><img src="../assets/a-9.png" width = auto></center>
<center>图A-9 验证Block Design的正确性</center>

&emsp;&emsp;接下来，回到HDL源文件窗口，在构建完毕的Block Design上右键，点击`Create HDL Wrapper`，并在随后弹出的对话框中点击`OK`按钮。此时，Vivado将为Block Design创建基于HDL的顶层包装文件。

&emsp;&emsp;最后，为外部输入/输出信号编写约束文件，即可进行后续的综合、实现、生成比特流和下板验证。
