% 实时显示scanimage的图片
classdef scanimage_realtime_process < handle
    properties
        hSI = scanimage.SI.empty;
        figCh1;
        figCh2;
    end

    properties
        buffer_ch1;
        buffer_ch2;
        processData;
        imageShowHandleCh1;
        imageShowHandleCh2;
        listeners;
        countBufferFrames = 0
        firstDraw = 1;

    end
    properties
        imageSize;
        rebuildFrameCH1;
        rebuildFrameCH2;
        colNum;
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
            obj.rebuildFrameCH1 =  zeros(obj.imageSize, obj.imageSize);
            obj.rebuildFrameCH2 =  zeros(obj.imageSize, obj.imageSize);
            disp("采集结束！")
        end

        function countFramesAndSaveToBuffer(obj,~,~)
            % scanimage 每取一帧就把其数据存储
            obj.countBufferFrames = obj.countBufferFrames + 1;
            obj.processImage();

        end

        function processImage(obj)
            % 获取当前帧
            ch1Frame = single(obj.hSI.hDisplay.lastFrame{1});
            ch2Frame = single(obj.hSI.hDisplay.lastFrame{2});

            % 对十帧图像进行重建
            start_f = mod(obj.countBufferFrames,10);
            if start_f == 0 % 如果是第十帧
                start_col = 9*obj.colNum +1 ;
                obj.rebuildFrameCH1(:,start_col:end) = ch1Frame(:,start_col:end);
                obj.rebuildFrameCH2(:,start_col:end) = ch2Frame(:,start_col:end);
                
                %显示图片
                obj.displayImage();
                % 删除
                obj.rebuildFrameCH1 =  zeros(obj.imageSize, obj.imageSize);
                obj.rebuildFrameCH2 =  zeros(obj.imageSize, obj.imageSize);

            else % 1-9帧
                start_col = (start_f-1)*obj.colNum +1 ;
                fill_col = start_col:start_col+obj.colNum-1;
                obj.rebuildFrameCH1(:,fill_col) = ch1Frame(:,fill_col);
                obj.rebuildFrameCH2(:,fill_col) = ch2Frame(:,fill_col);
            end
            
            

        end


        function chanDataRescaled = data_rescale(obj, chanData, channel)
            % 根据scanimage的lut显示图片
            lut = single(obj.hSI.hChannels.channelLUT{channel});
            maxVal = single(255);
            chanDataRescaled = uint8((single(chanData) - lut(1)) .* (maxVal / (lut(2)-lut(1))));
        end


        function displayImage(obj)
            chan1DataRescaled = obj.data_rescale(obj.rebuildFrameCH1,1);
            chan2DataRescaled = obj.data_rescale(obj.rebuildFrameCH2,2);
            % 解决标题闪烁的问题,handle = imshow();handle.CData = new_image;
            if obj.firstDraw == 1
                figure(obj.figCh1);
                obj.imageShowHandleCh1 = imshow(chan1DataRescaled,'border','tight','InitialMagnification', 'fit');
                figure(obj.figCh2);
                obj.imageShowHandleCh2 = imshow(chan2DataRescaled,'border','tight','InitialMagnification', 'fit');
                obj.firstDraw = 0;
            else
                obj.imageShowHandleCh1.CData=chan1DataRescaled;
                obj.imageShowHandleCh2.CData=chan2DataRescaled;
            end
        end
    end
    methods(Hidden)
        function obj = scanimage_realtime_process(hSI)
            obj.hSI = hSI;
            obj.figCh1 = figure('Name','Channel 1(Processed)','Visible','On',...
                            'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Tag','image_channel1','Position',[10,10,408,408]);

            obj.figCh2 = figure('Name','Channel 2(Processed)','Visible','On',...
                            'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Tag','image_channel2','Position',[540,10,408,408]);

            obj.imageSize = obj.hSI.hRoiManager.pixelsPerLine;
            obj.rebuildFrameCH1 =  zeros(obj.imageSize, obj.imageSize);
            obj.rebuildFrameCH2 =  zeros(obj.imageSize, obj.imageSize);
            obj.colNum = floor(obj.imageSize/10);
        end

        function delete(obj)
            obj.hSI = scanimage.SI.empty;
            obj.buffer_ch1 = []; 
            obj.buffer_ch2 = []; 
            if iscell(obj.listeners)
                cellfun(@delete, obj.listeners);
            end
            try
                close(obj.figCh1);
                close(obj.figCh2);
            catch
            end
        end


    end
end

% test = scanimage_realtime_process(hSI)
% test.listen_to_scanimage()
% delete(test)