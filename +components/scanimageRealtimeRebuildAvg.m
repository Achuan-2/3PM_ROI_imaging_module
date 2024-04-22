

% 用于0.1MHz实时显示scanimage的图片
% Changelogs
% 2023.10.09： 
% 1. 重构代码，把figCh1、figCh2，更改为figChannels{i}，便于重构为函数，方便调用
% 2. 支持检测scanimage的通道数，
% 3. 可以直接关闭改重建通道图而不再弹出
% 4. 重建方式改为平均图
classdef ScanimageRealtimeRebuildAvg < handle
    properties
        hSI = scanimage.SI.empty; % scanimage的变量
        listeners = cell(1,2); % 监听事件

        % 用于绘图
        fig = cell(1,4); % 显示重建图的fig，4个通道
        rebuildFrameChannels = cell(1,4); % 重建的图，4个通道
        imageSize; % 采集图像的大小
        countBufferFrames = 0; % 计算当前已经处理多少帧
        firstDrawFlags = [true,true,true,true]; %是否是第一次显示图
        imageShowHandles = cell(1,4); % 用于figure更新图片不闪烁标题
        bufferChannels = cell(1,4); % channel的buffer，用于取平均图

    end

    methods(Hidden)
        function obj = ScanimageRealtimeRebuildAvg(hSI)
            obj.hSI = hSI;
            obj.imageSize = obj.hSI.hRoiManager.pixelsPerLine;

            % 设置fig位置
            normalizedPositions = {[0.4471 0.5227 0.1594 0.2833],...
                [0.6094 0.5227 0.1594 0.2833],...
                [0.8094 0.5227 0.1594 0.2833],...
                [0.9094 0.5227 0.1594 0.2833]};
                
            % 创建fig，默认不可见
            for iChannel = 1:4
                obj.fig{iChannel} = figure('Visible', 'off').empty;
            end

            % 根据scanimage已打开的channel数量来显示重新fig
            for i = 1:length(obj.hSI.hChannels.channelDisplay) % 有几个Channel
                iChannel = obj.hSI.hChannels.channelDisplay(i); %显示第几个channel
                figPosition =   normalizedPositions{i};
                
                obj.fig{iChannel} = figure('Name',sprintf('Channel %d (Processed)',iChannel),'Visible','On',...
                    'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Units','normalized','Position',figPosition);
                obj.rebuildFrameChannels{iChannel} =  zeros(obj.imageSize, obj.imageSize);
                obj.bufferChannels{iChannel} =  zeros(10,obj.imageSize, obj.imageSize);
            end
           
        end

        function delete(obj)
            % 删除scanimage对象
            obj.hSI = scanimage.SI.empty;

            % 删除监听事件
            cellfun(@delete, obj.listeners);

            % 关闭图窗
            for iChannel =1:4
                if isvalid(obj.fig{iChannel})
                    close(obj.fig{iChannel})
                end
            end
 
        end
    end

    methods

        function listen_to_scanimage(obj)
            if ~isempty(obj.listeners)
                cellfun(@delete, obj.listeners);
            end
            obj.listeners{1} = addlistener(obj.hSI.hUserFunctions, 'frameAcquired', @obj.countFramesAndSaveToBuffer); % scanimage 每采集一帧，事件发生，调用回调函数
            obj.listeners{2} = addlistener(obj.hSI.hUserFunctions, 'acqAbort', @obj.reset); % scanimage当grab结束或focus abort 事件发生，调用回调函数
            disp("scanimage_realtime_process：start listening to scanimage event")
        end

        function reset(obj,~,~)
            obj.countBufferFrames = 0;
            for idx = 1:length(obj.hSI.hChannels.channelDisplay)
                iChannel = obj.hSI.hChannels.channelDisplay(idx);
                obj.rebuildFrameChannels{iChannel} =  zeros(obj.imageSize, obj.imageSize);
            end
            disp("scanimage_realtime_process：本次采集结束！")
        end

        function countFramesAndSaveToBuffer(obj,~,~)
            % scanimage 每取一帧就把其数据处理
            obj.countBufferFrames = obj.countBufferFrames + 1;

            % 平均10帧保存为一张图
            for i = 1:length(obj.hSI.hChannels.channelDisplay)
                channelName = obj.hSI.hChannels.channelDisplay(i); 

                if isvalid(obj.fig{channelName})       
                    obj.processImageChannel(channelIndex = i,channelName=channelName);
                end
            end

        end

        function processImageChannel(obj, options)
            arguments
                obj
                options.channelIndex
                options.channelName
            end
            % 获取当前帧

            channelFrame = single(obj.hSI.hDisplay.lastFrame{options.channelIndex});

            % 对十帧图像进行重建
            nFrame = mod(obj.countBufferFrames,10);
            if nFrame % 1-9帧，进行buffer
                obj.bufferChannels{options.channelName}(nFrame,:,:) = channelFrame;


            else % 如果是第十帧,则buffer完毕取平均
                obj.bufferChannels{options.channelName}(10,:,:) = channelFrame;
                data = obj.bufferChannels{options.channelName};
                
                % adjust contrast accroding to scanimage
                data = obj.data_rescale(data,options.channelIndex); %把int16数据根据lut变为uint8数据
                obj.bufferChannels{options.channelName} = data;
                rebuildFrameData = squeeze(mean(obj.bufferChannels{options.channelName},1));

                % display image
                obj.displayImageChannel(rebuildFrameData,channel = options.channelName);
                % reset obj.bufferChannels
                obj.bufferChannels{options.channelName} = zeros(10,obj.imageSize,obj.imageSize);
                
            end
            
        end
        function displayImageChannel(obj,data,options)
            % 棘手的问题：obj.figCh1和obj.figCh2怎么传参区别
            arguments
                obj
                data
                options.channel
            end
            chanDataRescaled = data; % TODO这一句估计有问题
            % 备注不需要考虑超出255，因为imshow已经限制了[0,255]了
            % 1. im2uint8(mat2gray(double(data))) 对每一帧单独进行归一化，会导致帧与帧之间的变化
            % 2. data
            % 3. data*10



            % 解决标题闪烁的问题: handle = imshow();handle.CData = new_image;
            if obj.firstDrawFlags(options.channel)

                figure(obj.fig{options.channel});
                obj.imageShowHandles{options.channel} = imshow(chanDataRescaled,[0,255],'border','tight','InitialMagnification', 'fit');

                obj.firstDrawFlags(options.channel) = false;
            else
                obj.imageShowHandles{options.channel}.CData= chanDataRescaled;
            end


        end

        function chanDataRescaled = data_rescale(obj, chanData, channel)
            % 根据scanimage的lut显示图片
            lut = single(obj.hSI.hChannels.channelLUT{channel});
            maxVal = single(255);
            chanDataRescaled = uint8((single(chanData) - lut(1)) .* (maxVal / (lut(2)-lut(1))));
        end

    end

end

% test = components.scanimageRealtimeRebuildAvg(hSI);test.listen_to_scanimage()
% 
% delete(test)