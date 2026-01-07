classdef ROIImagingModule_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        FileMenu                      matlab.ui.container.Menu
        SaveConfigMenu                matlab.ui.container.Menu
        LoadConfigMenu                matlab.ui.container.Menu
        SettingsMenu                  matlab.ui.container.Menu
        AWGSettingsMenu               matlab.ui.container.Menu
        AWGSimulateModeMenu           matlab.ui.container.Menu
        ScannerSettingsMenu           matlab.ui.container.Menu
        ROIMaskSettingsMenu           matlab.ui.container.Menu
        PowerCaculateMenu             matlab.ui.container.Menu
        UtilitiesMenu                 matlab.ui.container.Menu
        AWGControlMenu                matlab.ui.container.Menu
        ROIImagingSimulatorMenu       matlab.ui.container.Menu
        DataprocessMenu               matlab.ui.container.Menu
        TiffProcessMenu               matlab.ui.container.Menu
        SignalExtractionMenu          matlab.ui.container.Menu
        HelpMenu                      matlab.ui.container.Menu
        GithubMenu                    matlab.ui.container.Menu
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        StructureImagingPanel         matlab.ui.container.Panel
        ConventionalimagingButton     matlab.ui.control.Button
        Laser1on9offButton            matlab.ui.control.Button
        StructureImagingLamp          matlab.ui.control.Lamp
        HardwareSettingsPanel         matlab.ui.container.Panel
        AWGSimulateButton             matlab.ui.control.StateButton
        ScanimageButton               matlab.ui.control.StateButton
        ConfigurationFileEditField    matlab.ui.control.EditField
        ConfigurationEditFieldLabel   matlab.ui.control.Label
        AdvancedSettingsOpenButton    matlab.ui.control.Button
        ConfigFileSelectButton        matlab.ui.control.Button
        isConnectedLabel              matlab.ui.control.Label
        AWGstatusLabel                matlab.ui.control.Label
        AwgConnectButton              matlab.ui.control.Button
        ROIImagingPanel               matlab.ui.container.Panel
        RealtimeregistrationButton    matlab.ui.control.Button
        ChannelDropDown_2             matlab.ui.control.DropDown
        ROIImagingLamp                matlab.ui.control.Lamp
        AbortButton                   matlab.ui.control.Button
        LaserROIImagingButton         matlab.ui.control.Button
        ManualCorrectionPanel         matlab.ui.container.Panel
        ShowROImaskLabel              matlab.ui.control.Label
        ROIMaskSettingsButton         matlab.ui.control.Button
        SavemaskButton                matlab.ui.control.Button
        LoadmaskButton                matlab.ui.control.Button
        ROIdilateSpinner              matlab.ui.control.Spinner
        ROIdilateLabel                matlab.ui.control.Label
        MaskOnCheckBox                matlab.ui.control.CheckBox
        CellSegmentationPanel         matlab.ui.container.Panel
        norm_blocksizeEditField       matlab.ui.control.NumericEditField
        norm_blocksizeEditFieldLabel  matlab.ui.control.Label
        StructureTypeDropDown         matlab.ui.control.DropDown
        LoadSegImageButton            matlab.ui.control.Button
        RunmodelButton                matlab.ui.control.Button
        thresholdSpinner              matlab.ui.control.Spinner
        thresholdSpinnerLabel         matlab.ui.control.Label
        RightPanel                    matlab.ui.container.Panel
        ContrastSlider                matlab.ui.control.RangeSlider
        ContrastSliderLabel           matlab.ui.control.Label
        FrameSliderLabel              matlab.ui.control.Label
        FrameSlider                   matlab.ui.control.Slider
        Label                         matlab.ui.control.Label
        DropDown                      matlab.ui.control.DropDown
        UIAxesHomeButton              matlab.ui.control.Button
        ROIRatioEditField             matlab.ui.control.NumericEditField
        ROIratioEditFieldLabel        matlab.ui.control.Label
        ROIsEditField                 matlab.ui.control.NumericEditField
        ROIsEditFieldLabel            matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end


    properties (Access = public)
        awgSimulateState = false; % awg是否使用模拟模式
        % Sub APP
        AwgSettingsApp;% sub-app for awg settings
        ScannerSettingsApp; % sub-app for scanner settings
        AwgControlApp;
        SimulationApp;
        PowerCaculateAPP;
        ROIMaskSettingsApp;
        % Data process app
        SignalExtractionApp;

        roiMask % Dilate之后

        % AWG
        awgDevice= ividev.NIFGEN.empty; % AWG Device Object, default:empty

        % Scaniamge变量
        hSI = scanimage.SI.empty;
        hSICtl = scanimage.SIController.empty;

        % components
        StructureRebuilder = components.ScanimageRealtimeRebuildAvg.empty;%监听scanimage进行1/10成像
        DrawROI = components.DrawROI.empty; %  手动圈选ROI模块
        Seg =components.Segmentation.empty;
    end




    % path and folder
    properties
        folder; % app folder
        lastStructureImagepath = '';  % save last selected path of structure
        lastRoiMaskPath= ''; % save last selected path of roi mask
        lastConfigPath = ''; % save last selected path of config file
        last_seg_tiff_folder = ''; % save last selected path of avg tif file
        seg_img_layer;
        seg_img_stack;
        img_avg_Ch1;% Description
        img_avg_Ch2;
        img_seg_data; % 用于分割的图像数据
        img_seg_filename;
        img_seg_fname % Description
    end

    % listener
    properties (Access = private)
        structureListener = event.listener.empty;% listener for structure imaging
        
        img_seg_ext
    end

    % AWG Settings,Constant =true 让外部可以直接访问
    properties (Access = public)
        defaultConfig = struct();
        waveformConfig = struct();
        scannerConfig = struct();
        roiStyleConfig = struct();
        PowerCaculatConfig = struct();
    end

    % 配准
    properties (Access=public)
        refImg;
    end


    methods (Access = private)
        function windowButtonDown(app, ~, ~)
            if ~isempty(app.DrawROI)

                currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
                x = currentPosition(1,1);
                y = currentPosition(1,2);

                if x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                        y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)

                    % 强制平移模式下，当左键点击时，进入平移状态（按空格+左键）
                    if app.UIFigure.UserData.forcePanMode && strcmp(app.UIFigure.SelectionType, 'normal')
                        app.UIFigure.UserData.activeAxes.UserData.status = "axes_paning";
                        app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
                        return;
                    end

                    switch app.UIFigure.SelectionType
                        case 'normal' % 左键点击
                            % 可取消当前绘制
                            if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                                app.DrawROI.handroi_cancel();
                            end
                            app.UIFigure.UserData.CtrlPressed = false;
                            app.DrawROI.select_roi(x, y);
                            % 如果正在添加规则ROI，不进入平移模式
                            if ~app.DrawROI.is_drag_active() && ~app.DrawROI.is_roi_editing() && ~app.DrawROI.is_adding_regular_roi()
                                app.UIFigure.UserData.activeAxes.UserData.status = "axes_paning";
                                app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
                            end
                        case 'alt' % 代表 Ctrl+ 左键，或者单击右键；
                            if app.UIFigure.UserData.CtrlPressed % Ctrl + Click 删除ROI
                                app.DrawROI.delete_roi(x, y);
                            else % 右键点击，开始绘制ROI
                                % 只有当前轴允许绘制时才开始绘制
                                if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "idle") && app.DrawROI.drawing_enabled(app.DrawROI.active_axes_index)
                                    app.DrawROI.handroi_start(x, y);
                                end
                            end
                        case 'open' % 双击鼠标左键
                            % 检查是否点击在某个ROI上，如果是，则开始编辑该ROI
                            if app.DrawROI.is_adding_regular_roi()
                                app.DrawROI.finish_adding_regular_roi(true);
                            else
                                app.DrawROI.start_edit_roi(x, y);
                            end

                        case 'extend' % 代表 Shift+ 左键、鼠标中键或左右键一起按
                            return
                    end
                end
            end
        end

        function windowMotion(app, ~, ~)
            if isempty(app.UIFigure.UserData.activeAxes)
                return;
            end
            if isempty(app.DrawROI)
                return;
            end

            % 判断鼠标是否在UIAxes内

            currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);

            if  x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                    y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)
                app.UIFigure.UserData.mouseInAxes = true;
                switch app.UIFigure.UserData.activeAxes.UserData.status
                    case "axes_paning"
                        % 如果正在添加ROI，则不执行平移
                        % if ~app.DrawROI.is_adding_regular_roi()
                        app.pan_move();
                        % end
                    case "handroi_drawing"
                        if ~isempty(app.DrawROI)
                            app.DrawROI.handroi_draw(x, y);
                        end
                    otherwise
                        % 使用DrawROI的拖拽方法
                        if ~isempty(app.DrawROI)
                            app.DrawROI.drag_move(x, y);
                        end
                end
            else
                app.UIFigure.UserData.mouseInAxes = false;
            end
        end

        function pan_move(app)
            current_position = app.UIFigure.UserData.activeAxes.CurrentPoint;
            xlim_range = get(app.UIFigure.UserData.activeAxes, 'xlim');
            ylim_range = get(app.UIFigure.UserData.activeAxes, 'ylim');
            delta_points = current_position - app.UIFigure.UserData.Pan.previous_point;
            set(app.UIFigure.UserData.activeAxes, 'Xlim', xlim_range - delta_points(1));
            set(app.UIFigure.UserData.activeAxes, 'Ylim', ylim_range - delta_points(3));
            app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
        end

        function windowScrollWheel(app, ~, event)
            if isempty(app.UIFigure.UserData.activeAxes)
                return;
            end
            currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);
            if x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                    y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)
                if event.VerticalScrollCount > 0
                    scale = 1.1;
                else
                    scale = 1/1.1;
                end
                xlim_range = get(app.UIFigure.UserData.activeAxes, 'xlim');
                ylim_range = get(app.UIFigure.UserData.activeAxes, 'ylim');
                app.UIFigure.UserData.activeAxes.XLim = (xlim_range - x) * scale + x;
                app.UIFigure.UserData.activeAxes.YLim = (ylim_range - y) * scale + y;
            end
        end

        function windowButtonUp(app, ~, ~)
            % 只有当DrawROI对象存在且处于拖拽模式时，才停止拖拽
            if ~isempty(app.DrawROI) && app.DrawROI.is_drag_active()
                app.DrawROI.stop_drag();
            end

            if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                % 无论是否在强制平移模式，松开鼠标左键后都应停止平移
                app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                % 但在强制平移模式下保持手形光标
                if app.UIFigure.UserData.forcePanMode
                    set(app.UIFigure, 'Pointer', 'hand');
                else
                    set(app.UIFigure, 'Pointer', 'arrow');
                end
            end
        end

        function keyPress(app, ~, event)
            switch event.Key
                case 'control'
                    app.UIFigure.UserData.CtrlPressed = true;
                case 'shift'
                    app.UIFigure.UserData.ShiftPressed = true;
                case 'alt'
                    app.UIFigure.UserData.AltPressed = true;
                case 'space' % 空格键按下，激活强制平移模式
                    app.UIFigure.UserData.SpacePressed = true;
                    app.UIFigure.UserData.forcePanMode = true;
                    set(app.UIFigure, 'Pointer', 'hand'); % 改变鼠标指针样式以提示用户

                case 'delete'
                    if app.DrawROI.selected_roi_idx > 0
                        app.DrawROI.delete_selected_roi();
                    end
                    if app.DrawROI.is_adding_regular_roi()
                        app.DrawROI.cancel_adding_regular_roi();
                    end
                case 'uparrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(0, -1);
                        else
                            app.DrawROI.move_roi(0, -5);
                        end
                    end
                case 'downarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(0, 1);
                        else
                            app.DrawROI.move_roi(0, 5);
                        end
                    end
                case 'leftarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(-1, 0);
                        else
                            app.DrawROI.move_roi(-5, 0);
                        end
                    end
                case 'rightarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(1, 0);
                        else
                            app.DrawROI.move_roi(5, 0);
                        end
                    end
                case 'return'
                    % 检查是否在编辑ROI模式
                    if app.DrawROI.is_roi_editing()
                        app.DrawROI.finish_edit_roi(true);
                        % 检查是否在添加规则ROI模式
                    elseif app.DrawROI.is_adding_regular_roi()
                        app.DrawROI.finish_adding_regular_roi(true);
                        if app.DrawROI.showRoiNumber
                            app.DrawROI.show_roi_numbers();
                        end
                        % 使用活动轴的状态判断，而不是固定使用第一个轴
                    elseif strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                        app.DrawROI.finish_drawing();
                        if app.ShowROINumbersCheckBox.Value
                            app.DrawROI.show_roi_numbers();
                        end
                    end
                case 'escape'
                    % 检查是否在编辑ROI模式
                    if app.DrawROI.is_roi_editing()
                        app.DrawROI.cancel_edit_roi();
                        % 检查是否在添加规则ROI模式
                    elseif app.DrawROI.is_adding_regular_roi()
                        app.DrawROI.cancel_adding_regular_roi();
                        % 使用活动轴的状态判断，而不是固定使用第一个轴
                    elseif strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                        app.DrawROI.handroi_cancel();
                    end
            end
        end

        function keyRelease(app, ~, event)
            switch event.Key
                case 'control'
                    app.UIFigure.UserData.CtrlPressed = false;
                case 'shift'
                    app.UIFigure.UserData.ShiftPressed = false;
                case 'alt'  % Alt键释放，退出强制平移模式
                    app.UIFigure.UserData.AltPressed = false;
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow'); % 恢复默认鼠标指针
                    % 如果没有按住鼠标左键，则恢复idle状态
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        % 检查鼠标左键是否按下
                        if ~strcmp(get(app.UIFigure, 'SelectionType'), 'normal')
                            app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                        end
                    end
                case 'space'  % 空格键释放，退出强制平移模式
                    app.UIFigure.UserData.SpacePressed = false;
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow'); % 恢复默认鼠标指针
                    % 如果没有按住鼠标左键，则恢复idle状态
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        % 检查鼠标左键是否按下
                        if ~strcmp(get(app.UIFigure, 'SelectionType'), 'normal')
                            app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                        end
                    end

                case 'escape'
                    app.UIFigure.UserData.CtrlPressed = false;
                    app.UIFigure.UserData.ShiftPressed = false;
                    app.UIFigure.UserData.AltPressed = false;
                    app.UIFigure.UserData.SpacePressed = false; % 也重置空格键状态
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow');
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                    end
            end
        end


        function create_structure_pulse(app)
            % create pulse for structure imaging
            imageSize = app.scannerConfig.imageSize;

            % generate ROI pulse for each frame
            % 循环10次，创建waveformHandlesArray
            n = 10;
            waveformHandlesArray = cell(1,n);

            colNum = floor(imageSize/n);
            for i=1:n
                % 创建一个黑色的图像矩阵
                temp_mask = repmat(app.waveformConfig.pulseOff,imageSize, imageSize);

                % 计算本次要填充的列
                start = (i-1)*colNum+1;

                % 将这些列填充为白色
                if i == 10
                    % 如果是最后一列，则最后一次填充剩余的所有列
                    temp_mask(:, start:end) = app.waveformConfig.pulseOn;
                else
                    % 如果是前9次，则一次填充colNum列
                    temp_mask(:, start:start+colNum-1) = app.waveformConfig.pulseOn;
                end


                framePulse = create_frame_roi_pulse(app,temp_mask);

                % create waveform
                waveformHandle = awg.create_waveform_handle(app.awgDevice,framePulse);

                % add to waveformHandlesArray
                waveformHandlesArray{i} = waveformHandle;
            end
            waveformHandlesArray = cell2mat(waveformHandlesArray); % matlab 循环用cell 存储，然后再转化为mat矩阵

            sequenceLength = n; % seq 数
            loopCountsArray = ones(1,n); % 设置每个waveform的输出
            waveformSize = numel(framePulse);
            sampleCountsArray = repmat(waveformSize,1,n); % 每个waveform长度
            markerLocationArray = repmat(-1,1,n); % 是否输出markerLocation

            configureOutputMode(app.awgDevice,"OUTPUT_SEQ");
            [~, sequenceHandle] = createAdvancedArbSequence(app.awgDevice, sequenceLength, waveformHandlesArray, loopCountsArray, sampleCountsArray, markerLocationArray); % 创建sequenceHandle

            % generate Arb waveform
            awg.create_arb_sequence(app.awgDevice,sequenceHandle,app.waveformConfig);
        end

        function framePulse = create_frame_roi_pulse(app,roiMask)

            % Read parameters
            pulsePerPixel = app.scannerConfig.pulsePerPixel;
            scanBackLeftPixelTwice = app.scannerConfig.scanBackLeftPixelTwice * pulsePerPixel; % unit: pixel，scanleft和 scan right 也受到 pulsePerPixel 的影响
            scanBackRightPixelTwice = app.scannerConfig.scanBackRightPixelTwice * pulsePerPixel; % unit: pixel
            imageSize = app.scannerConfig.imageSize;
            scanWait = app.scannerConfig.scanWait; % unit: pulse


            % Generate ROI mask
            roiMaskPulse = repelem(roiMask, 1, pulsePerPixel); % Each pixel has several pulses, so the signal needs to be repeated
            roiMaskPulse(2:2:end, :) = fliplr(roiMaskPulse(2:2:end, :)); % Because of bidirectional scanning, the laser is scanned from left to right in the first line, and the second line is directly scanned from right, so even rows need to be mirrored

            % Add scan right to odd rows
            oddLineSignal = [roiMaskPulse(1:2:end, :) repmat(app.waveformConfig.pulseOff, imageSize / 2, scanBackRightPixelTwice)];

            % Add scan left to even rows
            evenLineSignal = [roiMaskPulse(2:2:end, :) repmat(app.waveformConfig.pulseOff, imageSize / 2, scanBackLeftPixelTwice)];

            % Then the odd row matrix and the even row matrix are pasted together in sequence and reduced to 1*n (considering the impact of changing the length of the array dynamically in the loop on performance, so use this method to optimize)
            signalPulse = reshape([oddLineSignal evenLineSignal]', 1, []);

            % Compose the final framePusle
            waitPulse = repmat(app.waveformConfig.pulseOff, 1, scanWait); % Add wait time in front
            scanleftFirstPulse = repmat(app.waveformConfig.pulseOff, 1, round(scanBackLeftPixelTwice / 2));
            framePulse = [waitPulse, scanleftFirstPulse, signalPulse(1:end - round(scanBackLeftPixelTwice / 2))]; % The first scanleft is missing, the last scanleft is extra

            % Actually, do not need to consider Flyback, but the length of the waveform must be an integer multiple of 4, so it needs to be supplemented
            if mod(length(framePulse), 4) ~= 0
                extraNum = 4 - mod(length(framePulse), 4);
                framePulse = [framePulse, repmat(app.waveformConfig.pulseOff, 1, extraNum)];
            end
        end

        function linePulse = create_line_roi_pulse(app, roiMaskLine, lineIndex)
            % Create pulse for a single line based on ROI mask

            % Read parameters
            pulsePerPixel = app.scannerConfig.pulsePerPixel;
            scanWait = app.scannerConfig.scanWait;
            scanBackLeftPixelTwice = app.scannerConfig.scanBackLeftPixelTwice * pulsePerPixel;
            scanBackRightPixelTwice = app.scannerConfig.scanBackRightPixelTwice * pulsePerPixel;
            imageWidth = app.scannerConfig.imageSize; % Assuming imageSize is square

            % Generate ROI mask pulse for the line
            roiMaskLinePulse = repelem(roiMaskLine, 1, pulsePerPixel); % Repeat for pulsePerPixel

            % Handle scan direction and add scan back time
            if mod(lineIndex, 2) == 1 % Odd lines (1, 3, 5...) - Scan Left to Right
                lineSignal = [repmat(app.waveformConfig.pulseOff, 1, scanWait), repmat(app.waveformConfig.pulseOff, 1, round(scanBackLeftPixelTwice/2)), roiMaskLinePulse, repmat(app.waveformConfig.pulseOff, 1, round(scanBackRightPixelTwice/2))];
            else % Even lines (2, 4, 6...) - Scan Right to Left
                roiMaskLinePulse = fliplr(roiMaskLinePulse); % Flip for right-to-left scan
                lineSignal = [repmat(app.waveformConfig.pulseOff, 1, scanWait), repmat(app.waveformConfig.pulseOff, 1, round(scanBackRightPixelTwice/2)), roiMaskLinePulse, repmat(app.waveformConfig.pulseOff, 1, round(scanBackLeftPixelTwice/2))];
            end

            % Ensure waveform length is a multiple of 4
            if mod(length(lineSignal), 4) ~= 0
                extraNum = 4 - mod(length(lineSignal), 4);
                lineSignal = [lineSignal, repmat(app.waveformConfig.pulseOff, 1, extraNum)];
            end
            linePulse = lineSignal;
        end

        function awg_output_roi_lines_pulse(app)
            % Configure AWG to output ROI pulses line by line using sequence mode

            imageHeight = app.scannerConfig.imageSize; % Assuming imageSize is square

            % Determine ROI mask based on pulse logic
            if ~app.waveformConfig.pulseOn
                app.roiMask = utils.active_low_logic(app.DrawROI.binary_mask);
            else
                app.roiMask = app.DrawROI.binary_mask;
            end

            % Create waveform handles for each line
            n = imageHeight; % Number of lines
            waveformHandlesArray = cell(1, n);
            sampleCountsArray = zeros(1, n); % Store actual length of each line pulse

            for i = 1:n
                linePulse = create_line_roi_pulse(app, app.roiMask(i,:), i);

                sampleCountsArray(i) = numel(linePulse); % Store length
                % disp(size(linePulse))
                % Create waveform handle for the line pulse
                waveformHandle = awg.create_waveform_handle(app.awgDevice, linePulse);
                waveformHandlesArray{i} = waveformHandle;
            end

            waveformHandlesArray = cell2mat(waveformHandlesArray);

            % Configure sequence parameters
            sequenceLength = n;
            loopCountsArray = ones(1, n); % Output each line waveform once per trigger
            markerLocationArray = repmat(-1, 1, n); % No specific marker locations needed here

            % Configure AWG for sequence output mode
            configureOutputMode(app.awgDevice, "OUTPUT_SEQ");

            % Create and configure the sequence
            [~, sequenceHandle] = createAdvancedArbSequence(app.awgDevice, sequenceLength, waveformHandlesArray, loopCountsArray, sampleCountsArray, markerLocationArray);

            % Generate Arb sequence output (triggered by line clock)
            awg.create_arb_sequence(app.awgDevice, sequenceHandle, app.waveformConfig);
            disp("ROI Imaging Module: Configured for Line Clock ROI Imaging");
        end


        function load_config(app, path)
            %% read file
            fid = fopen(path, 'r');
            if fid == -1
                error('Cannot open configuration file: %s', path);
            end
            jsonStr = fscanf(fid, '%c');
            fclose(fid);

            % json to struct
            try
                userConfig = jsondecode(jsonStr);
            catch e
                error('Error decoding JSON configuration: %s', e.message);
            end

            %% assignment value with field checking
            if isfield(userConfig, 'defaultConfig')
                app.defaultConfig = userConfig.defaultConfig;
            else
                warning('defaultConfig field not found in configuration file');
            end

            if isfield(userConfig, 'waveformConfig')
                app.waveformConfig = userConfig.waveformConfig;
            else
                warning('waveformConfig field not found in configuration file');
            end

            if isfield(userConfig, 'scannerConfig')
                app.scannerConfig = userConfig.scannerConfig;
            else
                warning('scannerConfig field not found in configuration file');
            end

            if isfield(userConfig, 'roiStyleConfig')
                app.roiStyleConfig = userConfig.roiStyleConfig;
            else
                warning('roiStyleConfig field not found in configuration file');
            end
            if isfield(userConfig, 'PowerCaculatConfig')
                app.PowerCaculatConfig = userConfig.PowerCaculatConfig;
            else
                warning('PowerCaculatConfig field not found in configuration file');
            end


            % if subapp is open
            if ~isempty(app.AwgSettingsApp)
                app.AwgSettingsApp.variableInit();
            end
            if ~isempty(app.ScannerSettingsApp)
                app.ScannerSettingsApp.variableInit();
            end
            % 更新ROI mask外观
            if ~isempty(app.DrawROI)
                init_DrawROI_Style(app);
            end
            % 更新ROI mask settings的值
            if ~isempty(app.ROIMaskSettingsApp)
               app.ROIMaskSettingsApp.variableInit();
            end
            % 更新PowerCaculate的值
            if ~isempty(app.PowerCaculateAPP)
               app.PowerCaculateAPP.variableInit();
            end
        end


        function init_config(app)
            % defaultConfig
            app.defaultConfig.configPath = fullfile(app.folder,'/config/');
            app.defaultConfig.roimaskPath = fullfile(app.folder,'/roi_mask/');
            % waveformConfig
            app.waveformConfig.pulseOn = 0;
            app.waveformConfig.pulseOff = 1;
            app.waveformConfig.resourceID = "Dev1"; % AWG Var: resourceID
            app.waveformConfig.gain = 3.3;
            app.waveformConfig.offset = 0;
            app.waveformConfig.sampleRate = 1.0007e6; % 1.0007 MHz
            app.waveformConfig.delayTime = 0;
            app.waveformConfig.mode = 'Stepped'; % Stepped
            app.waveformConfig.clockSource = 'ClkIn'; % 'OnboardClock' or 'ClkIn'
            app.waveformConfig.triggerOn = true; % true or false
            app.waveformConfig.triggerPort = 'PFI0'; % PFI0 or PFI1
            app.waveformConfig.exportSignalOn = true; % true or false
            app.waveformConfig.exportSignalType = 'DataMarker'; % Marker DataMarker
            app.waveformConfig.exportSignalPort = 'PFI1'; % PFI0 or PFI1

            % scannerConfig
            app.scannerConfig.imageSize = 512;
            app.scannerConfig.pulsePerPixel = 1;
            app.scannerConfig.scanWait = 56;
            app.scannerConfig.scanBackLeftPixelTwice = 40; % unit: pixel，scanleft和 scan right 也受到 pulsePerPixel 的影响
            app.scannerConfig.scanBackRightPixelTwice = 40; % unit: pixel
            app.scannerConfig.clockMode = 'Frame Clock'; % Line Clock or Frame Clock

            % roiStyleConfig
            app.roiStyleConfig.mask_color = 'random'; % 默认随机颜色
            app.roiStyleConfig.showRoiNumber = false; % 默认不显示字体
            app.roiStyleConfig.show_background = true; % 默认显示mask 背景
            app.roiStyleConfig.roi_number_fontSize = 6; % 设置默认字体大小
            app.roiStyleConfig.roi_number_fontColor = [255,0, 255]/255; % 设置默认字体颜色

            % power Caculate Config
            app.PowerCaculatConfig.hBeamID = 2; % hbeam ID
        end

        function process_structure_image(app,filename,path)
            % read tiff stack
            fullpath = fullfile(path, filename);
            imgStack = utils.tiff_read(fullpath);
            % read reoulution info
            tagstruct = utils.tiff_read_tag(fullpath);


            % 1/10 重构
            if app.StructureTypeDropDown.Value == "1/10 Imaging"
                imgStack =  utils.tiff_extract(imgStack);
            end

            % 保存为raw tif
            [~, fname, fext] = fileparts(filename);


            if app.StructureTypeDropDown.Value == "1/10 Imaging"
                utils.tiff_save(imgStack,fullfile(path, [fname,'_rebuild',fext]),tagstruct);
            end



            % 保存到类属性
            app.seg_img_stack = imgStack;
            
            % 保存为average tif
            imgAvgCh = utils.tiff_projection_avg(imgStack);

            % 生成配准参考图
            % ops = register.default_ops();
            % app.refImg = register.compute_reference(imgStack,ops);
            % utils.tiff_save(app.refImg, ...
            %     fullfile(folderProcessed, sprintf('%s_ref%s', fname, fext)));


            % 默认显示平均图
            hold(app.UIAxes,'off');
            app.img_seg_data = imgAvgCh;
            app.seg_img_layer = imshow(app.img_seg_data,[],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
            img_size = size(app.img_seg_data);
            axis(app.UIAxes,[0,img_size(2),0,img_size(1)]);
            hold(app.UIAxes,'on');
            % 更新contrast slider
            app.ContrastSlider.Limits = [double(min(app.img_seg_data,[],"all")), double(max(app.img_seg_data,[],"all"))];
            app.ContrastSlider.Value = app.ContrastSlider.Limits;
            app.UIAxes.CLim = app.ContrastSlider.Value;
    
            % for save mask
            app.img_seg_fname = fname;
            app.img_seg_ext =  fext;
            app.img_seg_filename = [app.img_seg_fname,app.img_seg_ext];
            app.last_seg_tiff_folder = path;


            % init DrawROI components
            app.init_DrawROI();
        end





        function structure_imaging_callback(app,~,~)
            % listen to scanimage event
            % reset device for new pusle
            % avoid awg device is not connected
            if isempty(app.awgDevice)
                uialert(app.UIFigure,"Please Connect AWG Device First",'Warning','Icon','warning','Modal',false);
                return
            end

            reset(app.awgDevice);

            % create structure pusle
            app.create_structure_pulse();
            disp("ROI Imaging Module: 0.1MHz Imaging");

            % 0.1MHZ: light lamp

            app.ConventionalimagingButton.FontWeight = 'normal';
            app.ConventionalimagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'bold';
            app.Laser1on9offButton.FontColor = [227, 0, 127]/255;
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];

            app.StructureImagingLamp.Color =[227, 0, 127]/255;

        end

        function laser_keep_on(app)
            % avoid awg device is not connected
            if ~isvalid(app.awgDevice)
                uialert(app.UIFigure,"Please Connect AWG Device First",'Warning','Icon','warning','Modal',false);
                return
            end

            reset(app.awgDevice);

            % create Arb waveform
            waveformDataArray = repmat(app.waveformConfig.pulseOn,1,20);
            waveformHandle = awg.create_waveform_handle(app.awgDevice,waveformDataArray);

            % generate Arb waveform with no trigger(do not wait until scanimage grab a image)
            awg.create_arb_waveform_notrigger(app.awgDevice,waveformHandle,app.waveformConfig);

            % turn on nogating lamp
            app.ConventionalimagingButton.FontWeight = 'bold';
            app.ConventionalimagingButton.FontColor = [0, 114, 189]/255;
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];

            app.StructureImagingLamp.Color = [0.90,0.90,0.90];
            pause(0.1);
            app.StructureImagingLamp.Color = [0, 114, 189]/255;
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            disp("ROI Imaging Module: Laser Keep On");
        end


        function laser_keep_off(app)
            reset(app.awgDevice);
            % create pulse for keeping laser off
            waveformDataArray = repmat(app.waveformConfig.pulseOff,1,20);
            waveformHandle = awg.create_waveform_handle(app.awgDevice,waveformDataArray);

            % generate Arb waveform with no trigger(do not wait until scanimage grab a image)
            awg.create_arb_waveform_notrigger(app.awgDevice,waveformHandle,app.waveformConfig);

            % turn off all lamps
            app.StructureImagingLamp.Color = [0.90,0.90,0.90];
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];


            app.ConventionalimagingButton.FontWeight = 'normal';
            app.ConventionalimagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];
        end



        function init_DrawROI(app)
            % create empty mask
            app.DrawROI = components.DrawROI(app, [app.UIAxes]);
            app.DrawROI.mask_size = size(app.img_seg_data);
            init_DrawROI_Style(app);
            % enable components
            app.MaskOnCheckBox.Value = true;
            app.Seg.enable = true;
            app.Seg.auto_rerun = false;
            % save image data
            app.UIAxes.UserData.status = 'idle';
            app.UIAxes.UserData.origin_xlim = app.UIAxes.XLim;
            app.UIAxes.UserData.origin_ylim = app.UIAxes.YLim;
        end
        function init_DrawROI_Style(app)
            if ~isempty(app.DrawROI) && ~isempty(fieldnames(app.roiStyleConfig))
                app.DrawROI.mask_color = app.roiStyleConfig.mask_color;
                app.DrawROI.showRoiNumber = app.roiStyleConfig.showRoiNumber; % 默认不显示字体
                app.DrawROI.show_background = app.roiStyleConfig.show_background; % 默认显示mask 背景
                app.DrawROI.roi_number_fontSize = app.roiStyleConfig.roi_number_fontSize; % 设置默认字体大小
                app.DrawROI.roi_number_fontColor = app.roiStyleConfig.roi_number_fontColor; % 设置默认字体颜色
            end
        end
        function roi_imaging_loop_callback(app,~,~)
            reset(app.awgDevice);


            % active low logic: 1（white) to 0, 0（black）to 1
            app.roiMask = utils.active_low_logic(app.DrawROI.binary_mask);

            % generate ROI pulse for each frame
            framePulse = app.create_frame_roi_pulse(app.roiMask);

            % create waveform
            waveformHandle = awg.create_waveform_handle(app.awgDevice,framePulse);

            % generate Arb waveform with no trigger(do not wait until scanimage grab a image)
            temp_config = app.waveformConfig;
            temp_config.mode = 'Continuous';
            awg.create_arb_waveform_notrigger(app.awgDevice,waveformHandle,temp_config);
        end

        function roi_imaging_callback(app,~,~)
            reset(app.awgDevice);

            % active low logic: 1（white) to 0, 0（black）to 1
            app.roiMask = utils.active_low_logic(app.DrawROI.binary_mask);

            % generate ROI pulse for each frame
            framePulse = app.create_frame_roi_pulse(app.roiMask);

            % create waveform
            waveformHandle = awg.create_waveform_handle(app.awgDevice,framePulse);

            % generate Arb waveform
            awg.create_arb_waveform(app.awgDevice,waveformHandle,app.waveformConfig);
        end

        function getCellposeModels(app, folderPath)
            % Get filenames in the specified folder
            files = dir(folderPath);

            % Initialize a set to store model names with an estimated maximum size
            maxFiles = length(files);
            modelNames = cell(1, maxFiles);
            modelCount = 0;

            % Iterate through each file in the folder
            for i = 1:maxFiles
                fileName = files(i).name;

                % Skip the current and parent directory entries
                if strcmp(fileName, '.') || strcmp(fileName, '..')
                    continue;
                end

                % Determine the model name based on the filename
                if startsWith(fileName, 'cyto2torch_')
                    modelName = 'cyto2';
                elseif startsWith(fileName, 'nucleitorch_')
                    modelName = 'nuclei';
                elseif startsWith(fileName, 'cytotorch_')
                    modelName = 'cyto';
                    
                else
                    modelName = fileName;
                end

                % Add the model name to the set if it's not already present
                if ~ismember(modelName, modelNames(1:modelCount))
                    modelCount = modelCount + 1;
                    modelNames{modelCount} = modelName;
                end
            end

            % Trim the modelNames array to the correct size
            modelNames = modelNames(1:modelCount);


            % Update the dropdown menu items and set the default value
            app.ModelsDropDown.Items = modelNames;
            app.ModelsDropDown.Value = modelNames{2};
        end

        
       function save_mask(app)
            try
                if isempty(app.DrawROI.roi_contours)
                    return
                end
                %% roi ratio、Actual power percentage到xlsx
                % get roiRatio
                roiRatio = app.ROIRatioEditField.Value;
                % caculate Actual power percentage
                scanArea = (app.scannerConfig.scanBackLeftPixelTwice/2+app.scannerConfig.imageSize+app.scannerConfig.scanBackRightPixelTwice/2)*app.scannerConfig.imageSize;
                acquisitionArea = app.scannerConfig.imageSize*app.scannerConfig.imageSize;
                fillfraction = acquisitionArea/scanArea;
                scanAreaPercentage = roiRatio*fillfraction;
                % Create a table with the ROI information
                roiTable = table(roiRatio, scanAreaPercentage, ...
                    'VariableNames', {'ROI_Ratio', 'Scan_Area_Percentage'});

                % Write the table to Excel file
                writetable(roiTable, fullfile(app.last_seg_tiff_folder, ...
                    [app.img_seg_fname, '_roiImagingMask.xlsx']), 'Sheet', 'Sheet1');

                %% save roi mask
                % save matfile
                data.roi_contours = app.DrawROI.roi_contours;
                data.original_roi_contours = app.DrawROI.original_roi_contours;
                data.dilate_level = app.DrawROI.dilate_level;
                data.roi_labeled_mask = uint16(app.DrawROI.generate_labeled_mask());
    
                save(fullfile(app.last_seg_tiff_folder,[app.img_seg_fname,'_roiImagingMask.mat']), ...
                    "-struct", ...
                    "data");
                utils.tiff_save(data.roi_labeled_mask,fullfile(app.last_seg_tiff_folder,strcat(app.img_seg_fname,'_roiImagingMask.tif')));

                % save roi mask to imageJ
                utils.save_roiContour_to_imagej(app.DrawROI.roi_contours,fullfile(app.last_seg_tiff_folder,strcat(app.img_seg_fname,'_roiImagingMask.zip')));

                app.UIAxes.XLim = app.UIAxes.UserData.origin_xlim;
                app.UIAxes.YLim = app.UIAxes.UserData.origin_ylim;
                % 
                % exportgraphics(app.UIAxes, ...
                %     fullfile(app.last_seg_tiff_folder, ...
                %     [app.img_seg_fname,'_roiMask.pdf']), ...
                %     'Resolution',600);
                % 
    
                exportgraphics(app.UIAxes, ...
                    fullfile(app.last_seg_tiff_folder, ...
                    [app.img_seg_fname,'_roiImagingMask.png']), ...
                    'Resolution',600);
            catch ME
                % 捕获并显示错误信息
                errordlg(ME.message, 'Error');
                fprintf(2,'%s\n', ME.getReport('extended'));
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            % export app to base
            assignin("base",'app',app);

            %% get app folder
            fullpath = mfilename('fullpath');
            [path,~]=fileparts(fullpath);
            app.folder = path;
            addpath(genpath(fullfile(app.folder,'libs')))

            %% init awg settings
            app.init_config();


            %% init DrawROI component
            app.DrawROI = components.DrawROI(app, [app.UIAxes]);
            app.UIFigure.UserData.CtrlPressed = false;
            app.UIFigure.UserData.ShiftPressed = false;
            app.UIFigure.UserData.AltPressed = false;
            app.UIFigure.UserData.SpacePressed = false;

            app.UIFigure.UserData.Pan = struct('previous_point', [0 0 0 0]);
            app.UIFigure.UserData.activeAxes = app.UIAxes; % 默认活动轴
            app.UIAxes.UserData.status = 'idle';
            app.UIAxes.UserData.origin_xlim = [];
            app.UIAxes.UserData.origin_ylim = [];
            app.UIFigure.UserData.mouseInAxes = false;
            app.UIFigure.UserData.forcePanMode = false;

            set(app.UIFigure, 'WindowButtonDownFcn', @app.windowButtonDown);
            set(app.UIFigure, 'WindowButtonMotionFcn', @app.windowMotion);
            set(app.UIFigure, 'WindowButtonUpFcn', @app.windowButtonUp);
            set(app.UIFigure, 'WindowKeyPressFcn', @app.keyPress);
            set(app.UIFigure, 'WindowKeyReleaseFcn', @app.keyRelease);
            set(app.UIFigure, 'WindowScrollWheelFcn', @app.windowScrollWheel);

            %% init Seg component
            try

                % python路径添加cellpose
                folder = fullfile(app.folder,'\+components');
                if count(py.sys.path,folder) == 0
                    insert(py.sys.path,int32(0),folder );
                end
                py.importlib.import_module('pycellpose');

                app.Seg = components.SegmentationPy();
            catch ME
                % 捕获并显示错误信息
                errordlg(ME.message, 'Error');
                fprintf(2,'%s\n', ME.getReport('extended'));
            end
                
            % app.Seg.cellpose_model_folder = fullfile(app.folder,'cellposeModels/');
            % getCellposeModels(app,app.Seg.cellpose_model_folder)

            

            %% init config settings
            default_json = fullfile(app.defaultConfig.configPath,'default.json');
            if exist(default_json,'file') ~= 0
                % if default.json exist
                app.load_config(default_json);
                app.ConfigurationFileEditField.Value = 'default.json';
            end


            %% 确认Scanimage是否启动
            % ui
            app.ScanimageButton.BackgroundColor = [1.00,0.00,0.00];
            try
                app.hSI = evalin('base', 'hSI');
                app.hSICtl = evalin('base', 'hSICtl');
            catch
                uialert(app.UIFigure,"Please Start Scanimage First",'Warning','Icon','warning','Modal',false);
                return
            end
            app.ScanimageButton.BackgroundColor = [0.33,0.60,0.85];
            app.ScanimageButton.Value = true;


        end

        % Button pushed function: ConfigFileSelectButton
        function ConfigFileSelectButtonPushed(app, event)
            % select file
            if isempty(app.lastConfigPath)
                % 考虑当前文件夹可能不是app文件夹
                configPath = fullfile(app.folder,app.defaultConfig.configPath);
                [filename,path]= utils.select_file({'*.json'},configPath);
            else
                [filename,path]= utils.select_file({'*.json'}, app.lastConfigPath);
            end

            if filename ~= 0
                fullpath = [path,filename];

                % save path for next click
                app.lastConfigPath = path;

                % load conig
                app.load_config(fullpath)

                % show config file in GUI
                app.ConfigurationFileEditField.Value = filename;

                % log in command line
                disp(['Loaded Config：',fullpath]);
            end



        end

        % Button pushed function: AdvancedSettingsOpenButton
        function AdvancedSettingsOpenButtonPushed(app, event)
            app.AwgSettingsApp = subapps.AwgSettings(app);
            app.ScannerSettingsApp = subapps.ScannerSettings(app);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % when exit MainApp
            % disconnect awg device
            if isvalid (app.StructureRebuilder)
                delete(app.StructureRebuilder);
            end
            if isvalid(app.structureListener)
                delete(app.structureListener);
            end

            if isvalid(app.awgDevice)
                reset(app.awgDevice);
                app.laser_keep_on();
                pause(2);
                awg.disconnect(app.awgDevice);
            end


            % close subapp
            if  ~isempty(app.AwgSettingsApp)
                delete(app.AwgSettingsApp)
            end
            if  ~isempty(app.ScannerSettingsApp)
                delete(app.ScannerSettingsApp)
            end
            if ~isempty(app.ROIMaskSettingsApp)
                delete(app.ROIMaskSettingsApp);
            end
            if ~isempty(app.PowerCaculateAPP)
                delete(app.PowerCaculateAPP);
            end
            % close MainApp
            delete(app)
        end

        % Button pushed function: AwgConnectButton
        function AwgConnectButtonPushed(app, event)
            % If not connected, click to connect
            if app.isConnectedLabel.Text == "Disconnected"
                % simulated mode on or off
                simulateState = app.AWGSimulateButton.Value;

                % create progress dialog
                d = uiprogressdlg(app.UIFigure,'Title','Connecting AWG',...
                    'Indeterminate','on');
                drawnow

                % connect to awg
                [app.awgDevice,status] = awg.connect(app.waveformConfig.resourceID,simulateState);

                % close the progress dialog
                close(d);

                if isvalid(app.awgDevice)
                    app.laser_keep_on();

                    % if connected to AWG already
                    if status
                        app.isConnectedLabel.Text = 'Connected';
                        app.AwgConnectButton.Text = 'Disconnect';
                    end
                end
            else
                % % If connected, click to disconnect
                reset(app.awgDevice);
                app.laser_keep_on();
                awg.disconnect(app.awgDevice);
                app.isConnectedLabel.Text = 'Disconnected';
                app.AwgConnectButton.Text = 'Connect';

                % turn off all lamps
                app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            end
        end

        % Button pushed function: AbortButton
        function AbortButtonPushed(app, event)

            app.laser_keep_off();

            app.StructureImagingLamp.Color = [0.90,0.90,0.90];

            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
        end

        % Button pushed function: LoadmaskButton
        function LoadmaskButtonPushed(app, event)
            app.LoadmaskButton.Enable = 'off';
            app.LoadmaskButton.FontColor = [1.00,1.00,1.00];
            app.LoadmaskButton.BackgroundColor = [0.96,0.65,0.11];
            % load mask
            if isempty(app.lastRoiMaskPath)
                % 考虑当前文件夹可能不是app文件夹
                [filename,path] = utils.select_file({ ...
                '*.mat;*.zip', 'ROI Mask files (*.mat, *.zip, *.png)'; ...
                '*.mat', 'MAT files (*.mat)'; ...
                '*.zip', 'Image ROI files (*.zip)'; ...
                '*.png;*.csv;*.txt;*.xlsx','Custom files (*.png;*.csv;*.txt;*.xlsx)'; ...
                '*.*', 'All Files (*.*)'}, ...
                app.last_seg_tiff_folder);

            else
                [filename,path] = utils.select_file({ ...
                    '*.mat;*.zip', 'ROI Mask files (*.mat, *.zip, *.png)'; ...
                    '*.mat', 'MAT files (*.mat)'; ...
                    '*.zip', 'Image ROI files (*.zip)'; ...
                    '*.png;*.csv;*.txt;*.xlsx','Custom files (*.png;*.csv;*.txt;*.xlsx)'; ...
                    '*.*', 'All Files (*.*)'}, ...
                    app.lastRoiMaskPath);
            end


            if filename ~= 0 % 如果不选择文件返回为0
                % save path for next click
                app.lastRoiMaskPath = path;

                % create progress dialog
                d = uiprogressdlg(app.UIFigure,'Title','Loading ROI Mask',...
                    'Indeterminate','on');
                drawnow

                % load roi
                
                try
                    app.DrawROI.load_roi_file(fullfile(path,filename));
                catch
                    app.LoadmaskButton.Enable = 'on';
                    app.LoadmaskButton.FontColor = [0,0,0];
                    app.LoadmaskButton.BackgroundColor = [0.96,0.96,0.96];
                    app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                    return
                end
                
                % enable draw roi
                app.MaskOnCheckBox.Value = true;
                
                app.Seg.enable = true;
                app.Seg.auto_rerun = false;

                % reset roi dilate value
                %app.ROIdilateSpinner.Value = 0;

                % close the dialog box
                close(d);
            end

            %% update ui
            % enable load mask button
            app.LoadmaskButton.Enable = 'on';
            app.LoadmaskButton.FontColor = [0,0,0];
            app.LoadmaskButton.BackgroundColor = [0.96,0.96,0.96];

            % 关闭ROI imaging灯
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];

        end

        % Menu selected function: AWGSettingsMenu
        function AWGSettingsMenuSelected(app, event)
            app.AwgSettingsApp = subapps.AwgSettings(app);
        end

        % Menu selected function: ScannerSettingsMenu
        function ScannerSettingsMenuSelected(app, event)
            app.ScannerSettingsApp = subapps.ScannerSettings(app);
        end

        % Menu selected function: AWGControlMenu
        function AWGControlMenuSelected(app, event)
            app.AwgControlApp = utilities.AWG_Control_2022b();

        end

        % Menu selected function: ROIImagingSimulatorMenu
        function ROIImagingSimulatorMenuSelected(app, event)
            app.SimulationApp = utilities.simulation_veritical_stripe();
        end

        % Menu selected function: FileMenu
        function FileMenuSelected(app, event)

        end

        % Menu selected function: SaveConfigMenu
        function SaveConfigMenuSelected(app, event)

            userConfig.defaultConfig = app.defaultConfig;
            userConfig.waveformConfig = app.waveformConfig;
            userConfig.scannerConfig = app.scannerConfig;
            userConfig.roiStyleConfig = app.roiStyleConfig;
            userConfig.PowerCaculatConfig = app.PowerCaculatConfig;
            % 自动替换路径中的反斜杠为正斜杠，否则会报错
            fields = fieldnames(userConfig.defaultConfig); % 获取 defaultConfig 中的所有字段名
            for i = 1:length(fields)
                fieldName = fields{i};
                fieldValue = userConfig.defaultConfig.(fieldName);
                if ischar(fieldValue) % 仅处理字符串类型的字段
                    % 替换反斜杠为正斜杠
                    modifiedValue = strrep(fieldValue, '\', '/');
                    userConfig.defaultConfig.(fieldName) = modifiedValue;
                end
            end

            if isempty(app.lastConfigPath)
                [filename,path] =  utils.save_file({'*.json'},app.defaultConfig.configPath);
            else
                [filename,path] =  utils.save_file({'*.json'}, app.lastConfigPath);
            end

            if ischar(filename) && ischar(path)
                fullpath = fullfile(path, filename);
                % save for next click
                app.lastConfigPath = path;
                % save to json
                jsonStr = jsonencode(userConfig,'PrettyPrint',true);
                fid = fopen(fullpath, 'w');
                fprintf(fid, jsonStr);
                fclose(fid);
                % log
                disp(['Config Saved to File: ',fullpath]);

                % change config file in GUI
                app.ConfigurationFileEditField.Value = filename;
            end

        end

        % Callback function
        function ChannelDropDownValueChanged(app, event)
            if isempty(app.img_avg_Ch1) || ~any(app.img_avg_Ch1,'all')
                return
            end

            value = app.ChannelDropDown.Value;
            switch value
                case 'CH1'
                    img = app.img_avg_Ch1;
                    app.img_seg_filename = [app.img_seg_fname,'_ch1',app.img_seg_ext];
                case 'CH2'
                    img = app.img_avg_Ch2;
                    app.img_seg_filename = [app.img_seg_fname,'_ch2',app.img_seg_ext];
            end

            hold(app.UIAxes,'off');
            app.img_seg_data = img;
            imshow(app.img_seg_data,[],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
            hold(app.UIAxes,'on');

            % init DrawROI components
            app.init_DrawROI();
        end

        % Menu selected function: PowerCaculateMenu
        function PowerCaculateMenuSelected(app, event)
            app.PowerCaculateAPP = subapps.PowerCaculate(app);
        end

        % Callback function
        function ImagingPowerEditFieldValueChanged(app, event)
            caculate_power(app);

        end

        % Value changed function: ScanimageButton
        function ScanimageButtonValueChanged(app, event)
            value = app.ScanimageButton.Value;
            if value
                try
                    app.hSI = evalin('base', 'hSI');
                    app.hSICtl = evalin('base', 'hSICtl');
                catch
                    app.ScanimageButton.Value = false;
                    uialert(app.UIFigure,"Please Start Scanimage First", ...
                        'Warning','Icon','warning','Modal',false);
                    return;
                end


                app.ScanimageButton.BackgroundColor = [0.33,0.60,0.85];

                %app.CaculateButtonPushed();

            else
                app.hSI = scanimage.SI.empty;
                app.hSICtl = scanimage.SIController.empty;
                app.ScanimageButton.BackgroundColor = [1.00,0.00,0.00];
            end
        end

        % Value changed function: ROIdilateSpinner
        function ROIdilateSpinnerValueChanged(app, event)
            value = app.ROIdilateSpinner.Value;
            app.DrawROI.dilate_roi(value);



            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
        end

        % Button pushed function: LoadSegImageButton
        function LoadSegImageButtonPushed(app, event)
            % Disable load button
            app.LoadSegImageButton.Enable = 'off';
            app.LoadSegImageButton.FontColor = [1.00,1.00,1.00];
            app.LoadSegImageButton.BackgroundColor = [0.96,0.65,0.11];
            [filename,path] = utils.select_file({'*.tif';'*.png'},app.last_seg_tiff_folder);
            
            if filename ~= 0
                % create progress dialog
                d = uiprogressdlg(app.UIFigure,'Title','Loading Image',...
                    'Indeterminate','on');
                drawnow

                % save path for next click
                app.last_seg_tiff_folder = path;
                app.img_seg_filename = filename; % 获取文件名+后缀
                [~, app.img_seg_fname, ~]  = fileparts(app.img_seg_filename); % 获取文件名，无后缀

                info = imfinfo(fullfile(path,filename));
                try
                    % load image
                    if length(info)>1
                        %% stacked frames
                        % Projection dropdown切换
                        app.DropDown.Enable = 'on';
                        app.DropDown.Items = {'AVG','Std','Max','Movie'};
                        app.DropDown.Value = app.DropDown.Items{1};
    
                        process_structure_image(app,filename,path);
                    else
                        % single frame
                        app.img_seg_data= imread(fullfile(app.last_seg_tiff_folder,filename));
                        app.refImg = app.img_seg_data;
                        
                        % Projection dropdown切换
                        app.DropDown.Enable = 'off';
                        app.DropDown.Items = {'1 Frame'};
                        app.DropDown.Value = app.DropDown.Items{1};
                        
                        % 显示图片
                        hold(app.UIAxes,'off');
                        app.seg_img_layer = imshow(app.img_seg_data,[],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
                        img_size = size(app.img_seg_data);
                        axis(app.UIAxes,[0,img_size(2),0,img_size(1)]);
                        hold(app.UIAxes,'on');
                        
                        % 隐藏movide slider
                        app.FrameSliderLabel.Visible = 'off';
                        app.FrameSlider.Visible = 'off';
    
    
                        % 对比度滑条
                        app.ContrastSlider.Limits = [double(min(app.img_seg_data,[],"all")), double(max(app.img_seg_data,[],"all"))];
                        app.ContrastSlider.Value = app.ContrastSlider.Limits;
                        app.UIAxes.CLim = app.ContrastSlider.Value;
                        % init DrawROI components
                        app.init_DrawROI();
                    end
                catch ME
                    % 捕获并显示错误信息
                    errordlg(ME.message, 'Error');
                    fprintf(2,'%s\n', ME.getReport('extended'));
                end
                % close the dialog box
                close(d);

            end

            % Enable load button
            app.LoadSegImageButton.Enable = 'on';
            app.LoadSegImageButton.FontColor = [0,0,0];
            app.LoadSegImageButton.BackgroundColor = [0.96,0.96,0.96];

            % 关闭ROI imaging灯
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            app.ROIsEditField.Value = 0;
            app.ROIRatioEditField.Value =0;

        end

        % Button pushed function: RunmodelButton
        function RunmodelButtonPushed(app, event)
            if ~app.Seg.enable
                return
            end

            % process bar
            progressDlg = uiprogressdlg(app.UIFigure,'Title','Running neuron segmentation',...
                'Indeterminate','on');
            drawnow


            flow_threshold = app.thresholdSpinner.Value;
            norm_blocksize= app.norm_blocksizeEditField.Value;
            labeled_mask =  app.Seg.run(app.img_seg_data,flow_threshold,norm_blocksize);
            app.DrawROI.load_from_mask(labeled_mask);
            % cp = cellpose(Model=model_type,ModelFolder=app.Seg.cellpose_model_folder, ExecutionEnvironment="gpu");
            % labeled_mask = segmentCells2D(cp,app.img_seg_data,CellThreshold=0,FlowErrorThreshold=flow_threshold,ImageCellDiameter=15); %ImageCellDiameter=56
            % app.DrawROI.load_from_mask(labeled_mask);
            % close the dialog box
            close(progressDlg);


            app.Seg.auto_rerun = true; % 支持调整threshold，就自动显示
            app.ROIdilateSpinner.Value = 0;

            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];

        end

        % Value changed function: thresholdSpinner
        function thresholdSpinnerValueChanged(app, event)

        end

        % Callback function
        function ModelsDropDownValueChanged(app, event)

            app.Seg.auto_rerun = false;

        end

        % Value changed function: MaskOnCheckBox
        function MaskOnCheckBoxValueChanged(app, event)

            if isempty(app.DrawROI)
                return
            end
            value = app.MaskOnCheckBox.Value;
            app.DrawROI.set_roi_visibility(1, value);

        end

        % Button pushed function: UIAxesHomeButton
        function UIAxesHomeButtonPushed(app, event)
            try
                app.UIAxes.XLim = app.UIAxes.UserData.origin_xlim;
                app.UIAxes.YLim = app.UIAxes.UserData.origin_ylim;
            catch
            end
        end

        % Button pushed function: SavemaskButton
        function SavemaskButtonPushed(app, event)

            non_modal_filename_input(app,app.img_seg_fname);

            function non_modal_filename_input(app,file_name)
                % 创建一个非模态窗口
                figPos = app.UIFigure.Position;
                figWidth = 300;
                figHeight = 200;
                figLeft = figPos(1) + (figPos(3) - figWidth)/2;
                figTop = figPos(2) + (figPos(4) - figHeight)/2;


                hFig = figure('Name', 'Enter File Name', ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'ToolBar', 'none', ...
                    'Resize', 'on', ...
                    'Position', [figLeft, figTop, figWidth, figHeight], ...
                    'WindowStyle', 'normal');
                % 创建一个文本框用于用户输入文件名
                hEdit = uicontrol('Style', 'edit', ...
                    'String',file_name,...
                    'Parent', hFig, ...
                    'Units', 'normalized', ...
                    'Position', [0.1, 0.5, 0.8, 0.1]);

                % 创建一个按钮，用户点击后保存文件名
                hButton = uicontrol('Style', 'pushbutton', ...
                    'Parent', hFig, ...
                    'Units', 'normalized', ...
                    'Position', [0.1, 0.3, 0.8, 0.1], ...
                    'String', 'Save', ...
                    'Callback', {@saveFileNameCallback, hFig,hEdit,app});
            end

            function saveFileNameCallback(~, ~, hFig,hEdit,app)
                % 获取用户输入的文件名
                fileName = get(hEdit, 'String');
                app.img_seg_fname = fileName;
                % 在这里执行保存文件的操作
                close(hFig);
                d = uiprogressdlg(app.UIFigure,'Title','Saving',...
                'Indeterminate','on');
                % save ROI
                try
                    save_mask(app);
                catch
                     close(d);
                     return
                end
                close(d);
                % hint: done
                uialert(app.UIFigure,'Save Mask Done','Done','Icon','success','Modal',false);
            end
        end

        % Button pushed function: LaserROIImagingButton
        function LaserROIImagingButtonPushed(app, event)
            % avoid awg device is not connected
            if isempty(app.awgDevice) || ~isvalid(app.awgDevice) % Check validity too
                uialert(app.UIFigure,"Please Connect AWG Device First",'Warning','Icon','warning','Modal',false);
                return
            end

            % 自动保存ROI mask
            % Check if DrawROI object and properties exist before saving
            if isvalid(app.DrawROI) 
                % 每次ROI成像，自动生成下一个文件的文件名，用来保存文件
                if ~isempty(app.hSI) || any(isvalid(app.hSI))
                    logCounter = app.hSI.hScan2D.logFileCounter;
                    app.img_seg_fname = sprintf('file_%05d',logCounter);
                    app.last_seg_tiff_folder = app.hSI.hScan2D.logFilePath;
                end
                save_mask(app);
            else
                warning('DrawROI object or its properties are not valid. Skipping mask save.');
            end

            % delete 0.1MHz listener and Rebuild
            if isvalid (app.StructureRebuilder)
                delete(app.StructureRebuilder);
            end

            if isvalid(app.structureListener)
                delete(app.structureListener);
            end

            %% set AWG output
            % reset AWG device for new waveform
            app.laser_keep_off();
            reset(app.awgDevice);
            

            if isempty(app.DrawROI.binary_mask2)
                mask = app.DrawROI.binary_mask;
            else
                mask = app.DrawROI.binary_mask2;
            end
            % Check clock mode and configure AWG accordingly
            if strcmpi(app.scannerConfig.clockMode, 'Line Clock')
                % --- Line Clock Logic ---
                awg_output_roi_lines_pulse(app);
    
            elseif strcmpi(app.scannerConfig.clockMode, 'Frame Clock')
                % --- Frame Clock Logic (Original) ---
                % Determine ROI mask based on pulse logic
                if ~app.waveformConfig.pulseOn
                    app.roiMask = utils.active_low_logic(mask);
                else
                    app.roiMask = mask;
                end

                % generate ROI pulse for the entire frame
                framePulse = app.create_frame_roi_pulse(app.roiMask);

                % create waveform handle
                waveformHandle = awg.create_waveform_handle(app.awgDevice,framePulse);

                % generate Arb waveform (triggered by frame clock)
                awg.create_arb_waveform(app.awgDevice,waveformHandle,app.waveformConfig);
                disp("ROI Imaging Module: Configured for Frame Clock ROI Imaging");
            else
                uialert(app.UIFigure,['Unknown clock mode: ', app.scannerConfig.clockMode],'Error','Icon','error','Modal',false);
                return;
            end
            %% light lamp
            app.ConventionalimagingButton.FontWeight = 'normal';
            app.ConventionalimagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='bold';
            app.LaserROIImagingButton.FontColor = [229, 0, 18]/255;

            app.StructureImagingLamp.Color = [0.90,0.90,0.90];

            % 闪一下
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            pause(0.1);
            app.ROIImagingLamp.Color = [229, 0, 18]/255;
            disp("ROI Imaging Module: ROI Imaging");
        end

        % Button pushed function: ConventionalimagingButton
        function ConventionalimagingButtonPushed(app, event)
            app.laser_keep_on();

            % Delete 0.1 MHz Listener to SCANIMAGE for Laser Keep On!
            if isvalid (app.StructureRebuilder)
                delete(app.StructureRebuilder);
            end

            if isvalid(app.structureListener)
                delete(app.structureListener);
            end
        end

        % Button pushed function: Laser1on9offButton
        function Laser1on9offButtonPushed(app, event)
            if isempty(app.hSI)
                uialert(app.UIFigure,"Please Connect Scanimage First",'Warning','Icon','warning','Modal',false);
                return
            end

            % 控制AWG进行十分之一成像
            app.structure_imaging_callback();

            % 实时成像重建：根据scanimage当前打开的channel进行重建
            delete(app.StructureRebuilder);
            app.StructureRebuilder= components.ScanimageRealtimeRebuildAvg(app.hSI);
            app.StructureRebuilder.listen_to_scanimage();

            % 0.1MHZ 监听程序
            if isa(app.hSI,'scanimage.SI')
                if isvalid(app.structureListener)
                    delete(app.structureListener);
                end
                %TODO：目前这个貌似没有意义了，因为不需要第一帧就是最左边开始拍
                app.structureListener = addlistener(app.hSI.hUserFunctions, 'acqModeStart', @app.structure_imaging_callback); % focus或grab结束后，自动重置结构成像
                disp("ROI Imaging Module: Listener to SCANIMAGE for 0.1MHz");
            else
                warning("Please Start Scanimage First");
            end

        end

        % Value changed function: ChannelDropDown_2
        function ChannelDropDown_2ValueChanged(app, event)
            value = app.ChannelDropDown_2.Value;
            disp(value);
        end

        % Button pushed function: RealtimeregistrationButton
        function RealtimeregistrationButtonPushed(app, event)
            % 备注：必须要focus才能正常发送！
            % 获取当前成像的roiData
            try
                stripeData = app.hSI.hDisplay.lastStripeData;
                roiData = stripeData.roiData{1};
    
                channels = roiData.channels;
                channel = channels(app.ChannelDropDown_2.Value);
                z = roiData.zs(1); % use the first available z
                
                roiData.onlyKeepZs(z);
                roiData.onlyKeepChannels(channel);
    
                img = app.img_seg_data;
                % roiData的imageDate替换为指定的图像，图像需要先进行根据lut，避免看不到图像
                lut = single(app.hSI.hChannels.channelLUT{channel});
                black = lut(1);
                white = lut(2);
                img = rescale(single(img), black, white);
                roiData.imageData{1}{1} = img';
    
                % 发送给scanimage
                app.hSI.hMotionManager.clearEstimators();
                app.hSI.hMotionManager.addEstimator(roiData);
                app.hSICtl = app.hSI.hController{1};
    
                % 显示MOtion correction界面
                hGUI = app.hSICtl.hGuiClasses.MotionDisplay;
                app.hSICtl.showGUI('MotionDisplay');
                app.hSICtl.raiseGUI('MotionDisplay');
                hGUI.currentZ = z;
                hGUI.selectedEstimator = app.hSI.hMotionManager.hMotionEstimators(1);
    
                app.hSI.hMotionManager.enable = true;
            catch ME
                errordlg("You need to acquire image data first before real-time registration.", 'Error');
                fprintf(2,'%s\n', ME.getReport('extended'));
            end
        end

        % Callback function
        function AdjustButtonValueChanged(app, event)
            value = app.AdjustButton.Value;
            if value
                img_adjusted = imadjust(app.img_seg_data);
                app.seg_img_layer.CData = img_adjusted;
            else
                app.seg_img_layer.CData = app.img_seg_data;
            end
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            value = app.DropDown.Value;
            switch value
                case 'AVG'
                    if ~isempty(app.img_seg_data)
                        % 隐藏滑条
                        app.FrameSlider.Visible = 'off';
                        app.FrameSliderLabel.Visible = 'off';
                        % 显示avg图片
                        d = uiprogressdlg(app.UIFigure,'Title','Processing','Indeterminate','on');
                        app.img_seg_data = utils.tiff_projection_avg(app.seg_img_stack);
                        close(d);
                        app.seg_img_layer.CData = app.img_seg_data;
                        % update contrast slider
                        app.ContrastSlider.Limits = [double(min(app.img_seg_data,[],"all")), double(max(app.img_seg_data,[],"all"))];
                        app.ContrastSlider.Value = app.ContrastSlider.Limits;
                        app.UIAxes.CLim = app.ContrastSlider.Value;
                    end

                case 'Movie'
                    if ~isempty(app.img_seg_data)
                        % 显示滑条
                        app.FrameSlider.Visible = 'on';
                        app.FrameSliderLabel.Visible = 'on';
                        % 显示单帧
                        app.seg_img_layer.CData = app.seg_img_stack(:,:,1);
                        n_frames = size(app.seg_img_stack,3);
                        app.FrameSlider.Value =1;
                        app.FrameSlider.Limits = [1,n_frames];
                        app.FrameSliderLabel.Text = sprintf("%d/%d",1,n_frames);
                        avg_img = utils.tiff_projection_avg(app.seg_img_stack);
                        % update contrast slider
                        app.ContrastSlider.Limits = [double(min(avg_img,[],"all")), double(max(avg_img,[],"all"))];
                        app.ContrastSlider.Value = app.ContrastSlider.Limits;
                        app.UIAxes.CLim = app.ContrastSlider.Value;
                    end

                case 'Std'
                    if ~isempty(app.img_seg_data)
                        % 隐藏滑条
                        app.FrameSlider.Visible = 'off';
                        app.FrameSliderLabel.Visible = 'off';
                        % 显示avg图片
                        d = uiprogressdlg(app.UIFigure,'Title','Processing','Indeterminate','on');
                        app.img_seg_data = utils.tiff_projection_std(app.seg_img_stack);
                        app.seg_img_layer.CData = app.img_seg_data;
                        close(d);
                        % update contrast slider
                        app.ContrastSlider.Limits = [double(min(app.img_seg_data,[],"all")), double(max(app.img_seg_data,[],"all"))];
                        app.ContrastSlider.Value = app.ContrastSlider.Limits;
                        app.UIAxes.CLim = app.ContrastSlider.Value;
                    end
                case 'Max'
                    if ~isempty(app.img_seg_data)
                        % 隐藏滑条
                        app.FrameSlider.Visible = 'off';
                        app.FrameSliderLabel.Visible = 'off';
                        % 显示avg图片
                        d = uiprogressdlg(app.UIFigure,'Title','Processing','Indeterminate','on');
                        app.img_seg_data = utils.tiff_projection_max(app.seg_img_stack);
                        app.seg_img_layer.CData = app.img_seg_data;
                        
                        close(d)
                        % update contrast slider
                        app.ContrastSlider.Limits = [double(min(app.img_seg_data,[],"all")), double(max(app.img_seg_data,[],"all"))];
                        app.ContrastSlider.Value = app.ContrastSlider.Limits;
                        app.UIAxes.CLim = app.ContrastSlider.Value;
                        
                    end
                

            end
        end

        % Value changed function: FrameSlider
        function FrameSliderValueChanged(app, event)
            value = app.FrameSlider.Value;
            n_frames = size(app.seg_img_stack,3);
            current_frame = round(value);
            app.FrameSliderLabel.Text = sprintf("%d/%d",current_frame,n_frames);
            app.seg_img_layer.CData = app.seg_img_stack(:,:,current_frame);
        end

        % Value changing function: FrameSlider
        function FrameSliderValueChanging(app, event)
            changingValue = event.Value;
            n_frames = size(app.seg_img_stack,3);
            current_frame = round(changingValue);
            app.FrameSliderLabel.Text = sprintf("%d/%d",current_frame,n_frames);
            app.seg_img_layer.CData = app.seg_img_stack(:,:,current_frame);
        end

        % Size changed function: ManualCorrectionPanel
        function ManualCorrectionPanelSizeChanged(app, event)
            position = app.ManualCorrectionPanel.Position;

        end

        % Callback function
        function editButtonPushed(app, event)

        end

        % Callback function
        function editButtonValueChanged(app, event)

            if ~app.DrawROI.enable
                app.editButton.Value = false;
                return
            end

            value = app.editButton.Value;
            if ~value
                app.DrawROI.modifyROI();
                app.editButton.Text = "edit";
            else
                app.DrawROI.modifyROI();
                app.editButton.Text = "done";
            end
        end

        % Callback function
        function ROIMaskClearButtonPushed(app, event)
            if ~isempty(app.DrawROI)
                choice = questdlg('Are you sure you want to clear all ROIs?', ...
                    'Clear ROIs', 'Yes', 'No', 'No');
                if strcmp(choice, 'Yes')
                    app.DrawROI.clear_all_rois();
                end
            end
        end

        % Button pushed function: ROIMaskSettingsButton
        function ROIMaskSettingsButtonPushed(app, event)
            % ROI面板打开ROIMaskSettings
            app.ROIMaskSettingsApp=subapps.ROIMaskSettings(app);
        end

        % Menu selected function: ROIMaskSettingsMenu
        function ROIMaskSettingsMenuSelected(app, event)
            % 顶部菜单打开ROIMaskSettings
            app.ROIMaskSettingsApp=subapps.ROIMaskSettings(app);
        end

        % Value changed function: ContrastSlider
        function ContrastSliderValueChanged(app, event)
            value = app.ContrastSlider.Value;
            if value(1) ~= value(2)
                app.UIAxes.CLim =value;
            end
        end

        % Value changing function: ContrastSlider
        function ContrastSliderValueChanging(app, event)
            value = event.Value;
            if value(1) ~= value(2)
                app.UIAxes.CLim =value;
            end

        end

        % Menu selected function: LoadConfigMenu
        function LoadConfigMenuSelected(app, event)
            ConfigFileSelectButtonPushed(app)
        end

        % Menu selected function: GithubMenu
        function GithubMenuSelected(app, event)
            web('https://github.com/Achuan-2/3PM_ROI_imaging_module');
        end

        % Menu selected function: AWGSimulateModeMenu
        function AWGSimulateModeMenuSelected(app, event)
            if ~app.awgSimulateState
                app.awgSimulateState = true;
                app.AWGSimulateButton.Visible = 'on';
                app.AWGSimulateButton.Value = true;
            else
                app.awgSimulateState = false;
                app.AWGSimulateButton.Visible = 'off';
                app.AWGSimulateButton.Value = false;
            end
        end

        % Menu selected function: SignalExtractionMenu
        function SignalExtractionMenuSelected(app, event)
            app.SignalExtractionApp= CalciumSignalExtraction();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {670, 670};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {297, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [92.3333333333333 92.3333333333333 864 670];
            app.UIFigure.Name = 'ROI Imaging Module';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.MenuSelectedFcn = createCallbackFcn(app, @FileMenuSelected, true);
            app.FileMenu.Text = ' File ';

            % Create SaveConfigMenu
            app.SaveConfigMenu = uimenu(app.FileMenu);
            app.SaveConfigMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveConfigMenuSelected, true);
            app.SaveConfigMenu.Text = 'Save Config';

            % Create LoadConfigMenu
            app.LoadConfigMenu = uimenu(app.FileMenu);
            app.LoadConfigMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadConfigMenuSelected, true);
            app.LoadConfigMenu.Text = 'Load Config';

            % Create SettingsMenu
            app.SettingsMenu = uimenu(app.UIFigure);
            app.SettingsMenu.Text = 'Settings';

            % Create AWGSettingsMenu
            app.AWGSettingsMenu = uimenu(app.SettingsMenu);
            app.AWGSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @AWGSettingsMenuSelected, true);
            app.AWGSettingsMenu.Text = 'AWG Settings';

            % Create AWGSimulateModeMenu
            app.AWGSimulateModeMenu = uimenu(app.SettingsMenu);
            app.AWGSimulateModeMenu.MenuSelectedFcn = createCallbackFcn(app, @AWGSimulateModeMenuSelected, true);
            app.AWGSimulateModeMenu.Text = 'AWG Simulate Mode';

            % Create ScannerSettingsMenu
            app.ScannerSettingsMenu = uimenu(app.SettingsMenu);
            app.ScannerSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @ScannerSettingsMenuSelected, true);
            app.ScannerSettingsMenu.Text = 'Scanner Settings';

            % Create ROIMaskSettingsMenu
            app.ROIMaskSettingsMenu = uimenu(app.SettingsMenu);
            app.ROIMaskSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @ROIMaskSettingsMenuSelected, true);
            app.ROIMaskSettingsMenu.Text = 'ROI Mask Settings';

            % Create PowerCaculateMenu
            app.PowerCaculateMenu = uimenu(app.SettingsMenu);
            app.PowerCaculateMenu.MenuSelectedFcn = createCallbackFcn(app, @PowerCaculateMenuSelected, true);
            app.PowerCaculateMenu.Text = 'Power Caculate';

            % Create UtilitiesMenu
            app.UtilitiesMenu = uimenu(app.UIFigure);
            app.UtilitiesMenu.Text = 'Utilities';

            % Create AWGControlMenu
            app.AWGControlMenu = uimenu(app.UtilitiesMenu);
            app.AWGControlMenu.MenuSelectedFcn = createCallbackFcn(app, @AWGControlMenuSelected, true);
            app.AWGControlMenu.Text = 'AWG Control';

            % Create ROIImagingSimulatorMenu
            app.ROIImagingSimulatorMenu = uimenu(app.UtilitiesMenu);
            app.ROIImagingSimulatorMenu.MenuSelectedFcn = createCallbackFcn(app, @ROIImagingSimulatorMenuSelected, true);
            app.ROIImagingSimulatorMenu.Text = 'ROI Imaging Simulator';

            % Create DataprocessMenu
            app.DataprocessMenu = uimenu(app.UIFigure);
            app.DataprocessMenu.Text = 'Data process';

            % Create TiffProcessMenu
            app.TiffProcessMenu = uimenu(app.DataprocessMenu);
            app.TiffProcessMenu.Text = 'Tiff Process';

            % Create SignalExtractionMenu
            app.SignalExtractionMenu = uimenu(app.DataprocessMenu);
            app.SignalExtractionMenu.MenuSelectedFcn = createCallbackFcn(app, @SignalExtractionMenuSelected, true);
            app.SignalExtractionMenu.Text = 'Signal Extraction';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = ' Help ';

            % Create GithubMenu
            app.GithubMenu = uimenu(app.HelpMenu);
            app.GithubMenu.MenuSelectedFcn = createCallbackFcn(app, @GithubMenuSelected, true);
            app.GithubMenu.Text = 'Github';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {297, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BorderType = 'none';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create CellSegmentationPanel
            app.CellSegmentationPanel = uipanel(app.LeftPanel);
            app.CellSegmentationPanel.Title = '2. Cell Segmentation';
            app.CellSegmentationPanel.Position = [7 272 285 173];

            % Create thresholdSpinnerLabel
            app.thresholdSpinnerLabel = uilabel(app.CellSegmentationPanel);
            app.thresholdSpinnerLabel.Position = [13 46 54 22];
            app.thresholdSpinnerLabel.Text = 'threshold';

            % Create thresholdSpinner
            app.thresholdSpinner = uispinner(app.CellSegmentationPanel);
            app.thresholdSpinner.Step = 0.05;
            app.thresholdSpinner.LowerLimitInclusive = 'off';
            app.thresholdSpinner.Limits = [0 3];
            app.thresholdSpinner.ValueChangedFcn = createCallbackFcn(app, @thresholdSpinnerValueChanged, true);
            app.thresholdSpinner.Tooltip = {'set  higher to get more cells, in range from (0,3]'};
            app.thresholdSpinner.Position = [113 46 55 22];
            app.thresholdSpinner.Value = 0.4;

            % Create RunmodelButton
            app.RunmodelButton = uibutton(app.CellSegmentationPanel, 'push');
            app.RunmodelButton.ButtonPushedFcn = createCallbackFcn(app, @RunmodelButtonPushed, true);
            app.RunmodelButton.Position = [13 11 228 23];
            app.RunmodelButton.Text = 'Run model';

            % Create LoadSegImageButton
            app.LoadSegImageButton = uibutton(app.CellSegmentationPanel, 'push');
            app.LoadSegImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSegImageButtonPushed, true);
            app.LoadSegImageButton.Icon = fullfile(pathToMLAPP, '+assets', 'folder-open.svg');
            app.LoadSegImageButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.LoadSegImageButton.Tooltip = {'Load Image to Segmentation'};
            app.LoadSegImageButton.Position = [13 114 152 23];
            app.LoadSegImageButton.Text = 'Load structure image';

            % Create StructureTypeDropDown
            app.StructureTypeDropDown = uidropdown(app.CellSegmentationPanel);
            app.StructureTypeDropDown.Items = {'via conventional', 'via FPA'};
            app.StructureTypeDropDown.Position = [179 114 79 22];
            app.StructureTypeDropDown.Value = 'via conventional';

            % Create norm_blocksizeEditFieldLabel
            app.norm_blocksizeEditFieldLabel = uilabel(app.CellSegmentationPanel);
            app.norm_blocksizeEditFieldLabel.Position = [13 75 88 22];
            app.norm_blocksizeEditFieldLabel.Text = 'norm_blocksize';

            % Create norm_blocksizeEditField
            app.norm_blocksizeEditField = uieditfield(app.CellSegmentationPanel, 'numeric');
            app.norm_blocksizeEditField.Position = [113 75 52 22];
            app.norm_blocksizeEditField.Value = 64;

            % Create ManualCorrectionPanel
            app.ManualCorrectionPanel = uipanel(app.LeftPanel);
            app.ManualCorrectionPanel.AutoResizeChildren = 'off';
            app.ManualCorrectionPanel.Title = '3. Manual Correction';
            app.ManualCorrectionPanel.SizeChangedFcn = createCallbackFcn(app, @ManualCorrectionPanelSizeChanged, true);
            app.ManualCorrectionPanel.Position = [8 125 284 136];

            % Create MaskOnCheckBox
            app.MaskOnCheckBox = uicheckbox(app.ManualCorrectionPanel);
            app.MaskOnCheckBox.ValueChangedFcn = createCallbackFcn(app, @MaskOnCheckBoxValueChanged, true);
            app.MaskOnCheckBox.Text = '';
            app.MaskOnCheckBox.FontColor = [0.3922 0.8314 0.0745];
            app.MaskOnCheckBox.Position = [119 82 14 22];

            % Create ROIdilateLabel
            app.ROIdilateLabel = uilabel(app.ManualCorrectionPanel);
            app.ROIdilateLabel.Position = [16 48 58 22];
            app.ROIdilateLabel.Text = 'ROI dilate';

            % Create ROIdilateSpinner
            app.ROIdilateSpinner = uispinner(app.ManualCorrectionPanel);
            app.ROIdilateSpinner.Limits = [0 Inf];
            app.ROIdilateSpinner.ValueChangedFcn = createCallbackFcn(app, @ROIdilateSpinnerValueChanged, true);
            app.ROIdilateSpinner.Tooltip = {'Dilate roi mask, in range from [0,+∞}'};
            app.ROIdilateSpinner.Position = [79 48 100 22];

            % Create LoadmaskButton
            app.LoadmaskButton = uibutton(app.ManualCorrectionPanel, 'push');
            app.LoadmaskButton.ButtonPushedFcn = createCallbackFcn(app, @LoadmaskButtonPushed, true);
            app.LoadmaskButton.Icon = fullfile(pathToMLAPP, '+assets', 'upload.svg');
            app.LoadmaskButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.LoadmaskButton.Tooltip = {'Load external mask  '};
            app.LoadmaskButton.Position = [15 14 98 23];
            app.LoadmaskButton.Text = 'Load mask';

            % Create SavemaskButton
            app.SavemaskButton = uibutton(app.ManualCorrectionPanel, 'push');
            app.SavemaskButton.ButtonPushedFcn = createCallbackFcn(app, @SavemaskButtonPushed, true);
            app.SavemaskButton.Icon = fullfile(pathToMLAPP, '+assets', 'save.svg');
            app.SavemaskButton.Tooltip = {'save ROI'; ' mask as .mat and image'};
            app.SavemaskButton.Position = [123 13 100 23];
            app.SavemaskButton.Text = 'Save mask';

            % Create ROIMaskSettingsButton
            app.ROIMaskSettingsButton = uibutton(app.ManualCorrectionPanel, 'push');
            app.ROIMaskSettingsButton.ButtonPushedFcn = createCallbackFcn(app, @ROIMaskSettingsButtonPushed, true);
            app.ROIMaskSettingsButton.Icon = fullfile(pathToMLAPP, '+assets', 'setting.svg');
            app.ROIMaskSettingsButton.Tooltip = {'Open Settings'};
            app.ROIMaskSettingsButton.Position = [144 81 41 23];
            app.ROIMaskSettingsButton.Text = '';

            % Create ShowROImaskLabel
            app.ShowROImaskLabel = uilabel(app.ManualCorrectionPanel);
            app.ShowROImaskLabel.Position = [16 81 95 22];
            app.ShowROImaskLabel.Text = 'Show ROI mask ';

            % Create ROIImagingPanel
            app.ROIImagingPanel = uipanel(app.LeftPanel);
            app.ROIImagingPanel.Title = '4. ROI Imaging';
            app.ROIImagingPanel.Position = [7 7 285 105];

            % Create LaserROIImagingButton
            app.LaserROIImagingButton = uibutton(app.ROIImagingPanel, 'push');
            app.LaserROIImagingButton.ButtonPushedFcn = createCallbackFcn(app, @LaserROIImagingButtonPushed, true);
            app.LaserROIImagingButton.Position = [14 46 100 23];
            app.LaserROIImagingButton.Text = 'ROI imaging';

            % Create AbortButton
            app.AbortButton = uibutton(app.ROIImagingPanel, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @AbortButtonPushed, true);
            app.AbortButton.Position = [149 46 98 23];
            app.AbortButton.Text = 'Abort';

            % Create ROIImagingLamp
            app.ROIImagingLamp = uilamp(app.ROIImagingPanel);
            app.ROIImagingLamp.Position = [212 88 12 12];
            app.ROIImagingLamp.Color = [0.902 0.902 0.902];

            % Create ChannelDropDown_2
            app.ChannelDropDown_2 = uidropdown(app.ROIImagingPanel);
            app.ChannelDropDown_2.Items = {'CH1', 'CH2'};
            app.ChannelDropDown_2.ItemsData = [1 2];
            app.ChannelDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ChannelDropDown_2ValueChanged, true);
            app.ChannelDropDown_2.Position = [149 10 56 22];
            app.ChannelDropDown_2.Value = 1;

            % Create RealtimeregistrationButton
            app.RealtimeregistrationButton = uibutton(app.ROIImagingPanel, 'push');
            app.RealtimeregistrationButton.ButtonPushedFcn = createCallbackFcn(app, @RealtimeregistrationButtonPushed, true);
            app.RealtimeregistrationButton.Position = [14 10 129 23];
            app.RealtimeregistrationButton.Text = 'Real-time registration';

            % Create HardwareSettingsPanel
            app.HardwareSettingsPanel = uipanel(app.LeftPanel);
            app.HardwareSettingsPanel.Title = 'Hardware Settings';
            app.HardwareSettingsPanel.Position = [7 536 285 130];

            % Create AwgConnectButton
            app.AwgConnectButton = uibutton(app.HardwareSettingsPanel, 'push');
            app.AwgConnectButton.ButtonPushedFcn = createCallbackFcn(app, @AwgConnectButtonPushed, true);
            app.AwgConnectButton.Position = [174 77 75 23];
            app.AwgConnectButton.Text = 'Connect';

            % Create AWGstatusLabel
            app.AWGstatusLabel = uilabel(app.HardwareSettingsPanel);
            app.AWGstatusLabel.Position = [14 78 69 22];
            app.AWGstatusLabel.Text = 'AWG status';

            % Create isConnectedLabel
            app.isConnectedLabel = uilabel(app.HardwareSettingsPanel);
            app.isConnectedLabel.Position = [96 78 78 22];
            app.isConnectedLabel.Text = 'Disconnected';

            % Create ConfigFileSelectButton
            app.ConfigFileSelectButton = uibutton(app.HardwareSettingsPanel, 'push');
            app.ConfigFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @ConfigFileSelectButtonPushed, true);
            app.ConfigFileSelectButton.Position = [230 45 20 23];
            app.ConfigFileSelectButton.Text = '...';

            % Create AdvancedSettingsOpenButton
            app.AdvancedSettingsOpenButton = uibutton(app.HardwareSettingsPanel, 'push');
            app.AdvancedSettingsOpenButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedSettingsOpenButtonPushed, true);
            app.AdvancedSettingsOpenButton.Position = [171 12 79 23];
            app.AdvancedSettingsOpenButton.Text = 'Advanced';

            % Create ConfigurationEditFieldLabel
            app.ConfigurationEditFieldLabel = uilabel(app.HardwareSettingsPanel);
            app.ConfigurationEditFieldLabel.Position = [14 46 77 22];
            app.ConfigurationEditFieldLabel.Text = 'Configuration';

            % Create ConfigurationFileEditField
            app.ConfigurationFileEditField = uieditfield(app.HardwareSettingsPanel, 'text');
            app.ConfigurationFileEditField.Position = [95 46 129 22];

            % Create ScanimageButton
            app.ScanimageButton = uibutton(app.HardwareSettingsPanel, 'state');
            app.ScanimageButton.ValueChangedFcn = createCallbackFcn(app, @ScanimageButtonValueChanged, true);
            app.ScanimageButton.Icon = fullfile(pathToMLAPP, '+assets', 'ScanImage.png');
            app.ScanimageButton.Text = '';
            app.ScanimageButton.BackgroundColor = [1 0 0];
            app.ScanimageButton.FontColor = [0.149 0.149 0.149];
            app.ScanimageButton.Position = [17 12 82 23];

            % Create AWGSimulateButton
            app.AWGSimulateButton = uibutton(app.HardwareSettingsPanel, 'state');
            app.AWGSimulateButton.Visible = 'off';
            app.AWGSimulateButton.Tooltip = {'Simulation'};
            app.AWGSimulateButton.Icon = fullfile(pathToMLAPP, '+assets', 'simulation.svg');
            app.AWGSimulateButton.Text = '';
            app.AWGSimulateButton.Position = [253 78 27 23];

            % Create StructureImagingPanel
            app.StructureImagingPanel = uipanel(app.LeftPanel);
            app.StructureImagingPanel.Title = '1. Structure Imaging';
            app.StructureImagingPanel.Position = [8 453 284 78];

            % Create StructureImagingLamp
            app.StructureImagingLamp = uilamp(app.StructureImagingPanel);
            app.StructureImagingLamp.Position = [212 62 12 12];
            app.StructureImagingLamp.Color = [0.902 0.902 0.902];

            % Create Laser1on9offButton
            app.Laser1on9offButton = uibutton(app.StructureImagingPanel, 'push');
            app.Laser1on9offButton.ButtonPushedFcn = createCallbackFcn(app, @Laser1on9offButtonPushed, true);
            app.Laser1on9offButton.Position = [159 13 100 23];
            app.Laser1on9offButton.Text = 'FPA imaging';

            % Create ConventionalimagingButton
            app.ConventionalimagingButton = uibutton(app.StructureImagingPanel, 'push');
            app.ConventionalimagingButton.ButtonPushedFcn = createCallbackFcn(app, @ConventionalimagingButtonPushed, true);
            app.ConventionalimagingButton.Position = [11 13 130 23];
            app.ConventionalimagingButton.Text = 'Conventional imaging';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BorderType = 'none';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Toolbar.Visible = 'off';
            app.UIAxes.XLimitMethod = 'tight';
            app.UIAxes.YLimitMethod = 'tight';
            app.UIAxes.ZLimitMethod = 'tight';
            app.UIAxes.GridLineWidth = 1;
            app.UIAxes.MinorGridLineWidth = 1;
            app.UIAxes.BoxStyle = 'full';
            app.UIAxes.LineWidth = 1;
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [47 93 512 512];

            % Create ROIsEditFieldLabel
            app.ROIsEditFieldLabel = uilabel(app.RightPanel);
            app.ROIsEditFieldLabel.HorizontalAlignment = 'right';
            app.ROIsEditFieldLabel.Position = [167 615 32 22];
            app.ROIsEditFieldLabel.Text = 'ROIs';

            % Create ROIsEditField
            app.ROIsEditField = uieditfield(app.RightPanel, 'numeric');
            app.ROIsEditField.Limits = [0 Inf];
            app.ROIsEditField.ValueDisplayFormat = '%.0f';
            app.ROIsEditField.Editable = 'off';
            app.ROIsEditField.Position = [211 613 51 22];

            % Create ROIratioEditFieldLabel
            app.ROIratioEditFieldLabel = uilabel(app.RightPanel);
            app.ROIratioEditFieldLabel.HorizontalAlignment = 'right';
            app.ROIratioEditFieldLabel.Position = [294 614 53 22];
            app.ROIratioEditFieldLabel.Text = 'ROI ratio';

            % Create ROIRatioEditField
            app.ROIRatioEditField = uieditfield(app.RightPanel, 'numeric');
            app.ROIRatioEditField.Limits = [0 Inf];
            app.ROIRatioEditField.ValueDisplayFormat = '%.3f';
            app.ROIRatioEditField.Editable = 'off';
            app.ROIRatioEditField.Position = [362 614 100 22];

            % Create UIAxesHomeButton
            app.UIAxesHomeButton = uibutton(app.RightPanel, 'push');
            app.UIAxesHomeButton.ButtonPushedFcn = createCallbackFcn(app, @UIAxesHomeButtonPushed, true);
            app.UIAxesHomeButton.Icon = fullfile(pathToMLAPP, '+assets', 'home.svg');
            app.UIAxesHomeButton.Position = [491 613 53 23];
            app.UIAxesHomeButton.Text = '';

            % Create DropDown
            app.DropDown = uidropdown(app.RightPanel);
            app.DropDown.Items = {'AVG', 'Movie'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.Position = [45 615 100 22];
            app.DropDown.Value = 'AVG';

            % Create Label
            app.Label = uilabel(app.RightPanel);
            app.Label.Position = [1 668 2 2];

            % Create FrameSlider
            app.FrameSlider = uislider(app.RightPanel);
            app.FrameSlider.Limits = [1 1000];
            app.FrameSlider.MajorTicks = [];
            app.FrameSlider.ValueChangedFcn = createCallbackFcn(app, @FrameSliderValueChanged, true);
            app.FrameSlider.ValueChangingFcn = createCallbackFcn(app, @FrameSliderValueChanging, true);
            app.FrameSlider.MinorTicks = [];
            app.FrameSlider.Visible = 'off';
            app.FrameSlider.Position = [58 83 490 3];
            app.FrameSlider.Value = 1;

            % Create FrameSliderLabel
            app.FrameSliderLabel = uilabel(app.RightPanel);
            app.FrameSliderLabel.HorizontalAlignment = 'center';
            app.FrameSliderLabel.Visible = 'off';
            app.FrameSliderLabel.Position = [48 64 490 22];
            app.FrameSliderLabel.Text = '1/1000';

            % Create ContrastSliderLabel
            app.ContrastSliderLabel = uilabel(app.RightPanel);
            app.ContrastSliderLabel.HorizontalAlignment = 'right';
            app.ContrastSliderLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContrastSliderLabel.Position = [48 43 50 22];
            app.ContrastSliderLabel.Text = 'Contrast';

            % Create ContrastSlider
            app.ContrastSlider = uislider(app.RightPanel, 'range');
            app.ContrastSlider.Limits = [0 2500];
            app.ContrastSlider.ValueChangedFcn = createCallbackFcn(app, @ContrastSliderValueChanged, true);
            app.ContrastSlider.ValueChangingFcn = createCallbackFcn(app, @ContrastSliderValueChanging, true);
            app.ContrastSlider.Position = [120 52 413 3];
            app.ContrastSlider.Value = [0 400];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ROIImagingModule_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end