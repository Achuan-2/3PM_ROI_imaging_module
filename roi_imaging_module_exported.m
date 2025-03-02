classdef roi_imaging_module_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RoiImagingModuleUIFigure     matlab.ui.Figure
        FileMenu                     matlab.ui.container.Menu
        LoadStructureImageMenu       matlab.ui.container.Menu
        LoadExternalmaskMenu         matlab.ui.container.Menu
        SaveConfigMenu               matlab.ui.container.Menu
        LoadConfigMenu               matlab.ui.container.Menu
        SettingsMenu                 matlab.ui.container.Menu
        AWGSettingsMenu              matlab.ui.container.Menu
        ScannerSettingsMenu          matlab.ui.container.Menu
        AddonsMenu                   matlab.ui.container.Menu
        PowerCaculateMenu            matlab.ui.container.Menu
        AWGControlMenu               matlab.ui.container.Menu
        ROIImagingSimulationMenu     matlab.ui.container.Menu
        CustomDrawMenu_2             matlab.ui.container.Menu
        HelpMenu                     matlab.ui.container.Menu
        Toolbar                      matlab.ui.container.Toolbar
        SimulationToggleTool         matlab.ui.container.toolbar.ToggleTool
        GridLayout                   matlab.ui.container.GridLayout
        LeftPanel                    matlab.ui.container.Panel
        StructureImagingPanel        matlab.ui.container.Panel
        RegularImagingButton         matlab.ui.control.Button
        Laser1on9offButton           matlab.ui.control.Button
        StructureImagingLamp         matlab.ui.control.Lamp
        SettingsPanel                matlab.ui.container.Panel
        ScanimageButton              matlab.ui.control.StateButton
        ConfigurationFileEditField   matlab.ui.control.EditField
        ConfigurationEditFieldLabel  matlab.ui.control.Label
        AdvancedSettingsOpenButton   matlab.ui.control.Button
        ConfigFileSelectButton       matlab.ui.control.Button
        isConnectedLabel             matlab.ui.control.Label
        AWGStatusLabel               matlab.ui.control.Label
        AwgConnectButton             matlab.ui.control.Button
        ROIImagingPanel              matlab.ui.container.Panel
        RealtimeregistrationButton   matlab.ui.control.Button
        ChannelDropDown_2            matlab.ui.control.DropDown
        ROIImagingLamp               matlab.ui.control.Lamp
        AbortButton                  matlab.ui.control.Button
        LaserROIImagingButton        matlab.ui.control.Button
        ManualcorrectionPanel        matlab.ui.container.Panel
        SaveMaskButton               matlab.ui.control.Button
        LoadMaskButton               matlab.ui.control.Button
        ROIdilateSpinner             matlab.ui.control.Spinner
        ROIdilateSpinnerLabel        matlab.ui.control.Label
        MaskOnCheckBox               matlab.ui.control.CheckBox
        MaskDropDown                 matlab.ui.control.DropDown
        MaskDropDownLabel            matlab.ui.control.Label
        NeuronSegmentationPanel      matlab.ui.container.Panel
        StructureTypeDropDown        matlab.ui.control.DropDown
        LoadSegImageButton           matlab.ui.control.Button
        RunModelButton               matlab.ui.control.Button
        ThresholdSpinner             matlab.ui.control.Spinner
        ThresholdSpinnerLabel        matlab.ui.control.Label
        ModelsDropDown               matlab.ui.control.DropDown
        ModelsDropDownLabel          matlab.ui.control.Label
        RightPanel                   matlab.ui.container.Panel
        FrameSliderLabel             matlab.ui.control.Label
        FrameSlider                  matlab.ui.control.Slider
        ContrastLabel                matlab.ui.control.Label
        Label                        matlab.ui.control.Label
        DropDown                     matlab.ui.control.DropDown
        AdjustButton                 matlab.ui.control.StateButton
        UIAxesHomeButton             matlab.ui.control.Button
        ROIRatioEditField            matlab.ui.control.NumericEditField
        ROIRatioEditField_2Label     matlab.ui.control.Label
        ROIsEditField                matlab.ui.control.NumericEditField
        ROIsEditFieldLabel           matlab.ui.control.Label
        PowerCaculatePanel           matlab.ui.container.Panel
        UpdateButton                 matlab.ui.control.Button
        PowerCostEditField           matlab.ui.control.NumericEditField
        PowerCoseLabel               matlab.ui.control.Label
        ROIPowerEditField            matlab.ui.control.NumericEditField
        ROIPowermWEditField_2Label   matlab.ui.control.Label
        StructurePowerEditField      matlab.ui.control.NumericEditField
        MHzPowermWEditFieldLabel     matlab.ui.control.Label
        ImagingPowerEditField        matlab.ui.control.NumericEditField
        LaserPowermWLabel            matlab.ui.control.Label
        UIAxes                       matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end


    properties (Access = public)
        % Sub APP
        AwgSettingsApp = 0;% sub-app for awg settings
        ScannerSettingsApp = 0; % sub-app for scanner settings
        AwgControlApp;
        SimulationApp;
        PowerCaculateAPP;
        
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
        last_seg_tiff_path = ''; % save last selected path of avg tif file
        seg_img_layer;
        seg_img_stack;
        img_avg_Ch1;% Description
        img_avg_Ch2;
        img_seg_data; % 用于分割的图像数据
        img_seg_filename;
    end

    % listener
    properties (Access = private)
        structureListener = event.listener.empty;% listener for structure imaging
        img_seg_name % Description
        img_seg_ext
    end

    % AWG Settings,Constant =true 让外部可以直接访问
    properties (Access = public)
        defaultConfig = struct();
        waveformConfig = struct();
        scannerConfig = struct();
    end
    
    % 配准
    properties (Access=public)
        refImg; 
    end


    methods (Access = private)

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
                temp_mask = repmat(app.defaultConfig.pulseOff,imageSize, imageSize);

                % 计算本次要填充的列
                start = (i-1)*colNum+1;

                % 将这些列填充为白色
                if i == 10
                    % 如果是最后一列，则最后一次填充剩余的所有列
                    temp_mask(:, start:end) = app.defaultConfig.pulseOn;
                else
                    % 如果是前9次，则一次填充colNum列
                    temp_mask(:, start:start+colNum-1) = app.defaultConfig.pulseOn;
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
            scanWait = app.scannerConfig.scanWait;


            % Generate ROI mask
            roiMaskPulse = repelem(roiMask, 1, pulsePerPixel); % Each pixel has several pulses, so the signal needs to be repeated
            roiMaskPulse(2:2:end, :) = fliplr(roiMaskPulse(2:2:end, :)); % Because of bidirectional scanning, the laser is scanned from left to right in the first line, and the second line is directly scanned from right, so even rows need to be mirrored

            % Add scan right to odd rows
            oddLineSignal = [roiMaskPulse(1:2:end, :) repmat(app.defaultConfig.pulseOff, imageSize / 2, scanBackRightPixelTwice)];

            % Add scan left to even rows
            evenLineSignal = [roiMaskPulse(2:2:end, :) repmat(app.defaultConfig.pulseOff, imageSize / 2, scanBackLeftPixelTwice)];

            % Then the odd row matrix and the even row matrix are pasted together in sequence and reduced to 1*n (considering the impact of changing the length of the array dynamically in the loop on performance, so use this method to optimize)
            signalPulse = reshape([oddLineSignal evenLineSignal]', 1, []);

            % Compose the final framePusle
            waitPulse = repmat(app.defaultConfig.pulseOff, 1, scanWait); % Add wait time in front
            scanleftFirstPulse = repmat(app.defaultConfig.pulseOff, 1, round(scanBackLeftPixelTwice / 2));
            framePulse = [waitPulse, scanleftFirstPulse, signalPulse(1:end - round(scanBackLeftPixelTwice / 2))]; % The first scanleft is missing, the last scanleft is extra

            % Actually, do not need to consider Flyback, but the length of the waveform must be an integer multiple of 4, so it needs to be supplemented
            if mod(length(framePulse), 4) ~= 0
                extraNum = 4 - mod(length(framePulse), 4);
                framePulse = [framePulse, repmat(app.defaultConfig.pulseOff, 1, extraNum)];
            end
        end

        function load_config(app,path)
            % read file
            fid = fopen(path, 'r');
            jsonStr = fscanf(fid, '%c');
            fclose(fid);
            % json to struct
            userConfig  = jsondecode(jsonStr);
            % assignment value
            app.defaultConfig = userConfig.defaultConfig;
            app.waveformConfig = userConfig.waveformConfig;
            app.scannerConfig = userConfig.scannerConfig;
        end

        function init_awg_settings(app)
            % defaultConfig
            app.defaultConfig.pulseOn = 0;
            app.defaultConfig.pulseOff = 1;
            app.defaultConfig.configPath = './config/';
            app.defaultConfig.roimaskPath = './roi_mask/';
            % waveformConfig
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
        end

        function process_structure_image(app,filename,path)
            % read tiff stack
            fullpath = fullfile(path, filename);
            imgStack = utils.tiff_read(fullpath);
            % read reoulution info
            t = Tiff(fullpath, 'r');
            tagstruct.XResolution = t.getTag("XResolution");
            tagstruct.YResolution = tagstruct.XResolution;
            t.close();

            
            if app.StructureTypeDropDown.Value == "1/10 Imaging"
                imgStack =  utils.tiff_extract(imgStack);
            end

            % get path
            folderProcessed = fullfile(path); 
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed)
            end

            % 保存为raw tif
            frames = size(imgStack,3);
            [~, fname, fext] = fileparts(filename);

            
            if app.StructureTypeDropDown.Value == "1/10 Imaging"
                utils.tiff_save(imgStack,fullfile(folderProcessed, [fname,'_rebuild',fext]),tagstruct);
            end

            
            
            % AVG 和 imgStack 的数据类型不一样，AVG是8bit，所以app.seg\_img\_layer.CData换成imgStack就非常亮，可能需要把imgStack换成uint8类型？
            % imgStack_normalized = mat2gray(imgStack);
            % imgStack_normalized = imgStack_normalized * 255;
            %app.seg_img_stack = imgStack_normalized;
            app.seg_img_stack = imgStack;
            % 保存为average tif
            imgAvgCh = utils.tiff_projection_avg(imgStack);
            %utils.tiff_save(imgAvgCh,fullfile(folderProcessed, sprintf('%s_%d_Frames_AVG%s', fname,frames, fext)),tagstruct);

            % 自动调整对比度 EnhanceContrastsh
            %app.img_avg_Ch1 = imadjust(imgAvgCh);
            %utils.tiff_save(app.img_avg_Ch1,fullfile(folderProcessed, sprintf('%s_%d_Frames_AVG_EnhanceContrast%s', fname,frames, fext)),tagstruct);
            
            % 生成配准参考图
            % ops = register.default_ops();
            % app.refImg = register.compute_reference(imgStack,ops);
            % utils.tiff_save(app.refImg, ...
            %     fullfile(folderProcessed, sprintf('%s_ref%s', fname, fext)));

            % 加载Ch1的图像
            %app.ChannelDropDown.Enable = "on";

            hold(app.UIAxes,'off');
            app.img_seg_data = imgAvgCh;
            %app.ChannelDropDown.Value = 'CH1';
            app.seg_img_layer = imshow(app.img_seg_data,[],'parent',app.UIAxes,'border','tight','initialmagnification','fit');

            img_size = size(app.img_seg_data);
            axis(app.UIAxes,[0,img_size(2),0,img_size(1)]);
            hold(app.UIAxes,'on');

            % init DrawROI components
            app.init_DrawROI();

            % for save mask
            app.img_seg_name = fname;
            app.img_seg_ext =  fext;
            app.img_seg_filename = [app.img_seg_name,app.img_seg_ext];
            app.last_seg_tiff_path = fullfile(path,'Structure');
            if ~exist(app.last_seg_tiff_path, 'dir')
                mkdir(app.last_seg_tiff_path)
            end
        end



        function caculate_power(app)
            % 计算理想激光功率，方便调整
            % get value
            imagingPower= app.ImagingPowerEditField.Value;
            powerCost = app.PowerCostEditField.Value;
            roiRatio = app.ROIRatioEditField.Value;
            scanArea = (app.scannerConfig.scanBackLeftPixelTwice/2+app.scannerConfig.imageSize+app.scannerConfig.scanBackRightPixelTwice/2)*app.scannerConfig.imageSize+app.scannerConfig.scanWait;
            acquisitionArea = app.scannerConfig.imageSize*app.scannerConfig.imageSize;
            fillfraction = acquisitionArea/scanArea;

            % caculate power
            %structurePower = imagingPower *0.1* powerCost*fillfraction;
            structurePower = imagingPower *0.1;
            roiPower = imagingPower*roiRatio*fillfraction*powerCost;

            % update value in gui
            app.StructurePowerEditField.Value = structurePower;
            app.ROIPowerEditField.Value = roiPower;
        end


        function structure_imaging_callback(app,~,~)
            % listen to scanimage event
            % reset device for new pusle
            % avoid awg device is not connected
            if isempty(app.awgDevice)
                uialert(app.RoiImagingModuleUIFigure,"Please Connect AWG Device First",'Warning','Icon','warning');
                return
            end

            reset(app.awgDevice);

            % create structure pusle
            app.create_structure_pulse();
            disp("ROI Imaging Module: 0.1MHz Imaging");

            % 0.1MHZ: light lamp

            app.RegularImagingButton.FontWeight = 'normal';
            app.RegularImagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'bold';
            app.Laser1on9offButton.FontColor = [1 0 0];
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];

            app.StructureImagingLamp.Color = [0.00,1.00,0.00];

        end

        function laser_keep_on(app)
            % avoid awg device is not connected
            if ~isvalid(app.awgDevice)
                uialert(app.RoiImagingModuleUIFigure,"Please Connect AWG Device First",'Warning','Icon','warning');
                return
            end

            reset(app.awgDevice);

            % create Arb waveform
            waveformDataArray = repmat(app.defaultConfig.pulseOn,1,20);
            waveformHandle = awg.create_waveform_handle(app.awgDevice,waveformDataArray);

            % generate Arb waveform with no trigger(do not wait until scanimage grab a image)
            awg.create_arb_waveform_notrigger(app.awgDevice,waveformHandle,app.waveformConfig);

            % turn on nogating lamp
            app.RegularImagingButton.FontWeight = 'bold';
            app.RegularImagingButton.FontColor = [1 0 0];
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];

            app.StructureImagingLamp.Color = [0.90,0.90,0.90];
            pause(0.1);
            app.StructureImagingLamp.Color = [0.93,0.69,0.13];
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            disp("ROI Imaging Module: Laser Keep On");
        end


        function laser_keep_off(app)
            reset(app.awgDevice);
            % create pulse for keeping laser off
            waveformDataArray = repmat(app.defaultConfig.pulseOff,1,20);
            waveformHandle = awg.create_waveform_handle(app.awgDevice,waveformDataArray);

            % generate Arb waveform with no trigger(do not wait until scanimage grab a image)
            awg.create_arb_waveform_notrigger(app.awgDevice,waveformHandle,app.waveformConfig);

            % turn off all lamps
            app.StructureImagingLamp.Color = [0.90,0.90,0.90];
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];


            app.RegularImagingButton.FontWeight = 'normal';
            app.RegularImagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='normal';
            app.LaserROIImagingButton.FontColor = [0 0 0];
        end

        function get_scanimage_power(app)
            lut = app.hSI.hBeams.hBeams{1, 1}.powerFraction2PowerWattLut;
            fraction = app.hSI.hBeams.powerFractions;
            power_W = utils.interp1_extended(lut(:,1),lut(:,2),fraction,'linear','extrap'); % unit: W
            app.ImagingPowerEditField.Value = round(power_W(1)*10^3);
        end

        function update_scanimage_power(app,~,~)
            % get scanimage power fraction and caculate the laser power by
            % lut
            app.get_scanimage_power();
            % caculate 0.1MHz and ROI actual power
            app.caculate_power();
        end

        function init_DrawROI(app)
            % create empty mask
            app.DrawROI.mask_size = size(app.img_seg_data);
            app.DrawROI.mask = zeros(app.DrawROI.mask_size);
            app.DrawROI.colored_mask = uint8(zeros([app.DrawROI.mask_size,3]));
            app.DrawROI.reset_three_fold_mask();

            % create empty mask layer
            app.DrawROI.mask_layer = imshow(app.DrawROI.colored_mask,[0,255],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
            app.DrawROI.mask_layer.AlphaData = zeros(app.DrawROI.mask_size);
            app.DrawROI.outline_layer = imshow(uint8(zeros([app.DrawROI.mask_size,3])),[0,255],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
            app.DrawROI.outline_layer.AlphaData = zeros(app.DrawROI.mask_size);
            % enable components
            app.MaskOnCheckBox.Value = true;
            app.DrawROI.enable  = true;
            app.Seg.enable = true;
            app.Seg.auto_rerun = false;
            % save image data
            app.UIAxes.UserData.origin_xlim = app.UIAxes.XLim;
            app.UIAxes.UserData.origin_ylim = app.UIAxes.YLim;
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
            app.ModelsDropDown.Value = modelNames{1};
        end

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % export app to base
            assignin("base",'app',app);

            % get app folder
            fullpath = mfilename('fullpath');
            [path,~]=fileparts(fullpath);
            app.folder = path;


            % init awg settings
            app.init_awg_settings();
            app.RoiImagingModuleUIFigure.UserData.CtrlPressed = false;
            app.RoiImagingModuleUIFigure.UserData.ShiftPressed = false;

            % init hand draw roi settings
            app.DrawROI = components.DrawROI(app);
            app.UIAxes.UserData.pan_previous_point = [];
            app.UIAxes.UserData.status = "idle"; % status: idle,handroi_drawing,paning
            app.UIAxes.UserData.origin_xlim = app.UIAxes.XLim;
            app.UIAxes.UserData.origin_ylim = app.UIAxes.YLim;
            
            % seg
            app.Seg = components.Segmentation();
            app.getCellposeModels(app.Seg.cellpose_model_folder)

            % ui
            app.ScanimageButton.BackgroundColor = [1.00,0.00,0.00];
            
            % init config settings
            default_json = fullfile(app.folder,app.defaultConfig.configPath,'default.json');
            if exist(default_json,'file') ~= 0
                % if default.json exist
                app.load_config(default_json);
                app.ConfigurationFileEditField.Value = 'default.json';
            end


            % 确认Scanimage是否启动
            try
                app.hSI = evalin('base', 'hSI');
                app.hSICtl = evalin('base', 'hSICtl');
            catch
                uialert(app.RoiImagingModuleUIFigure,"Please Start Scanimage First",'Warning','Icon','warning');
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


                % if subapp is open
                if app.AwgSettingsApp ~= 0
                    app.AwgSettingsApp.variableInit();
                end
                if app.ScannerSettingsApp ~= 0
                    app.ScannerSettingsApp.variableInit();
                end
            end



        end

        % Button pushed function: AdvancedSettingsOpenButton
        function AdvancedSettingsOpenButtonPushed(app, event)
            app.AwgSettingsApp = subapps.AwgSettings(app);
            app.ScannerSettingsApp = subapps.ScannerSettings(app);
        end

        % Close request function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureCloseRequest(app, event)
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
            if app.AwgSettingsApp ~= 0
                delete(app.AwgSettingsApp)
            end
            if app.ScannerSettingsApp ~= 0
                delete(app.ScannerSettingsApp)
            end


            % close MainApp
            delete(app)
        end

        % Button pushed function: AwgConnectButton
        function AwgConnectButtonPushed(app, event)
            % If not connected, click to connect
            if app.isConnectedLabel.Text == "Disconnected"
                % simulated mode on or off
                simulateState = app.SimulationToggleTool.State;

                % create progress dialog
                d = uiprogressdlg(app.RoiImagingModuleUIFigure,'Title','Connecting AWG',...
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

        % Button pushed function: LoadMaskButton
        function LoadMaskButtonPushed(app, event)
            app.LoadMaskButton.Enable = 'off';
            app.LoadMaskButton.FontColor = [1.00,1.00,1.00];
            app.LoadMaskButton.BackgroundColor = [0.96,0.65,0.11];
            % load mask
            if isempty(app.lastRoiMaskPath)
                % 考虑当前文件夹可能不是app文件夹
                roimaskPath = fullfile(app.folder,app.defaultConfig.roimaskPath);
                [filename,path] = utils.select_file({'*.mat';'*.png';'*.csv';'*.txt'},roimaskPath);
            else

                [filename,path] = utils.select_file({'*.mat';'*.png';'*.csv';'*.txt'},app.lastRoiMaskPath);
            end


            if filename ~= 0 % 如果不选择文件返回为0
                % save path for next click
                app.lastRoiMaskPath = path;

                % create progress dialog
                d = uiprogressdlg(app.RoiImagingModuleUIFigure,'Title','Loading ROI Mask',...
                    'Indeterminate','on');
                drawnow

                % load roi
                app.MaskOnCheckBox.Value = true;
                app.DrawROI.load_roi_mask(path,filename);

                % enable draw roi
                app.DrawROI.enable  = true;
                app.Seg.enable = true; 
                app.Seg.auto_rerun = false;

                % reset roi dilate value
                %app.ROIdilateSpinner.Value = 0;

                % close the dialog box
                close(d);
            end

            %% update ui
            % enable load mask button
            app.LoadMaskButton.Enable = 'on';
            app.LoadMaskButton.FontColor = [0,0,0];
            app.LoadMaskButton.BackgroundColor = [0.96,0.96,0.96];

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
            app.AwgControlApp = addons.AWG_Control_2022b();

        end

        % Menu selected function: ROIImagingSimulationMenu
        function ROIImagingSimulationMenuSelected(app, event)
            app.SimulationApp = addons.simulation_veritical_stripe();
        end

        % Menu selected function: FileMenu
        function FileMenuSelected(app, event)

        end

        % Menu selected function: SaveConfigMenu
        function SaveConfigMenuSelected(app, event)

            userConfig.defaultConfig = app.defaultConfig;
            userConfig.waveformConfig = app.waveformConfig;
            userConfig.scannerConfig = app.scannerConfig;



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

        % Button down function: RightPanel
        function RightPanelButtonDown(app, event)

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
                    app.img_seg_filename = [app.img_seg_name,'_ch1',app.img_seg_ext];
                case 'CH2'
                    img = app.img_avg_Ch2;
                    app.img_seg_filename = [app.img_seg_name,'_ch2',app.img_seg_ext];
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
            app.PowerCaculateAPP = addons.Power_Caculate();
        end

        % Value changed function: ImagingPowerEditField
        function ImagingPowerEditFieldValueChanged(app, event)
            app.caculate_power();

        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            if isa(app.hSI,'scanimage.SI')
                app.get_scanimage_power();
                % 更新完功率后自动更新
                app.caculate_power();
            else
                uialert(app.RoiImagingModuleUIFigure,"Please Start Scanimage First",'Warning','Icon','warning');
            end


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
                    uialert(app.RoiImagingModuleUIFigure,"Please Start Scanimage First", ...
                        'Warning','Icon','warning');
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
            value = app.ROIdilateSpinner.Value();
            if value
                app.DrawROI.is_dilating = true;
            else
                app.DrawROI.is_dilating = false;
            end

            % generate dilated mask
            app.DrawROI.dilate_mask(app.ROIdilateSpinner.Value);

            % update mask layer
            app.DrawROI.update_mask_layer();

            % caculate ROI Power
            app.caculate_power();

            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
        end

        % Button pushed function: LoadSegImageButton
        function LoadSegImageButtonPushed(app, event)
            % Disable load button
            app.LoadSegImageButton.Enable = 'off';
            app.LoadSegImageButton.FontColor = [1.00,1.00,1.00];
            app.LoadSegImageButton.BackgroundColor = [0.96,0.65,0.11];
            [filename,path] = utils.select_file({'*.tif';'*.png'},app.last_seg_tiff_path);

            if filename ~= 0
                % create progress dialog
                d = uiprogressdlg(app.RoiImagingModuleUIFigure,'Title','Loading Image',...
                    'Indeterminate','on');
                drawnow

                % save path for next click
                app.last_seg_tiff_path = path;
                app.img_seg_filename = filename;
                info = imfinfo(fullfile(path,filename));

                % load image
                if length(info)>1
                    % stacked frames
                    app.DropDown.Enable = 'on';
                    process_structure_image(app,filename,path);
                else
                    % single frame
                    app.img_seg_data= imread(fullfile(app.last_seg_tiff_path,filename));
                    app.refImg = app.img_seg_data;
                    %app.img_seg_data = imadjust(app.img_seg_data);

                    app.DropDown.Enable = 'off';
                    hold(app.UIAxes,'off');

                    app.seg_img_layer = imshow(app.img_seg_data,[],'parent',app.UIAxes,'border','tight','initialmagnification','fit');
                     

                    img_size = size(app.img_seg_data);
                    axis(app.UIAxes,[0,img_size(2),0,img_size(1)]);
                    hold(app.UIAxes,'on');
                    
                    % init DrawROI components
                    app.init_DrawROI();
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

        % Window button down function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowButtonDown(app, event)
            % get mouse position in UIaxes
            currentPosition =app.UIAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);
            if x >= app.UIAxes.XLim(1) && x <= app.UIAxes.XLim(2) && y >= app.UIAxes.YLim(1) && y <= app.UIAxes.YLim(2)

                switch app.RoiImagingModuleUIFigure.SelectionType
                    % left click
                    case 'normal'
                        % left click can cancel draw roi
                        if app.UIAxes.UserData.status == "handroi_drawing"
                            app.DrawROI.handroi_cancel();
                        end

                        selecting_roi = false;

                        % Enabling conditions：already drawed roi manualy or run segmentation
                        if app.DrawROI.enable && any(app.DrawROI.mask,'all')
                            % Click on ROI to make it white
                            selecting_roi = app.DrawROI.select_cell(x,y);

                        end

                        % When not select a roi, right click can pan the UIAxes
                        if ~selecting_roi
                            pan_click();
                        end

                        % right click /ctrl + left click
                    case 'alt'
                        % ctrl + left click
                        if app.RoiImagingModuleUIFigure.UserData.CtrlPressed
                            % disp("ctrl + left click");
                            app.DrawROI.delete_cell(x,y);
                            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
                            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                            % right click
                        else
                            if app.UIAxes.UserData.status ~= "handroi_drawing" && app.DrawROI.enable
                                app.DrawROI.handroi_start(x,y) % 手动圈选ROI 绘制起点
                                % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
                                app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                            end
                        end

                    case 'open'
                        % zoom restore
                        try
                            app.UIAxes.XLim = app.UIAxes.UserData.origin_xlim;
                            app.UIAxes.YLim = app.UIAxes.UserData.origin_ylim;
                        catch
                        end
                        % shift click / left click+ right click
                    case 'extend'
                        return
                end
            end



            function pan_click()
                app.UIAxes.UserData.status = "axes_paning";
                app.UIAxes.UserData.pan_previous_point = app.UIAxes.CurrentPoint;
                set(app.RoiImagingModuleUIFigure,'Pointer','fleur');

            end

        end

        % Window button up function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowButtonUp(app, event)
            switch app.UIAxes.UserData.status
                case "axes_paning"
                    app.UIAxes.UserData.status = "idle";
                    set(app.RoiImagingModuleUIFigure,'Pointer','arrow');
                case "handroi_drawing"
                    return
                otherwise
                    return
            end
        end

        % Window button motion function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowButtonMotion(app, event)
            % 鼠标移动过程中的绘图
            currentPosition =app.UIAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);
            if x >= app.UIAxes.XLim(1) && x <= app.UIAxes.XLim(2) && y >= app.UIAxes.YLim(1) && y <= app.UIAxes.YLim(2)
                switch  app.UIAxes.UserData.status
                    case "axes_paning"
                        pan_move()
                    case "handroi_drawing"
                       app.DrawROI.handroi_draw(x,y)
                    otherwise
                        return
                end
            end


            function pan_move()
                % get mouse position in UIaxes
                current_position =app.UIAxes.CurrentPoint;

                % get current location (in pixels)
                % get current XY-limits
                xlim_range = get(app.UIAxes, 'xlim');
                ylim_range = get(app.UIAxes, 'ylim');
                % find change in position
                delta_points = current_position - app.UIAxes.UserData.pan_previous_point;

                % Adjust limits
                set(app.UIAxes, 'Xlim', xlim_range - delta_points(1));
                set(app.UIAxes, 'Ylim', ylim_range - delta_points(3));

                % save new position
                app.UIAxes.UserData.pan_previous_point = get(app.UIAxes, 'CurrentPoint');

            end

        end

        % Window scroll wheel function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowScrollWheel(app, event)
            % 鼠标滚轮放大
            currentPosition =app.UIAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);
            if x >= app.UIAxes.XLim(1) && x <= app.UIAxes.XLim(2) && y >= app.UIAxes.YLim(1) && y <= app.UIAxes.YLim(2)
                if event.VerticalScrollCount > 0
                    scale = 1.1;
                else
                    scale = 1/1.1;
                end
                xlim_range = get(app.UIAxes, 'xlim');
                ylim_range = get(app.UIAxes, 'ylim');
                app.UIAxes.XLim = (xlim_range - x) * scale + x;
                app.UIAxes.YLim = (ylim_range - y) * scale + y;
            end
        end

        % Window key press function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowKeyPress(app, event)
            key = event.Key;
            switch key
                case 'control'
                    % disp("Control pressed")
                    app.RoiImagingModuleUIFigure.UserData.CtrlPressed = true;
                case 'shift'
                    app.RoiImagingModuleUIFigure.UserData.ShiftPressed = true;
                otherwise
                    return
            end

        end

        % Window key release function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureWindowKeyRelease(app, event)
            key = event.Key;
            switch key
                case 'escape'
                    % cancel draw roi manually
                    app.DrawROI.current_stroke = [];
                    for i = 1:length(app.DrawROI.plot_handles)
                        delete(app.DrawROI.plot_handles(i));
                    end
                    app.DrawROI.plot_handles = [];
                    app.UIAxes.UserData.status = "idle";
                case 'delete'
                    if app.DrawROI.enable
                        if app.DrawROI.last_selected_roi_index
                            app.DrawROI.delete_selected_cell();
                            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
                            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                        end
                    end
                case 'control'
                    app.RoiImagingModuleUIFigure.UserData.CtrlPressed = false;
                case 'shift'
                    app.RoiImagingModuleUIFigure.UserData.ShiftPressed = false;
                otherwise
                    return
            end
        end

        % Key press function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureKeyPress(app, event)
            key = event.Key;
            switch key
                case 'uparrow'
                    if app.DrawROI.enable
                        if ~app.RoiImagingModuleUIFigure.UserData.ShiftPressed
                            app.DrawROI.move_down = app.DrawROI.move_down + 1;
                        else
                            app.DrawROI.move_down = app.DrawROI.move_down + 5;
                        end
                        app.DrawROI.move_mask_update();
                        app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                    end
                case 'downarrow'
                    if app.DrawROI.enable
                        if ~app.RoiImagingModuleUIFigure.UserData.ShiftPressed
                            app.DrawROI.move_down = app.DrawROI.move_down - 1;
                        else
                            app.DrawROI.move_down = app.DrawROI.move_down - 5;
                        end

                        app.DrawROI.move_mask_update();
                        app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                    end
                case 'leftarrow'
                    if app.DrawROI.enable
                        if ~app.RoiImagingModuleUIFigure.UserData.ShiftPressed
                            app.DrawROI.move_right = app.DrawROI.move_right + 1;
                        else
                            app.DrawROI.move_right = app.DrawROI.move_right + 5;
                        end

                        app.DrawROI.move_mask_update();
                        app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                    end

                case 'rightarrow'
                    if app.DrawROI.enable
                        if ~app.RoiImagingModuleUIFigure.UserData.ShiftPressed
                            app.DrawROI.move_right = app.DrawROI.move_right - 1;
                        else
                            app.DrawROI.move_right = app.DrawROI.move_right - 5;
                        end

                        app.DrawROI.move_mask_update();
                        app.ROIImagingLamp.Color = [0.90,0.90,0.90];
                    end
            end

        end

        % Key release function: RoiImagingModuleUIFigure
        function RoiImagingModuleUIFigureKeyRelease(app, event)

        end

        % Button pushed function: RunModelButton
        function RunModelButtonPushed(app, event)
            if ~app.Seg.enable
                return
            end

            % process bar
            progressDlg = uiprogressdlg(app.RoiImagingModuleUIFigure,'Title','Running neuron segmentation',...
                'Indeterminate','on');
            drawnow

            model_type = app.ModelsDropDown.Value;
            flow_threshold = app.ThresholdSpinner.Value;
            cp = cellpose(Model=model_type,ModelFolder=app.Seg.cellpose_model_folder);
            app.DrawROI.mask = segmentCells2D(cp,app.img_seg_data,CellThreshold=0,FlowErrorThreshold=flow_threshold); %ImageCellDiameter=56

            % close the dialog box
            close(progressDlg);


            % toggle mask style button to colored mask
            app.MaskDropDown.Value = "Colored";
            app.DrawROI.colored_mask = components.drawRoi.mask_to_rgb(app.DrawROI.mask,app.DrawROI.colormaps);

            app.DrawROI.reset_three_fold_mask();
            app.DrawROI.update_mask_layer();


            app.Seg.auto_rerun = true; % 支持调整threshold，就自动显示
            app.ROIdilateSpinner.Value = 0;

            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];

        end

        % Value changed function: ThresholdSpinner
        function ThresholdSpinnerValueChanged(app, event)

            if  ~app.Seg.auto_rerun
                return
            end
            model_type = app.ModelsDropDown.Value;
            new_threshold = app.ThresholdSpinner.Value;
            cp = cellpose(Model=model_type,ModelFolder=app.Seg.cellpose_model_folder);
            new_mask = segmentCells2D(cp,app.img_seg_data,FlowErrorThreshold=new_threshold); %ImageCellDiameter=56

            % 为了已存在的roi不更改颜色，只在mask上新增新的roi和删除roi，需要找出new mask和old mask的不同
            app.DrawROI.threshold_update_mask(new_mask);

            % 关闭ROI灯，提示ROI成像与当前ROI mask不一致
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
        end

        % Value changed function: ModelsDropDown
        function ModelsDropDownValueChanged(app, event)

            app.Seg.auto_rerun = false;

        end

        % Value changed function: MaskDropDown
        function MaskDropDownValueChanged(app, event)
            app.DrawROI.update_mask_layer();
        end

        % Value changed function: MaskOnCheckBox
        function MaskOnCheckBoxValueChanged(app, event)
            value = app.MaskOnCheckBox.Value;
            if isempty(app.DrawROI.mask_layer)
                return
            end
            if value
                % disable draw roi
                app.DrawROI.enable  = true;
                app.DrawROI.update_mask_layer();
            else
                % enable draw roi
                app.DrawROI.enable  = false;
                app.DrawROI.mask_layer.AlphaData = 0;
            end

        end

        % Button pushed function: UIAxesHomeButton
        function UIAxesHomeButtonPushed(app, event)
            try
                app.UIAxes.XLim = app.UIAxes.UserData.origin_xlim;
                app.UIAxes.YLim = app.UIAxes.UserData.origin_ylim;
            catch
            end
        end

        % Button pushed function: SaveMaskButton
        function SaveMaskButtonPushed(app, event)
            
            [~, file_name, ~]  = fileparts(app.img_seg_filename);

            non_modal_filename_input(app,file_name);

            function non_modal_filename_input(app,file_name)
                % 创建一个非模态窗口
                hFig = figure('Name', 'Enter File Name', ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'ToolBar', 'none', ...
                    'Resize', 'on', ...
                    'WindowStyle', 'modal'); % 'normal' makes it non-modal

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
                disp(['The entered file name is: ', fileName]);
                % 在这里执行保存文件的操作
                close(hFig);
                % save mat
                data.three_fold_mask = app.DrawROI.three_fold_mask;
                data.three_fold_colored_mask = app.DrawROI.three_fold_colored_mask;
                data.three_fold_colored_mask_dilate_before = app.DrawROI.three_fold_colored_mask_dilate_before;
                data.three_fold_mask_dilate_before = app.DrawROI.three_fold_mask_dilate_before;
                data.move_down = app.DrawROI.move_down;
                data.move_right = app.DrawROI.move_right;
                data.dilate = app.ROIdilateSpinner.Value;

                save(fullfile(app.last_seg_tiff_path,[fileName,'_mask.mat']), ...
                    "-struct", ...
                    "data");


                % save png
                imwrite(app.DrawROI.binary_mask, ...
                    fullfile(app.last_seg_tiff_path,[fileName,'_mask.png']));

                % hint: done
                uialert(app.RoiImagingModuleUIFigure,'Save Mask Done','Done','Icon','success');
            end
        end

        % Button pushed function: LaserROIImagingButton
        function LaserROIImagingButtonPushed(app, event)
            % avoid awg device is not connected
            if isempty(app.awgDevice)
                uialert(app.RoiImagingModuleUIFigure,"Please Connect AWG Device First",'Warning','Icon','warning');
                return
            end

            % 自动保存ROI mask
            [~, file_name, ~]  = fileparts(app.img_seg_filename);
            data.three_fold_mask = app.DrawROI.three_fold_mask;
            data.three_fold_colored_mask = app.DrawROI.three_fold_colored_mask;
            data.move_down = app.DrawROI.move_down;
            data.move_right = app.DrawROI.move_right;

            save(fullfile(app.last_seg_tiff_path,[file_name,'_mask.mat']), ...
                "-struct", ...
                "data");


            % save png
            imwrite(app.DrawROI.binary_mask, ...
                fullfile(app.last_seg_tiff_path,[file_name,'_mask.png']));
            % delete 0.1MHz listener and Rebuild
            if isvalid (app.StructureRebuilder)
                delete(app.StructureRebuilder);
            end

            if isvalid(app.structureListener)
                delete(app.structureListener);
            end
            
            %% set AWG output
            % reset AWG device for new waveform
            reset(app.awgDevice);


            % active low logic: 1（white) to 0, 0（black）to 1
            if ~app.defaultConfig.pulseOn
                app.roiMask = utils.active_low_logic(app.DrawROI.binary_mask);
            else
                app.roiMask = app.DrawROI.binary_mask;
            end
            % generate ROI pulse for each frame
            framePulse = app.create_frame_roi_pulse(app.roiMask);

            % create waveform
            waveformHandle = awg.create_waveform_handle(app.awgDevice,framePulse);

            % generate Arb waveform
            awg.create_arb_waveform(app.awgDevice,waveformHandle,app.waveformConfig);
            %% light lamp
            app.RegularImagingButton.FontWeight = 'normal';
            app.RegularImagingButton.FontColor = [0 0 0];
            app.Laser1on9offButton.FontWeight = 'normal';
            app.Laser1on9offButton.FontColor = [0 0 0];
            app.LaserROIImagingButton.FontWeight ='bold';
            app.LaserROIImagingButton.FontColor = [1 0 0];

            app.StructureImagingLamp.Color = [0.90,0.90,0.90];

            % 闪一下
            app.ROIImagingLamp.Color = [0.90,0.90,0.90];
            pause(0.1);
            app.ROIImagingLamp.Color = [0.07,0.62,1.00];
            disp("ROI Imaging Module: ROI Imaging");
        end

        % Button pushed function: RegularImagingButton
        function RegularImagingButtonPushed(app, event)
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
                uialert(app.RoiImagingModuleUIFigure,"Please Connect Scanimage First",'Warning','Icon','warning');
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
            stripeData = app.hSI.hDisplay.lastStripeData;
            roiData = stripeData.roiData{1};

            channels = roiData.channels;
            channel = channels(app.ChannelDropDown_2.Value);
            z = roiData.zs(1); % use the first available z
            roiData.onlyKeepZs(z);
            roiData.onlyKeepChannels(channel);

            img = app.refImg;
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
        end

        % Value changed function: AdjustButton
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
                        app.seg_img_layer.CData = app.img_seg_data;
                    end
                case 'Movie'
                    if ~isempty(app.img_seg_data)
                        % 显示滑条
                        app.FrameSlider.Visible = 'on';
                        app.FrameSliderLabel.Visible = 'on';
                        app.seg_img_layer.CData = app.seg_img_stack(:,:,1);
                        n_frames = size(app.seg_img_stack,3);
                        app.FrameSlider.Value =1;
                        app.FrameSlider.Limits = [1,n_frames];
                        app.FrameSliderLabel.Text = sprintf("%d/%d",1,n_frames);
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

        % Size changed function: ManualcorrectionPanel
        function ManualcorrectionPanelSizeChanged(app, event)
            position = app.ManualcorrectionPanel.Position;
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.RoiImagingModuleUIFigure.Position(3);
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

            % Create RoiImagingModuleUIFigure and hide until all components are created
            app.RoiImagingModuleUIFigure = uifigure('Visible', 'off');
            app.RoiImagingModuleUIFigure.AutoResizeChildren = 'off';
            app.RoiImagingModuleUIFigure.Position = [99.8571428571428 99.8571428571428 1178 670];
            app.RoiImagingModuleUIFigure.Name = 'ROI Imaging Module';
            app.RoiImagingModuleUIFigure.Resize = 'off';
            app.RoiImagingModuleUIFigure.CloseRequestFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureCloseRequest, true);
            app.RoiImagingModuleUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.RoiImagingModuleUIFigure.WindowButtonDownFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowButtonDown, true);
            app.RoiImagingModuleUIFigure.WindowButtonUpFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowButtonUp, true);
            app.RoiImagingModuleUIFigure.WindowButtonMotionFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowButtonMotion, true);
            app.RoiImagingModuleUIFigure.WindowScrollWheelFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowScrollWheel, true);
            app.RoiImagingModuleUIFigure.WindowKeyPressFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowKeyPress, true);
            app.RoiImagingModuleUIFigure.WindowKeyReleaseFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureWindowKeyRelease, true);
            app.RoiImagingModuleUIFigure.KeyPressFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureKeyPress, true);
            app.RoiImagingModuleUIFigure.KeyReleaseFcn = createCallbackFcn(app, @RoiImagingModuleUIFigureKeyRelease, true);

            % Create FileMenu
            app.FileMenu = uimenu(app.RoiImagingModuleUIFigure);
            app.FileMenu.MenuSelectedFcn = createCallbackFcn(app, @FileMenuSelected, true);
            app.FileMenu.Text = ' File ';

            % Create LoadStructureImageMenu
            app.LoadStructureImageMenu = uimenu(app.FileMenu);
            app.LoadStructureImageMenu.Text = 'Load Structure Image';

            % Create LoadExternalmaskMenu
            app.LoadExternalmaskMenu = uimenu(app.FileMenu);
            app.LoadExternalmaskMenu.Text = 'Load External mask';

            % Create SaveConfigMenu
            app.SaveConfigMenu = uimenu(app.FileMenu);
            app.SaveConfigMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveConfigMenuSelected, true);
            app.SaveConfigMenu.Text = 'Save Config';

            % Create LoadConfigMenu
            app.LoadConfigMenu = uimenu(app.FileMenu);
            app.LoadConfigMenu.Text = 'Load Config';

            % Create SettingsMenu
            app.SettingsMenu = uimenu(app.RoiImagingModuleUIFigure);
            app.SettingsMenu.Text = ' Settings ';

            % Create AWGSettingsMenu
            app.AWGSettingsMenu = uimenu(app.SettingsMenu);
            app.AWGSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @AWGSettingsMenuSelected, true);
            app.AWGSettingsMenu.Text = 'AWG Settings';

            % Create ScannerSettingsMenu
            app.ScannerSettingsMenu = uimenu(app.SettingsMenu);
            app.ScannerSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @ScannerSettingsMenuSelected, true);
            app.ScannerSettingsMenu.Text = 'Scanner Settings';

            % Create AddonsMenu
            app.AddonsMenu = uimenu(app.RoiImagingModuleUIFigure);
            app.AddonsMenu.Text = ' Add-ons ';

            % Create PowerCaculateMenu
            app.PowerCaculateMenu = uimenu(app.AddonsMenu);
            app.PowerCaculateMenu.MenuSelectedFcn = createCallbackFcn(app, @PowerCaculateMenuSelected, true);
            app.PowerCaculateMenu.Text = 'Power Caculate';

            % Create AWGControlMenu
            app.AWGControlMenu = uimenu(app.AddonsMenu);
            app.AWGControlMenu.MenuSelectedFcn = createCallbackFcn(app, @AWGControlMenuSelected, true);
            app.AWGControlMenu.Text = 'AWG Control';

            % Create ROIImagingSimulationMenu
            app.ROIImagingSimulationMenu = uimenu(app.AddonsMenu);
            app.ROIImagingSimulationMenu.MenuSelectedFcn = createCallbackFcn(app, @ROIImagingSimulationMenuSelected, true);
            app.ROIImagingSimulationMenu.Text = 'ROI Imaging Simulation';

            % Create CustomDrawMenu_2
            app.CustomDrawMenu_2 = uimenu(app.AddonsMenu);
            app.CustomDrawMenu_2.Text = 'Custom Draw';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.RoiImagingModuleUIFigure);
            app.HelpMenu.Text = ' Help ';

            % Create Toolbar
            app.Toolbar = uitoolbar(app.RoiImagingModuleUIFigure);

            % Create SimulationToggleTool
            app.SimulationToggleTool = uitoggletool(app.Toolbar);
            app.SimulationToggleTool.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'simulation.svg');

            % Create GridLayout
            app.GridLayout = uigridlayout(app.RoiImagingModuleUIFigure);
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

            % Create NeuronSegmentationPanel
            app.NeuronSegmentationPanel = uipanel(app.LeftPanel);
            app.NeuronSegmentationPanel.Title = '2. Neuron Segmentation';
            app.NeuronSegmentationPanel.Position = [7 272 285 173];

            % Create ModelsDropDownLabel
            app.ModelsDropDownLabel = uilabel(app.NeuronSegmentationPanel);
            app.ModelsDropDownLabel.Position = [13 77 44 22];
            app.ModelsDropDownLabel.Text = 'Models';

            % Create ModelsDropDown
            app.ModelsDropDown = uidropdown(app.NeuronSegmentationPanel);
            app.ModelsDropDown.Items = {'cyto2', 'cyto'};
            app.ModelsDropDown.ValueChangedFcn = createCallbackFcn(app, @ModelsDropDownValueChanged, true);
            app.ModelsDropDown.Tooltip = {'segmentation model'};
            app.ModelsDropDown.Position = [88 77 100 22];
            app.ModelsDropDown.Value = 'cyto2';

            % Create ThresholdSpinnerLabel
            app.ThresholdSpinnerLabel = uilabel(app.NeuronSegmentationPanel);
            app.ThresholdSpinnerLabel.Position = [13 46 58 22];
            app.ThresholdSpinnerLabel.Text = 'Threshold';

            % Create ThresholdSpinner
            app.ThresholdSpinner = uispinner(app.NeuronSegmentationPanel);
            app.ThresholdSpinner.Step = 0.05;
            app.ThresholdSpinner.LowerLimitInclusive = 'off';
            app.ThresholdSpinner.Limits = [0 3];
            app.ThresholdSpinner.ValueChangedFcn = createCallbackFcn(app, @ThresholdSpinnerValueChanged, true);
            app.ThresholdSpinner.Tooltip = {'set  higher to get more cells, in range from (0,3]'};
            app.ThresholdSpinner.Position = [87 46 55 22];
            app.ThresholdSpinner.Value = 0.4;

            % Create RunModelButton
            app.RunModelButton = uibutton(app.NeuronSegmentationPanel, 'push');
            app.RunModelButton.ButtonPushedFcn = createCallbackFcn(app, @RunModelButtonPushed, true);
            app.RunModelButton.Position = [13 11 228 23];
            app.RunModelButton.Text = 'Run Model';

            % Create LoadSegImageButton
            app.LoadSegImageButton = uibutton(app.NeuronSegmentationPanel, 'push');
            app.LoadSegImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSegImageButtonPushed, true);
            app.LoadSegImageButton.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'folder-open.svg');
            app.LoadSegImageButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.LoadSegImageButton.Tooltip = {'Load Image to Segmentation'};
            app.LoadSegImageButton.Position = [13 114 152 23];
            app.LoadSegImageButton.Text = 'Load Structure Image';

            % Create StructureTypeDropDown
            app.StructureTypeDropDown = uidropdown(app.NeuronSegmentationPanel);
            app.StructureTypeDropDown.Items = {'normal imaging', '1/10 Imaging'};
            app.StructureTypeDropDown.Position = [179 114 79 22];
            app.StructureTypeDropDown.Value = 'normal imaging';

            % Create ManualcorrectionPanel
            app.ManualcorrectionPanel = uipanel(app.LeftPanel);
            app.ManualcorrectionPanel.AutoResizeChildren = 'off';
            app.ManualcorrectionPanel.Title = '3. Manual correction';
            app.ManualcorrectionPanel.SizeChangedFcn = createCallbackFcn(app, @ManualcorrectionPanelSizeChanged, true);
            app.ManualcorrectionPanel.Position = [8 125 284 136];

            % Create MaskDropDownLabel
            app.MaskDropDownLabel = uilabel(app.ManualcorrectionPanel);
            app.MaskDropDownLabel.Position = [16 76 34 22];
            app.MaskDropDownLabel.Text = 'Mask';

            % Create MaskDropDown
            app.MaskDropDown = uidropdown(app.ManualcorrectionPanel);
            app.MaskDropDown.Items = {'Colored', 'Binary'};
            app.MaskDropDown.ValueChangedFcn = createCallbackFcn(app, @MaskDropDownValueChanged, true);
            app.MaskDropDown.Tooltip = {'Choose mask style to display: colored mask or binary mask'};
            app.MaskDropDown.Position = [65 76 100 22];
            app.MaskDropDown.Value = 'Colored';

            % Create MaskOnCheckBox
            app.MaskOnCheckBox = uicheckbox(app.ManualcorrectionPanel);
            app.MaskOnCheckBox.ValueChangedFcn = createCallbackFcn(app, @MaskOnCheckBoxValueChanged, true);
            app.MaskOnCheckBox.Text = '';
            app.MaskOnCheckBox.FontColor = [0.3922 0.8314 0.0745];
            app.MaskOnCheckBox.Position = [188 75 14 22];

            % Create ROIdilateSpinnerLabel
            app.ROIdilateSpinnerLabel = uilabel(app.ManualcorrectionPanel);
            app.ROIdilateSpinnerLabel.Position = [16 45 62 22];
            app.ROIdilateSpinnerLabel.Text = 'ROI  dilate';

            % Create ROIdilateSpinner
            app.ROIdilateSpinner = uispinner(app.ManualcorrectionPanel);
            app.ROIdilateSpinner.Limits = [0 Inf];
            app.ROIdilateSpinner.ValueChangedFcn = createCallbackFcn(app, @ROIdilateSpinnerValueChanged, true);
            app.ROIdilateSpinner.Tooltip = {'Dilate roi mask, in range from [0,+∞}'};
            app.ROIdilateSpinner.Position = [93 45 100 22];

            % Create LoadMaskButton
            app.LoadMaskButton = uibutton(app.ManualcorrectionPanel, 'push');
            app.LoadMaskButton.ButtonPushedFcn = createCallbackFcn(app, @LoadMaskButtonPushed, true);
            app.LoadMaskButton.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'upload.svg');
            app.LoadMaskButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.LoadMaskButton.Tooltip = {'Load external mask  '};
            app.LoadMaskButton.Position = [15 11 98 23];
            app.LoadMaskButton.Text = 'Load Mask';

            % Create SaveMaskButton
            app.SaveMaskButton = uibutton(app.ManualcorrectionPanel, 'push');
            app.SaveMaskButton.ButtonPushedFcn = createCallbackFcn(app, @SaveMaskButtonPushed, true);
            app.SaveMaskButton.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'save.svg');
            app.SaveMaskButton.Tooltip = {'choose where to save mask as .mat and .jpg'};
            app.SaveMaskButton.Position = [147 11 100 23];
            app.SaveMaskButton.Text = 'Save Mask';

            % Create ROIImagingPanel
            app.ROIImagingPanel = uipanel(app.LeftPanel);
            app.ROIImagingPanel.Title = '4. ROI Imaging';
            app.ROIImagingPanel.Position = [7 7 285 105];

            % Create LaserROIImagingButton
            app.LaserROIImagingButton = uibutton(app.ROIImagingPanel, 'push');
            app.LaserROIImagingButton.ButtonPushedFcn = createCallbackFcn(app, @LaserROIImagingButtonPushed, true);
            app.LaserROIImagingButton.Position = [14 41 100 23];
            app.LaserROIImagingButton.Text = 'ROI Imaging';

            % Create AbortButton
            app.AbortButton = uibutton(app.ROIImagingPanel, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @AbortButtonPushed, true);
            app.AbortButton.Position = [149 41 98 23];
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
            app.RealtimeregistrationButton.Position = [14 9 129 23];
            app.RealtimeregistrationButton.Text = 'Real-time registration';

            % Create SettingsPanel
            app.SettingsPanel = uipanel(app.LeftPanel);
            app.SettingsPanel.Title = 'Settings';
            app.SettingsPanel.Position = [7 536 285 130];

            % Create AwgConnectButton
            app.AwgConnectButton = uibutton(app.SettingsPanel, 'push');
            app.AwgConnectButton.ButtonPushedFcn = createCallbackFcn(app, @AwgConnectButtonPushed, true);
            app.AwgConnectButton.Position = [174 77 75 23];
            app.AwgConnectButton.Text = 'Connect';

            % Create AWGStatusLabel
            app.AWGStatusLabel = uilabel(app.SettingsPanel);
            app.AWGStatusLabel.Position = [14 78 71 22];
            app.AWGStatusLabel.Text = 'AWG Status';

            % Create isConnectedLabel
            app.isConnectedLabel = uilabel(app.SettingsPanel);
            app.isConnectedLabel.Position = [96 78 78 22];
            app.isConnectedLabel.Text = 'Disconnected';

            % Create ConfigFileSelectButton
            app.ConfigFileSelectButton = uibutton(app.SettingsPanel, 'push');
            app.ConfigFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @ConfigFileSelectButtonPushed, true);
            app.ConfigFileSelectButton.Position = [230 45 20 23];
            app.ConfigFileSelectButton.Text = '...';

            % Create AdvancedSettingsOpenButton
            app.AdvancedSettingsOpenButton = uibutton(app.SettingsPanel, 'push');
            app.AdvancedSettingsOpenButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedSettingsOpenButtonPushed, true);
            app.AdvancedSettingsOpenButton.Position = [171 12 79 23];
            app.AdvancedSettingsOpenButton.Text = 'Advanced';

            % Create ConfigurationEditFieldLabel
            app.ConfigurationEditFieldLabel = uilabel(app.SettingsPanel);
            app.ConfigurationEditFieldLabel.Position = [14 46 77 22];
            app.ConfigurationEditFieldLabel.Text = 'Configuration';

            % Create ConfigurationFileEditField
            app.ConfigurationFileEditField = uieditfield(app.SettingsPanel, 'text');
            app.ConfigurationFileEditField.Position = [95 46 129 22];

            % Create ScanimageButton
            app.ScanimageButton = uibutton(app.SettingsPanel, 'state');
            app.ScanimageButton.ValueChangedFcn = createCallbackFcn(app, @ScanimageButtonValueChanged, true);
            app.ScanimageButton.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'ScanImage.png');
            app.ScanimageButton.Text = '';
            app.ScanimageButton.BackgroundColor = [1 0 0];
            app.ScanimageButton.FontColor = [0.149 0.149 0.149];
            app.ScanimageButton.Position = [17 12 82 23];

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
            app.Laser1on9offButton.Position = [144 13 109 23];
            app.Laser1on9offButton.Text = '1/10 ROI Imaging';

            % Create RegularImagingButton
            app.RegularImagingButton = uibutton(app.StructureImagingPanel, 'push');
            app.RegularImagingButton.ButtonPushedFcn = createCallbackFcn(app, @RegularImagingButtonPushed, true);
            app.RegularImagingButton.Position = [13 13 103 23];
            app.RegularImagingButton.Text = 'Regular Imaging';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BorderType = 'none';
            app.RightPanel.ButtonDownFcn = createCallbackFcn(app, @RightPanelButtonDown, true);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Toolbar.Visible = 'off';
            app.UIAxes.XLimitMethod = 'tight';
            app.UIAxes.YLimitMethod = 'tight';
            app.UIAxes.ZLimitMethod = 'tight';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.BoxStyle = 'full';
            app.UIAxes.LineWidth = 1;
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [47 93 512 512];

            % Create PowerCaculatePanel
            app.PowerCaculatePanel = uipanel(app.RightPanel);
            app.PowerCaculatePanel.Title = 'Power Caculate';
            app.PowerCaculatePanel.Position = [616 394 260 270];

            % Create LaserPowermWLabel
            app.LaserPowermWLabel = uilabel(app.PowerCaculatePanel);
            app.LaserPowermWLabel.HorizontalAlignment = 'right';
            app.LaserPowermWLabel.Position = [15 206 115 22];
            app.LaserPowermWLabel.Text = 'Laser  Power(mW)';

            % Create ImagingPowerEditField
            app.ImagingPowerEditField = uieditfield(app.PowerCaculatePanel, 'numeric');
            app.ImagingPowerEditField.ValueChangedFcn = createCallbackFcn(app, @ImagingPowerEditFieldValueChanged, true);
            app.ImagingPowerEditField.Position = [145 206 100 22];

            % Create MHzPowermWEditFieldLabel
            app.MHzPowermWEditFieldLabel = uilabel(app.PowerCaculatePanel);
            app.MHzPowermWEditFieldLabel.HorizontalAlignment = 'right';
            app.MHzPowermWEditFieldLabel.Position = [17 107 113 22];
            app.MHzPowermWEditFieldLabel.Text = '0.1MHz Power(mW)';

            % Create StructurePowerEditField
            app.StructurePowerEditField = uieditfield(app.PowerCaculatePanel, 'numeric');
            app.StructurePowerEditField.Editable = 'off';
            app.StructurePowerEditField.Position = [145 107 100 22];

            % Create ROIPowermWEditField_2Label
            app.ROIPowermWEditField_2Label = uilabel(app.PowerCaculatePanel);
            app.ROIPowermWEditField_2Label.HorizontalAlignment = 'right';
            app.ROIPowermWEditField_2Label.Position = [38 72 93 22];
            app.ROIPowermWEditField_2Label.Text = 'ROI Power(mW)';

            % Create ROIPowerEditField
            app.ROIPowerEditField = uieditfield(app.PowerCaculatePanel, 'numeric');
            app.ROIPowerEditField.Editable = 'off';
            app.ROIPowerEditField.Position = [146 72 100 22];

            % Create PowerCoseLabel
            app.PowerCoseLabel = uilabel(app.PowerCaculatePanel);
            app.PowerCoseLabel.HorizontalAlignment = 'right';
            app.PowerCoseLabel.Position = [63 146 67 22];
            app.PowerCoseLabel.Text = 'Power Cost';

            % Create PowerCostEditField
            app.PowerCostEditField = uieditfield(app.PowerCaculatePanel, 'numeric');
            app.PowerCostEditField.Position = [145 146 100 22];
            app.PowerCostEditField.Value = 1;

            % Create UpdateButton
            app.UpdateButton = uibutton(app.PowerCaculatePanel, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Position = [146 176 100 23];
            app.UpdateButton.Text = 'Update';

            % Create ROIsEditFieldLabel
            app.ROIsEditFieldLabel = uilabel(app.RightPanel);
            app.ROIsEditFieldLabel.HorizontalAlignment = 'right';
            app.ROIsEditFieldLabel.Position = [47 35 32 22];
            app.ROIsEditFieldLabel.Text = 'ROIs';

            % Create ROIsEditField
            app.ROIsEditField = uieditfield(app.RightPanel, 'numeric');
            app.ROIsEditField.Limits = [0 Inf];
            app.ROIsEditField.ValueDisplayFormat = '%.0f';
            app.ROIsEditField.Editable = 'off';
            app.ROIsEditField.Position = [94 35 51 22];

            % Create ROIRatioEditField_2Label
            app.ROIRatioEditField_2Label = uilabel(app.RightPanel);
            app.ROIRatioEditField_2Label.HorizontalAlignment = 'right';
            app.ROIRatioEditField_2Label.Position = [371 35 58 22];
            app.ROIRatioEditField_2Label.Text = 'ROI Ratio';

            % Create ROIRatioEditField
            app.ROIRatioEditField = uieditfield(app.RightPanel, 'numeric');
            app.ROIRatioEditField.Limits = [0 Inf];
            app.ROIRatioEditField.ValueDisplayFormat = '%.3f';
            app.ROIRatioEditField.Editable = 'off';
            app.ROIRatioEditField.Position = [444 35 100 22];

            % Create UIAxesHomeButton
            app.UIAxesHomeButton = uibutton(app.RightPanel, 'push');
            app.UIAxesHomeButton.ButtonPushedFcn = createCallbackFcn(app, @UIAxesHomeButtonPushed, true);
            app.UIAxesHomeButton.Icon = fullfile(pathToMLAPP, 'assets', 'icon', 'home.svg');
            app.UIAxesHomeButton.Position = [491 613 53 23];
            app.UIAxesHomeButton.Text = '';

            % Create AdjustButton
            app.AdjustButton = uibutton(app.RightPanel, 'state');
            app.AdjustButton.ValueChangedFcn = createCallbackFcn(app, @AdjustButtonValueChanged, true);
            app.AdjustButton.Text = 'Adjust';
            app.AdjustButton.Position = [238 615 51 23];

            % Create DropDown
            app.DropDown = uidropdown(app.RightPanel);
            app.DropDown.Items = {'AVG', 'Movie'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.Position = [45 615 100 22];
            app.DropDown.Value = 'AVG';

            % Create Label
            app.Label = uilabel(app.RightPanel);
            app.Label.Position = [1 668 2 2];

            % Create ContrastLabel
            app.ContrastLabel = uilabel(app.RightPanel);
            app.ContrastLabel.Position = [179 615 50 22];
            app.ContrastLabel.Text = 'Contrast';

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
            app.FrameSliderLabel.Position = [58 61 490 22];
            app.FrameSliderLabel.Text = '1/1000';

            % Show the figure after all components are created
            app.RoiImagingModuleUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = roi_imaging_module_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.RoiImagingModuleUIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.RoiImagingModuleUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.RoiImagingModuleUIFigure)
        end
    end
end