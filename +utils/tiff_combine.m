function imgStackCombine =  tiff_combine(imgStack)
    nFrames = size(imgStack,3);
    imageSize = size(imgStack,1);
    realFrames = nFrames/10;
    imgStackCombine = zeros(imageSize, imageSize,realFrames );

    % 把10帧图片合并为一帧，合并的规则为取第i帧的i:10:512列
    for iframe = 1:realFrames
        temp_frame =  zeros(imageSize, imageSize);
        count = 1;
        for i = 7:16
            img = imgStack(:, :, 10*(iframe-1)+count);
            start = i;
            if start>10
                start = start -10;
            end
            fill_col = start:10:imageSize;
            temp_frame(:,fill_col) = img(:,fill_col);

            count = count +1;
        end
        imgStackCombine(:,:,iframe) = temp_frame;
    end
end