function [imgStackCh1,imgStackCh2] =  tiff_split(fullpath)
    fileName = fullpath;
    info = imfinfo(fileName); % 获取图像信息
    nFramesTwice = numel(info); % 获取帧数
    nFrames = nFramesTwice/2;
    imageSize = info(1).Height;
    % ch1
    imgStackCh1 = zeros(imageSize,imageSize, nFrames); % 构建一个空白的image stack序列
    for k = 1:nFrames
        imgStackCh1(:, :, k) = imread(fileName, 2*k-1, 'Info', info);
    end

    % ch2
    imgStackCh2 = zeros(imageSize,imageSize, nFrames); % 构建一个空白的image stack序列
    for k = 1:nFrames
        imgStackCh2(:, :, k) = imread(fileName, 2*k, 'Info', info);
    end
end