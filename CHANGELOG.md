
## 2024.07.30

* 简化变量

  * draw_roi_enable 合并为**app.DrawROI.enable**
  * app.draw.previous_point 改为 **app.UIAxes.UserData.pan_previous_point**
  * seg\_enable、seg\_adjust\_enable 改为**app.Seg.enable、app.Seg.auto_rerun**
* 加载结构图代码完善

  * 加载分割通道前的tif还是分割后的tif

    * 为了支持加载正常成像的代码，也支持加载十分之一开的图像，还是加载分割后的tif比较好
  * 需要支持加载正常成像的代码，也支持加载十分之一开的图像，
  * 支持加载多张图片，也支持加载单张tif
* 由调用自定义的cellpose模块改为matlab官方开发的cellpose

## 2024.04.22
-  🐛 Fix 第一次启动scanimage没开，再开scnaimage，连接需要点击两次
-  🐛 Fix 0.1MHZ修复THG通道（CH3）不显示
-  🐛 Fix 0.1MHz读取修复不能提取非10倍数帧文件的问题
-  🐛 Fix 0.1MHZ 显示图像亮度不断在变
   -  `chanDataRescaled = im2uint8(mat2gray(double(data)))` 改为  `chanDataRescaled = data*10` 
-  🎨 精简和优化0.1MHz重建代码
-  ✨ 加载0.1MHz结构图像：区分单帧和stack图像代码完善
-  ✨ 加载0.1MHz结构图像：Tiff保存和读取代码使用新版

## 2023.11.1 
- 添加细胞分割模块
  - 使用cellpose进行细胞分割
  - 支持圈选细胞