function tiff_split(inputFilePath, numChannels, options)
    % tiff_split - 将多通道TIFF文件分割为单通道TIFF文件，并可选择去除涟漪噪声
    %
    % 输入:
    %   inputFilePath   - 输入TIFF文件的完整路径 (字符串)
    %   numChannels     - 要分割的通道数 (正整数)
    %
    % 名称-值对参数:
    %   'FolderProcessed' - 存放分割后文件的文件夹路径 (字符串, 可选)
    %                       如果是相对路径，则作为输入文件目录的子文件夹
    %                       如果是绝对路径，则直接使用该路径
    %                       默认为输入文件目录下的'Processed'子文件夹
    %   'AvgOutput'       - 是否计算并保存平均投影 (逻辑值, 可选, 默认为true)
    %   'rippleNoise'     - 去除涟漪噪声的阈值 (数值, 可选, 默认为700)
    %                       将小于此阈值的像素值设为0，用于去除低强度噪声
    %   'progressDlg'        - progressDlg句柄，用于显示进度条 (可选)
    %
    % 示例:
    %   tiff_split('input.tif', 3)
    %   tiff_split('input.tif', 3, 'FolderProcessed', 'output_folder')
    %   tiff_split('input.tif', 3, 'FolderProcessed', 'C:\absolute\path\to\output')
    %   tiff_split('input.tif', 3, 'AvgOutput', true)
    %   tiff_split('input.tif', 3, 'rippleNoise', 500)
    
    
    arguments
        inputFilePath (1,1) string
        numChannels (1,1) {mustBePositive, mustBeInteger}
        options.FolderProcessed (1,1) string = "Processed"
        options.AvgOutput (1,1) logical = true
        options.rippleNoiseEnable =  true
        options.rippleNoise = 700
        options.progressDlg = []
    end
    
    % 获取输入文件的目录
    [inputDir, inputName, inputExt] = fileparts(inputFilePath);
    filename = strcat(inputName,inputExt);
    % 判断文件是否存在
    if ~isfile(inputFilePath)
        throw(MException('tiff_split:FileNotFound', 'Input file not found: %s', filename));
    end
    % 获取输入文件大小
    
    fileInfo = dir(inputFilePath);
    inputFileSize = fileInfo.bytes;
    % 决定是否使用BigTiff (基于每个通道的估计大小)
    useBigTiff = (inputFileSize/numChannels) > 3.9 * 1024^3; % threshold: 3.9GB
    
    % 判断FolderProcessed是否为绝对路径
    if isabs(options.FolderProcessed)
        folderProcessed = options.FolderProcessed;
    else
        folderProcessed = fullfile(inputDir, options.FolderProcessed);
    end
    
    % 创建输出文件夹（如果不存在）
    if ~exist(folderProcessed, 'dir')
        mkdir(folderProcessed);
    end
    
    % 获取TIF文件信息并验证
    info = imfinfo(inputFilePath);
    numFrames = numel(info);
    if numFrames <= numChannels
        warning("Tiff的帧数小于待分割的通道数")
        return
    end

    % --- 新增：提前读取元数据 ---
    tiffMetaData = utils.tiff_read_tag(inputFilePath);
    % 如果启用了去涟漪噪声，则修改元数据以反映uint16类型
    if options.rippleNoiseEnable
        tiffMetaData.BitsPerSample = 16;
        tiffMetaData.SampleFormat = Tiff.SampleFormat.UInt;
    end
    % 提取分辨率和描述
    resolution = [];
    if isfield(tiffMetaData,'XResolution')
        resolution = tiffMetaData.XResolution;
    end
    description = [];
    if isfield(tiffMetaData,'ImageDescription')
        description = tiffMetaData.ImageDescription;
    end
    % --- 结束新增 ---

    % 初始化进度显示
    if isempty(options.progressDlg)
        % 使用 waitbar
        waitbarHandle = waitbar(0, 'Processing...', 'Name', sprintf('TIFF Split Progress: %s',filename), 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
        setappdata(waitbarHandle, 'canceling', 0)
    else
        progressDlg_messages = options.progressDlg.Message;
    end
    
    % 打开输入文件
    inputTiff = Tiff(inputFilePath, 'r');
    cleanupObj = onCleanup(@() close(inputTiff)); % 确保输入文件被关闭
    
    % --- 修改：创建 Fast Tiff Writers ---
    TiffWriters = cell(1, numChannels);
    for ch = 1:numChannels
        outputFilePath = fullfile(folderProcessed, sprintf('%s_ch%d%s', inputName, ch, inputExt));
        
        % 创建输出文件写入器
        try
            if useBigTiff
                % 使用BigTiff格式存储输出文件
                TiffWriters{ch} = Fast_BigTiff_Write(outputFilePath, resolution, 0, description); % 假设第三个参数为0
            else
                % 使用标准Tiff格式存储输出文件
                TiffWriters{ch} = Fast_Tiff_Write(outputFilePath, resolution, 0, description); % 假设第三个参数为0
            end
            % 设置元数据（如果写入器支持） - Fast_Tiff_Write可能在构造时处理了基本标签
            % 如果需要设置更多标签，可能需要调用写入器对象的其他方法（此处未显示）
            % 例如： TiffWriters{ch}.SetTag(tiffMetaData); % 假设有这样的方法
        catch ME
            % 清理已打开的写入器
            for k=1:ch-1
                if ~isempty(TiffWriters{k})
                    close(TiffWriters{k});
                end
            end
            close(inputTiff); % 关闭输入文件
            if ~isempty(options.progressDlg)
                 options.progressDlg.Value = 1; % 关闭进度条
            elseif exist('waitbarHandle', 'var') && ishandle(waitbarHandle)
                delete(waitbarHandle);
            end
            rethrow(ME); % 重新抛出错误
        end
    end
    % --- 结束修改 ---
    
    % 初始化累加器和帧计数器
    accumulators = cell(1, numChannels);
    frameCounts = zeros(1, numChannels);
    % --- 移除：isFirstFrameForChannel 不再需要 ---
    % isFirstFrameForChannel = true(1, numChannels); 
    
    % 处理每一帧
    % --- 移除：tiffMetaData 在循环外读取 ---
    % tiffMetaData = struct(); 
    for frameIdx = 1:numFrames
        % 检查是否取消
        cancelled = false;
        if isempty(options.progressDlg)
            if getappdata(waitbarHandle, 'canceling')
                disp('Operation canceled by user');
                cancelled = true;
            end
        else
            if options.progressDlg.CancelRequested
                cancelled = true;
            end
        end
        if cancelled
             % 如果取消，确保关闭所有写入器
            cellfun(@(x) closeIfNeeded(x), TiffWriters);
            if exist('waitbarHandle', 'var') && ishandle(waitbarHandle)
                 delete(waitbarHandle);
            end
            break; % 跳出循环
        end

        inputTiff.setDirectory(frameIdx);
        frame = inputTiff.read();
        channelIdx = mod(frameIdx - 1, numChannels) + 1;
        
        % remove ripple noise
        if options.rippleNoiseEnable
            frame(frame<options.rippleNoise) = 0;
            frame = uint16(frame);
        end
        
        % --- 修改：使用 Fast Tiff Writer 写入 ---
        % 移除标签设置逻辑
        % if isempty(fieldnames(tiffMetaData)) ... end
        % if isFirstFrameForChannel(channelIdx) ... else ... end
        
        % 写入帧 (注意：示例代码使用了转置 img'，这里保持 frame 不变以匹配原始逻辑)
        % 如果 Fast_Tiff_Write 需要转置，则应改为 TiffWriters{channelIdx}.WriteIMG(frame');
        TiffWriters{channelIdx}.WriteIMG(frame'); 
        
        % --- 移除：writeDirectory() 由 Fast_Tiff_Write 处理 ---
        % if frameIdx ~= numFrames ... end 
        % --- 结束修改 ---

        % 累加图像并增加帧计数
        if options.AvgOutput
            if isempty(accumulators{channelIdx})
                accumulators{channelIdx} = single(frame);
            else
                accumulators{channelIdx} = accumulators{channelIdx} + single(frame);
            end
            frameCounts(channelIdx) = frameCounts(channelIdx) + 1;
        end
        
        % 更新进度显示
        if isempty(options.progressDlg)
            waitbar(frameIdx / numFrames, waitbarHandle, sprintf('Processing: %d/%d', frameIdx, numFrames));
        else
            options.progressDlg.Message = sprintf('%s丨 Spliting [%d/%d]', progressDlg_messages,frameIdx, numFrames);
            options.progressDlg.Value = frameIdx/numFrames;
        end
    end
    
    % 完成进度显示
    if isempty(options.progressDlg) && exist('waitbarHandle', 'var') && ishandle(waitbarHandle)
        delete(waitbarHandle);
    end

    % --- 修改：关闭所有输出文件写入器 ---
    cellfun(@(x) closeIfNeeded(x), TiffWriters);
    % --- 结束修改 ---
    
    % 如果需要，计算并保存平均投影
    if options.AvgOutput && ~cancelled % 仅在未取消时计算平均值
        for i = 1:numChannels
            % 检查是否有帧被处理
            if frameCounts(i) > 0
                avgFilename = sprintf('%s_ch%d_%d_Frames_AVG.tif', inputName, i, frameCounts(i));
                enhanceFilename = sprintf('%s_ch%d_%d_Frames_AVG_EnhanceContrast.tif', inputName, i, frameCounts(i));
                
                % 计算平均投影
                imgStackAvg = accumulators{i} / frameCounts(i);
                if options.rippleNoiseEnable
                    imgStackAvg = uint16(imgStackAvg);
                else
                    % 如果原始数据不是int16，这里可能需要调整
                    imgStackAvg = cast(imgStackAvg, info(1).SampleFormat); % 尝试使用原始格式
                    if strcmp(info(1).SampleFormat,'uint16') % 确保与原始匹配
                         imgStackAvg = uint16(imgStackAvg);
                    elseif strcmp(info(1).SampleFormat,'int16')
                         imgStackAvg = int16(imgStackAvg);
                    % 添加其他可能的类型转换
                    end

                end
                
                
                % 保存平均投影 (使用原始的 tiff_save，因为它处理标签)
                % 注意：这里的 tiffMetaData 可能已被修改为 uint16（如果去噪启用）
                % 如果希望平均投影保留原始位深，需要传递未经修改的元数据
                utils.tiff_save(imgStackAvg, fullfile(folderProcessed, avgFilename), tiffMetaData);
                
                % 自动调整对比度并保存
                utils.tiff_save(imadjust(imgStackAvg), fullfile(folderProcessed, enhanceFilename), tiffMetaData);
            end
        end
    end
end

% --- 移除：generate_tagstruct 不再直接使用 ---
% function tagstruct = generate_tagstruct(input_img) ... end

% ... isabs function ...

% --- 新增：辅助函数以安全关闭写入器 ---
function closeIfNeeded(writerObj)
    if ~isempty(writerObj) && isvalid(writerObj) % 检查对象是否有效
        try
            close(writerObj);
        catch ME
            warning('Failed to close Tiff writer: %s', ME.message);
        end
    end
end
% --- 结束新增 ---

function result = isabs(path)
    % 判断路径是否为绝对路径
    if ispc
        % Windows系统
        result = ~isempty(regexp(path, '^[a-zA-Z]:\\', 'once')) || ...
            ~isempty(regexp(path, '^\\\\', 'once'));
    else
        % Unix-like系统 (包括 macOS)
        result = startsWith(path, '/');
    end
end
