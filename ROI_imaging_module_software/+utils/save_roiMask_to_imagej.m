function save_roiMask_to_imagej(roi_mask, zip_filename)
    % 创建临时目录存储ROI文件
    temp_dir = tempname;
    mkdir(temp_dir);

    try
        % 获取unique labels (排除背景0)
        labels = unique(roi_mask);
        labels(labels == 0) = [];
        % 确定编号的位数
        num_labels = length(labels);
        num_digits = floor(log10(num_labels)) + 1;
        % 为每个label创建ROI文件
        for i = 1:length(labels)
            label = labels(i);
            binary_mask = roi_mask == label;

            % 获取边界轮廓
            B = bwboundaries(binary_mask, 'noholes');

            if isempty(B)
                continue;
            end

            % 获取主轮廓
            coords = B{1};

            % 首先计算边界框（使用1-based坐标）
            bounds = [min(coords(:, 1)), min(coords(:, 2)), ... % top, left
                          max(coords(:, 1)), max(coords(:, 2))]; % bottom, right

            % 转换坐标：将所有坐标减去左上角坐标
            coords = coords - [bounds(1), bounds(2)];

            % 现在将边界框转换为0-based坐标
            bounds = bounds - 1;

            % 保存单个ROI文件,使用格式化编号（确保排序正确）
            roi_filename = fullfile(temp_dir, sprintf(['ROI_%0', num2str(num_digits), 'd.roi'], i));
            save_single_roi(coords, bounds, roi_filename);
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
        fwrite(fid, 227, 'int16'); % 版本
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
