function varargout = tiff_read(filepath, frame_range, nChannel)
    %tiff_read_volume - 读取Tiff图像的灰度值.
    %
    %   USAGE
    %       imgStack = tiff_read(filepath);           % 读取所有帧，单通道
    %       [imgCh1,imgCh2] = tiff_read(filepath,2); % 读取所有帧，双通道
    %       imgFrame = tiff_read(filepath, 1, 5);    % 读取第5帧，单通道
    %       imgRange = tiff_read(filepath, 1, '1:10');% 读取第1到10帧，单通道
    %
    %   INPUT PARAMETERS
    %       filepath             -   图像文件的路径
    %       nChannel (optional)  -  通道数，默认为1
    %       frame_range (optional)-  帧范围，默认为'none' (全部读取)
    %                                 可以是一个数值，代表读取特定帧
    %                                 可以是字符串 'start:end'，代表读取帧范围
    %
    %   OUTPUT PARAMETERS
    %       imgStack         -   输出图像堆栈或单帧图像
    %                          如果 nChannel > 1, 则输出为 cell 数组，每个 cell 代表一个通道

    arguments
        filepath string;
        frame_range {mustBeValidFrameRange} = 'none'; % 使用验证函数
        nChannel double = 1;
    end

    t = Tiff(filepath, 'r');
    iminfo = imfinfo(filepath);
    num_frame = length(iminfo);
    w = iminfo(1).Width; % 从imfinfo获取图像宽度
    h = iminfo(1).Height; % 从imfinfo获取图像高度


    if strcmp(frame_range, 'none') % 读取所有帧
        imgStack = zeros(h, w, num_frame, class(read(t))); % 预分配所有帧的空间
        setDirectory(t, 1); % 确保回到第一帧 (虽然打开时默认是第一帧，但为了保险)
        for i = 1:num_frame
            setDirectory(t, i); % 设置当前读取的目录为第i帧 (Tiff目录索引从1开始)
            imgStack(:, :, i) = read(t);
        end

    elseif isnumeric(frame_range) && isscalar(frame_range) % 读取单帧
        frame_index = round(frame_range); % 确保帧索引是整数
        if frame_index < 1 || frame_index > num_frame
            error('指定的帧索引超出范围 (1-%d).', num_frame);
        end
        imgStack = zeros(h, w, 1, class(read(t))); % 预分配单帧空间
        setDirectory(t, frame_index);
        imgStack(:, :, 1) = read(t);

    elseif ischar(frame_range) || isstring(frame_range) % 读取帧范围
        range_str = char(frame_range); % 转换为 char 方便处理
        colon_index = strfind(range_str, ':');
        if isempty(colon_index)
            error('帧范围格式不正确，应为 "start:end".');
        end

        start_str = range_str(1:colon_index-1);
        end_str = range_str(colon_index+1:end);

        if isempty(start_str)
            start_frame = 1;
        else
            start_frame = str2double(start_str);
            if isnan(start_frame) || start_frame < 1
                error('帧范围起始值无效.');
            end
        end

        if isempty(end_str)
            end_frame = num_frame;
        else
            end_frame = str2double(end_str);
            if isnan(end_frame) || end_frame > num_frame
                error('帧范围结束值无效.');
            end
        end

        if start_frame > end_frame
            error('帧范围起始值不能大于结束值.');
        end

        frame_indices = start_frame:end_frame;
        num_frames_to_read = length(frame_indices);
        imgStack = zeros(h, w, num_frames_to_read, class(read(t))); % 预分配帧范围的空间

        for i = 1:num_frames_to_read
            setDirectory(t, frame_indices(i));
            imgStack(:, :, i) = read(t);
        end

    else
        error('frame_range 参数类型不正确，应为 "none", 数值或 "start:end" 字符串.');
    end

    t.close();

    % 处理通道输出
    if nChannel == 1
        varargout{1} = imgStack;
    else
        varargout = cell(1, nChannel);
        for iChannel = 1:nChannel
            varargout{iChannel} = imgStack(:, :, iChannel:nChannel:end);
        end
    end
end

function mustBeValidFrameRange(frame_range)
    if ~(strcmp(frame_range, 'none') || ...
         (isnumeric(frame_range) && isscalar(frame_range)) || ...
         (ischar(frame_range) || isstring(frame_range)))
        error('frame_range 参数必须为 "none", 数值或 "start:end" 字符串.');
    end
    if (ischar(frame_range) || isstring(frame_range)) && ~(strcmp(frame_range, 'none'))
        range_str = char(frame_range);
        if ~isempty(range_str)
            colon_count = sum(range_str == ':');
            if colon_count > 1
                error('帧范围字符串格式不正确，最多只能有一个冒号.');
            end
             if colon_count == 1
                parts = split(range_str,':');
                if length(parts) ~= 2
                    error('帧范围字符串格式不正确，应为 "start:end".');
                end
                start_str = parts{1};
                end_str = parts{2};

                if ~isempty(start_str) && isnan(str2double(start_str))
                     error('帧范围起始值无效.');
                end
                 if ~isempty(end_str) && isnan(str2double(end_str))
                     error('帧范围结束值无效.');
                end
             elseif colon_count == 0 && isnan(str2double(range_str)) && ~strcmp(range_str, 'none')
                 error('帧范围字符串格式不正确，应为 "start:end" 或 "none".');
             end
        end
    end
end
