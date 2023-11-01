

% 用于0.1MHz实时显示scanimage的图片
% Changelogs
% 2023.10.09： 
% 1. 重构代码，把figCh1、figCh2，更改为figChannels{i}，便于重构为函数，方便调用
% 2. 支持检测scanimage的通道数，
% 3. 可以直接关闭改重建通道图而不再弹出
% 4. 重建方式改为平均图
classdef scanimageRealtimeRebuildAvg < handle
    properties
        hSI = scanimage.SI.empty; % scanimage的变量
        listeners = cell(1,2); % 监听事件

        % 用于绘图
        figChannels = cell(1,4); % 显示重建图的fig，4个通道是为了兼容
        rebuildFrameChannels = cell(1,4); % 重建的图
        imageSize; % 采集图像的大小
        countBufferFrames = 0; % 计算当前已经处理多少帧
        firstDrawFlags = [true,true]; %是否是第一次显示图
        imageShowHandles = cell(1,4); % 用于figure更新图片不闪烁标题

        bufferChannels = cell(1,4); % channel的buffer，用于取平均图

    end

    methods(Hidden)
        function obj = scanimageRealtimeRebuildAvg(hSI)
            obj.hSI = hSI;
            obj.imageSize = obj.hSI.hRoiManager.pixelsPerLine;

            % TODO：这里的位置可以去三光子电脑具体确认下
           
            figPositions = {[10,10,408,408],[540,10,408,408]};

            
            for iChannel = 1:4
                obj.figChannels{iChannel} = figure('Visible', 'off').empty;
            end

            % 根据scanimage的channel数量显示

            for idx = 1:length(obj.hSI.hChannels.channelDisplay)
                iChannel = obj.hSI.hChannels.channelDisplay(idx);
                obj.figChannels{iChannel} = figure('Name',sprintf('Channel %d (Processed)',iChannel),'Visible','On',...
                    'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Tag','image_channel1','Position',figPositions{iChannel});
                obj.rebuildFrameChannels{iChannel} =  zeros(obj.imageSize, obj.imageSize);

                obj.bufferChannels{iChannel} =  zeros(10,obj.imageSize, obj.imageSize);
            end
           
        end

        function delete(obj)
            obj.hSI = scanimage.SI.empty;


            % 删除监听事件
            cellfun(@delete, obj.listeners);

            % 关闭图窗
            for iChannel =1:4
                if isvalid(obj.figChannels{iChannel})
                    close(obj.figChannels{iChannel})
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
            disp("Listen to scanimage event <frameAcquired>")
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

            for idx = 1:length(obj.hSI.hChannels.channelDisplay)
                iChannel = obj.hSI.hChannels.channelDisplay(idx);
                if isvalid(obj.figChannels{iChannel})
                    
                    obj.processImageChannel(channel = iChannel);
                end
            end

        end

        function processImageChannel(obj, options)
            arguments
                obj
                options.channel
            end

            % 获取当前帧
            channelFrame = single(obj.hSI.hDisplay.lastFrame{options.channel});

            % 对十帧图像进行重建
            nFrame = mod(obj.countBufferFrames,10);
            if nFrame % 1-9帧，进行buffer
                obj.bufferChannels{options.channel}(nFrame,:,:) = channelFrame;


            else % 如果是第十帧,则buffer完毕取平均
                obj.bufferChannels{options.channel}(10,:,:) = channelFrame;
                rebuildFrameData = squeeze(mean(obj.bufferChannels{options.channel},1));

                %显示图片
                obj.displayImageChannel(rebuildFrameData,channel = options.channel);

                obj.bufferChannels{options.channel} = zeros(10,obj.imageSize,obj.imageSize);
                
            end
            
        end
        function displayImageChannel(obj,data,options)
            % 棘手的问题：obj.figCh1和obj.figCh2怎么传参区别
            arguments
                obj
                data
                options.channel
            end
            % TODO还不确定是不是乘以10:由于是10张取一张平均图，所以还需要乘10
            data = data*10;
            chanDataRescaled = obj.data_rescale(data,options.channel);


            % 解决标题闪烁的问题: handle = imshow();handle.CData = new_image;
            if obj.firstDrawFlags(options.channel)

                figure(obj.figChannels{options.channel});
                obj.imageShowHandles{options.channel} = imshow(chanDataRescaled,'border','tight','InitialMagnification', 'fit');

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