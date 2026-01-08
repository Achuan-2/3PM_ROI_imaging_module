function averageImage = avg_big_tiff(filePath)
    tifInfo = imfinfo(filePath);
    numFrames = numel(tifInfo);
    sumImage = [];
    % 打开tif文件
    tiffObj = Tiff(filePath, 'r');
    
    for frame = 1:numFrames
        % 读取当前帧
        tiffObj.setDirectory(frame);
        currentFrame = tiffObj.read();
    
        % 初始化sumImage矩阵
        if isempty(sumImage)
            sumImage = zeros(size(currentFrame), 'double');
        end
    
        % 累加到总和矩阵
        sumImage = sumImage + double(currentFrame);
   
    end
    
    % 关闭tif文件
    tiffObj.close();
    
    % 计算平均图像
    averageImage = sumImage / numFrames;
    averageImage = uint16(averageImage);
end