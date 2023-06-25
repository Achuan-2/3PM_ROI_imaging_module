function imgMax = tiff_max(filepath,imgStack,thresholdMax)
    nFrames = size(imgStack,3);
    imgStack_sorted = sort(imgStack, 3, 'descend'); % 按灰度值降序
    imgMax =  imgStack_sorted(:, :, 1:ceil(nFrames*thresholdMax));
    utils.tiff_save_avg(filepath,imgMax);
end