
## 软件安装

### Requirements

* 硬件
  * NI PXI-5421 + NI PXIe-PCIe8361
  * 硬件配置具体见[ROI imaging module hardware setup guide](../ROI_imaging_module_hardware/README.md)
* 成像系统
  * 使用ScanImage作为三光子成像系统
* 软件安装
  * Matlab >= R2022b (we use Matlab R2023b)
    需要安装如下toolbox
    * Instrument Control Toolbox
    * [IVI and VXIplug&amp;play Driver Support from Instrument Control Toolbox](https://ww2.mathworks.cn/hardware-support/ivi-vxiplug-play-instrument-driver.html)
  * Python v3.10

### Install Cellpose-SAM

软件使用Cellpose-SAM进行自动细胞分割

参考[https://github.com/MouseLand/cellpose](https://github.com/MouseLand/cellpose)的安装教程，安装cellpose

1. Install a [miniforge](https://github.com/conda-forge/miniforge) distribution of Python.
2. Create a new environment and install Cellpose

   ```bash
   # create cellpose environment
   conda create --name cellpose python=3.10
   conda activate cellpose
   # install pytorch
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
   # install cellpose
   python -m pip install cellpose[gui]
   ```
3. 打开Matlab ，Matlab 配置python环境为cellpose的环境所在文件地址

   ```matlab
   pyenv('Version', "C:\Users\[YOUR_USER_NAME]\miniforge3\envs\cellpose\python.exe",ExecutionMode = 'OutOfProcess')
   ```

   ![image](assets/image-20260105111901-tksfa1t.png)

### Install ROI imaging module software

在Github下载本repo到本地文件夹

打开Matlab，进入3PM_ROI_imaging_module\ROI_imaging_module_software文件夹，在终端输入下面命令来运行软件

```bash
roi_imaging_module
```

![image](assets/image-20260105170742-xxo1w8m.png)

## ROI imaging module基本配置

### AWG参数配置

点击顶栏菜单Settings → AWG Settings

![image](assets/image-20260105170756-z7p6bhy.png)

AWG Settings界面

![image](assets/image-20260105170950-azxn5fs.png)

* Device ID：在NI Max 软件里可以获取到，默认一般为Dev1
* Trigger mode：无需设置，可选Continous、Single、Burst、Stepped，具体区别请查看[AWG文档](https://www.ni.com/en/support/documentation/supplemental/06/advanced-arbitrary-waveform-generator-features.html)
  * 在ROI imaging、FPA imaging时，将使用Stepped模式
  * 在Regular imaging时，将使用Continuous模式，使激光持续开放
* Sampling clock：默认使用External，通过ClkIn端口输入激光器的同步时钟
* External trigger：默认为On，默认使用PFI0端口输入vDAQ输出的每帧扫描起始信号，来触发AWG输出每帧信号
* Gain (V)：默认为3.3V
* Offset (V): 默认为0
* Sampling rate (Hz): 默认为1e6，需要设置为使用激光器的重复频率
* Delay (ns)：默认为0

### AWG 连接

点击Connect按钮进行连接

![image](assets/image-20260105171010-20tapk7.png)

如果在测试电脑上运行本软件，电脑没有连接AWG硬件，想测试软件运行功能，可以使用AWG Simulate Mode

![image](assets/image-20260105171038-07yimc2.png)

在Connect按钮右边会出现一个按钮，这时进入Simulate mode，可以连接AWG虚拟硬件，并可以正常执行AWG 输出波形等功能

![image](assets/image-20260105171051-xjj4h21.png)

成功连接虚拟AWG后，会默认进入Conventional imaging模式

![image](assets/image-20260105172027-qb7nw91.png)

如果想要测试AWG进行自定义波形输出，可以点击Utilities → AWG Control

![image](assets/image-20260105172043-6i96hd4.png)

AWG Control界面

![image](assets/image-20260105172427-2pkcvnw.png)

![image](assets/image-20260105172440-pc4tb8b.png)

### 配置scanner参数

点击ScanImage按钮，将连接ScanImage成像软件，获取所有成像扫描参数

![image](assets/image-20260105172519-2gj3qs8.png)

点击顶栏菜单Settings → Scanner Settings

![image](assets/image-20260105172543-30fw0mn.png)

Scanner Settings界面

![image](assets/image-20260105172757-qdur0xk.png)

* Trigger type：默认为Frame Clock，可选Frame Clock/Line Clock
* Image size：成像系统保存的图片像素大小
* Pulse per pixel：默认为1，代表一个像素有几个激光脉冲
* Wait (pixels)：the initial wait time before scanning begins.
* Turnaround left*2 (pixels)/Turnaround right*2 (pixels)：the turnaround time for the bidirectional scanner to reverse direction at the end of each line. *2代表考虑两行之间的turnaround总时间

点击Update按钮，会自动读取ScanImage的扫描参数，将Image size、Pulse per pixel、Turnaround left*2(pixels)、Turnaround right*2(pixels)自动配置

但Wait (pixels)需要自己成像测试，才能得知具体的值

可以点击软件的顶栏的Utilities → ROI imaging Simulator，使用ROI imaging Simulator来了解Turnaround和Wait参数对ROI成像效果的影响

![image](assets/image-20260105173024-77kzpyd.png)

ROI imaging Simulator界面

![image](assets/image-20260105173731-4p34f3u.png)

ROI mask输入黑白相间的垂直条纹时，如果Turnaround设置的不对，会输出为斜菱形图案

![image](assets/image-20260105173846-irsgyn4.png)

如果Turnaround输入正确，而Wait输入不正确，输出图案的垂直条纹出现锯齿状边缘

![image](assets/image-20260105174220-2uunfzs.png)

### 加载和保存配置

当配置好AWG Settings和Scanner Settings的参数，可以点击File → Save Config，保存参数设置

![image](assets/image-20260105175526-tefe4yw.png)

要加载已保存的配置，点击Configuration的...按钮

![image](assets/image-20260105175715-xbi85ay.png)

## ROI imaging module 功能使用教程

### FPA imaging

在三光子深层组织成像时，使用FPA imaging可以比conventional imaging，以更低的功率获得更高SNR的图形

![image](assets/image-20260105212107-j6tqj2h.png)

点击FPA imaging按钮，可以一键进入FPA imaging mode

![image](assets/image-20260105212424-cu3pmfu.png)

并且具备自动重建功能，每成像10帧，自动重建完整图形

![FPA_imaging2](assets/FPA_imaging2-20260105213035-hqu35iz.gif)

### Cell segmentation

##### Automatic segmentation

在使用FPA imaging 获得高SNR图像之后，可以使用Cellpose-SAM模型，一键自动识别神经元

![cell_segmentation](assets/cell_segmentation-20260105221002-uj8uj1a.gif)

* norm_blocksize: handle uneven illumination in images，将图像进行分块进行调整对比度
* threshold: balance detection sensitivity and false positive rate, set  higher to get more cells, in range from (0,3]

##### Manual correction

如果对自动识别的效果不满意，可以手动调整分割结果

* 选中细胞，按delete删除
* 滚轮可以放大缩小图片
* 右键可以圈选神经元
* 上下左右键对整体mask进行移动

![manual_correction](assets/manual_correction-20260105221343-t9jy7r7.gif)

##### Adjust ROI mask

点击⚙️按钮，可以打开ROI Mask Settings窗口，具有如下功能

* 设置mask color
* 选择是否显示ROI ID
* 添加矩形/圆形ROI
* 调整ROI功能
  * 排序ROI
  * 拖动ROI
  * 批量删除ROI
  * 删除所有ROI

![image](assets/image-20260105221502-3tyvgxe.png)

##### Dialte ROI mask

设置dialte值，可以让the resulting mask are dilated to accommodate minor tissue displacements

![image](assets/image-20260105221522-23evc7o.png)

##### Save mask and load mask

点击Save mask可以保存mask，保存格式：tif、mat、imageJ ROI.zip

点击Load mask可以加载png、tif、csv、mat、imageJ ROI.zip格式的mask

![image](assets/image-20260105222748-8e4818v.png)

### ROI imging

点击ROI imaging按钮，即可一键进行ROI imaging

点击Abort按钮则取消ROI imaging模式，把激光持续关闭

![image](assets/image-20260105223945-6a9my1j.png)

![ROI_imaging](assets/ROI_imaging-20260105224349-okk3ep1.gif)

### Real-time registration

点击Real-time registration按钮，可以把参考图发送给ScanImage，进行实时配准

![image](assets/image-20260105225202-2z5ltqz.png)

如何使用RIMA进行Real-time registration：

复制ROI_imaging_module_software\+RIMA\RIMAMotionEsitimator.m到ScanImage的安装文件夹下的+scanimage\+components\+motionEstimators文件夹下

点击Select Estimator选择RIMAMotionEsitimator.m

![image](assets/image-20260105225453-yjqb397.png)

## 成像后的数据处理

### 分割通道、去除规律噪声、配准

### 提取钙信号
