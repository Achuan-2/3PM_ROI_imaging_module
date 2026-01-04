function [avgFrame, maxFrame, stdFrame] = calculateProjections(imageData, frameRange,showFigure)
    % calculateProjections 计算图像堆栈的多种投影
    %   [avgFrame, maxFrame, stdFrame] = calculateProjections(imageData, showFigure, frameRange)
    %
    %   输入参数:
    %     imageData - 包含图像帧的结构体数组，每个元素应有channel1字段
    %     showFigure - 可选参数，是否显示结果图像，默认为false
    %     frameRange - 可选参数，指定用于计算的帧范围，格式为字符串如'1000'或'2:2000'
    %                  不提供或为空时使用所有帧
    %
    %   输出参数:
    %     avgFrame - 平均值投影
    %     maxFrame - 最大值投影
    %     stdFrame - 标准差投影
    
    % 设置默认参数
    if nargin < 2
        frameRange = '';
    end
    if nargin < 3
        showFigure = false;
    end
    
    
    % 获取总帧数
    totalFrames = length(imageData.Data);
    
    % 解析帧范围
    if isempty(frameRange)
        % 使用所有帧
        selectedFrames = 1:totalFrames;
    else
        % 解析帧范围字符串
        if contains(frameRange, ':')
            % 处理包含"end"的情况
            frameRange = strrep(frameRange, 'end', num2str(totalFrames));
            
            % 格式为 'start:end'
            parts = split(frameRange, ':');
            startFrame = str2double(parts{1});
            endFrame = str2double(parts{2});
            selectedFrames = startFrame:endFrame;
        else
            % 格式为单个数字，表示取前N帧
            numFrames = str2double(frameRange);
            selectedFrames = 1:min(numFrames, totalFrames);
        end
        
        % 确保帧范围有效
        selectedFrames = selectedFrames(selectedFrames >= 1 & selectedFrames <= totalFrames);
        if isempty(selectedFrames)
            error('指定的帧范围无效或超出可用帧范围(1-%d)', totalFrames);
        end
    end
    
    % 获取实际使用的帧数
    numFrames = length(selectedFrames);
    
    % 获取第一帧以确定尺寸
    firstFrameIndex = selectedFrames(1);
    frame1 = imageData.Data(firstFrameIndex).channel1;
    
    % 初始化变量
    sumFrames = double(zeros(size(frame1)));
    maxFrame = double(zeros(size(frame1)));
    
    % 第一次遍历：计算总和和最大值
    for idx = 1:numFrames
        i = selectedFrames(idx);
        currentFrame = double(imageData.Data(i).channel1);
        sumFrames = sumFrames + currentFrame;
        maxFrame = max(maxFrame, currentFrame);
    end
    
    % 计算平均值
    avgFrame = sumFrames / numFrames;
    
    % 初始化标准差计算的变量
    sumSquaredDiff = double(zeros(size(frame1)));
    
    % 第二次遍历：计算标准差
    for idx = 1:numFrames
        i = selectedFrames(idx);
        currentFrame = double(imageData.Data(i).channel1);
        diff = currentFrame - avgFrame;
        sumSquaredDiff = sumSquaredDiff + diff.^2;
    end
    
    % 计算标准差
    stdFrame = sqrt(sumSquaredDiff / numFrames);

    % 转置结果以匹配图像显示格式
    avgFrame = avgFrame';
    maxFrame = maxFrame';
    stdFrame = stdFrame';
    
    % 根据需要显示结果
    if showFigure
        figure('Position', [100, 100, 1200, 400]);
        
        % 显示平均投影
        subplot(1, 3, 1);
        imshow(avgFrame',[]);
        title('平均投影 (AVG Projection)');
        
        % 显示最大值投影
        subplot(1, 3, 2);
        imshow(maxFrame',[]);
        title('最大值投影 (MAX Projection)');
        
        % 显示标准差投影
        subplot(1, 3, 3);
        imshow(stdFrame',[]);
        title('标准差投影 (STD Projection)');
        
        % 添加总标题
        sgtitle(['图像投影方式比较 (帧范围: ' num2str(selectedFrames(1)) '-' num2str(selectedFrames(end)) ')']);
    end
end

