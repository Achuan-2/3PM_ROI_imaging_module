function imgStackCombine =  subframe_rebuild(imgStack)
    % 获取输入的数据类型
    inputDataType = class(imgStack);
    % 每十帧合并为一帧
    nFrames = size(imgStack,3); % 获取总帧数
    imageSize = size(imgStack,1);
    realFrames = floor(nFrames/10); % 需要考虑帧不为10倍整数的情况
    imgStackCombine = zeros(imageSize, imageSize,realFrames);
    
    for i = 1:realFrames
        start_frame = (i-1)*10+1;
        end_frame = i*10;
        imgStackCombine(:,:,i) = mean(double(imgStack(:,:,start_frame:end_frame)),3);
        
    end
    switch inputDataType
        case 'uint8'
            imgStackCombine = im2uint8(mat2gray(double(imgStackCombine)));
            
        case 'uint16'
            imgStackCombine = im2uint16(mat2gray(double(imgStackCombine)));
            
            
        case 'int16'
            imgStackCombine = im2uint16(mat2gray(double(imgStackCombine)));
            
    end
    
end
