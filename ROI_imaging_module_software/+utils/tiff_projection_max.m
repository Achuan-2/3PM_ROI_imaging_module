function imgMax = tiff_projection_max(imgStack,thresholdMax)
    arguments
        imgStack
        thresholdMax=0.3
    end
    nFrames = size(imgStack,3);
    imgStack_sorted = sort(imgStack, 3, 'descend'); % 每个像素点按时间上的灰度值降序
    imgMaxStack =  imgStack_sorted(:, :, 1:ceil(nFrames*thresholdMax));

    imgMax = utils.tiff_projection_avg(imgMaxStack);
end