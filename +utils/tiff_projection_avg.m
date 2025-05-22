function imgAvg = tiff_projection_avg(imgStack)
    % 获取输入图像栈的数据类型
    inputType = class(imgStack);
    
    % 计算平均值
    imgAvg = mean(double(imgStack),3);
    
    % 根据输入类型转换输出类型
    switch inputType
        case 'uint8'
            imgAvg = uint8(imgAvg);
        case 'uint16'
            imgAvg = uint16(imgAvg);
        case 'int16'
            imgAvg = int16(imgAvg);
        case 'single'
            imgAvg = single(imgAvg);
        otherwise
            % 如果是其他类型，保持默认的双精度
            imgAvg = imgAvg;
    end
end
