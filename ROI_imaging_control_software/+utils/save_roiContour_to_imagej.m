function save_roiContour_to_imagej(roi_contours, zip_filename)
    % roi_contours: 1×n的cell数组，n代表roi数量，每个cell为l×2的矩阵，代表轮廓坐标
    %               坐标按照[y,x]排列，即[row,col]
    % zip_filename: 保存的ImageJ ROI zip文件名
    
    % 创建临时目录存储ROI文件
    temp_dir = tempname;
    mkdir(temp_dir);
    
    try
        % 确定编号的位数
        num_rois = length(roi_contours);
        num_digits = floor(log10(max(1, num_rois))) + 1;
        
        % 为每个轮廓创建ROI文件
        for i = 1:num_rois
            coords = roi_contours{i};
            if isempty(coords)
                continue;
            end
            % 把coords的x和y左边替换，变为[y,x]格式
            coords = coords(:, [2, 1]);
            
            % 首先计算边界框（使用1-based坐标）
            bounds = [min(coords(:, 1)), min(coords(:, 2)), ... % top, left
                max(coords(:, 1)), max(coords(:, 2))];    % bottom, right
            
            % 转换坐标：将所有坐标减去左上角坐标
            coords_rel = coords - [bounds(1), bounds(2)];
            
            % 将边界框转换为0-based坐标
            bounds = bounds - 1;
            
            % 保存单个ROI文件,使用格式化编号（确保排序正确）
            roi_filename = fullfile(temp_dir, sprintf(['ROI_%0', num2str(num_digits), 'd.roi'], i));
            save_single_roi(coords_rel, bounds, roi_filename);
        end
        
        % 创建ZIP文件
        zip(zip_filename, '*', temp_dir);
    catch ME
        rmdir(temp_dir, 's');
        rethrow(ME);
    end
    
    % 清理临时目录
    rmdir(temp_dir, 's');
end

function save_single_roi(coords, bounds, filename)
    % 打开文件
    fid = fopen(filename, 'w', 'ieee-be');
    
    try
        % 写入头部
        fwrite(fid, 'Iout', 'char'); % 魔数
        fwrite(fid, 228, 'int16'); % 版本
        fwrite(fid, 7, 'uint8'); % ROI类型 (7=Freehand)
        fwrite(fid, 0, 'uint8'); % 占位符
        
        % 写入边界框 [top left bottom right]
        % ImageJ的边界框需要使用整数坐标
        fwrite(fid, round([bounds(1) bounds(2) bounds(3) bounds(4)]), 'int16');
        
        % 写入坐标点数量
        n_coords = size(coords, 1);
        fwrite(fid, n_coords, 'uint16');
        
        % 设置ROI选项
        options = 128; % 设置SUB_PIXEL_RESOLUTION选项（与roifile.py一致）
        fwrite(fid, options, 'uint16'); % ROI选项，设为0表示无填充
        
        % 写入64字节header的剩余部分
        fwrite(fid, zeros(1, 64 - 20), 'uint8');
        
        % 写入坐标（不需要再减1，因为已经相对于边界框原点）
        fwrite(fid, round(coords(:, 2)), 'int16'); % X坐标
        fwrite(fid, round(coords(:, 1)), 'int16'); % Y坐标
        
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    % 关闭文件
    fclose(fid);
end