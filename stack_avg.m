input_path = "D:\SynologyDrive\Microscope-3PM\JixiongSu\AES\20240920_blood\Processed\file_00006_ch1.tif";
imgStack = tiff_read(input_path);

% 获取输入图像的大小
[height, width, numFrames] = size(imgStack);

% 获取标签
t = Tiff(input_path, 'r');
tagstruct = struct();
try
    tagstruct.XResolution = t.getTag('XResolution');
    tagstruct.YResolution = tagstruct.XResolution;
catch
    
end

% 确定新的帧数
newNumFrames = floor(numFrames / 10);

% 初始化新的图像堆栈
newImgStack = zeros(height, width, newNumFrames, 'like', imgStack);

% 循环遍历每一组10帧，计算平均值
imgStack = double(imgStack); 
for k = 1:newNumFrames
    startIdx = (k-1)*10 + 1;
    endIdx = k*10;
    newImgStack(:,:,k) = uint16(mean(imgStack(:,:,startIdx:endIdx), 3));
end


% 使用fileparts解析输入路径
[pathstr, name, ext] = fileparts(input_path);

% 生成输出文件名
output_name = strcat(name,'_stackavg',ext);

% 生成输出路径
output_path = fullfile(pathstr, output_name);

% 将 newImgStack 保存为 tiff 文件，每一帧分别写入
tiff_save(newImgStack,output_path,tagstruct);