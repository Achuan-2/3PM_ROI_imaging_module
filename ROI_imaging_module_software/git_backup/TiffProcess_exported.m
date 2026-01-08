classdef TiffProcess_exported < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        SplitandprocessTab              matlab.ui.container.Tab
        ScanphaseCopyCH1toothersCheckBox  matlab.ui.control.CheckBox
        OutputFolderEditFieldLabel      matlab.ui.control.Label
        OutputFolderEditField           matlab.ui.control.EditField
        RegCopyCH1toothersCheckBox      matlab.ui.control.CheckBox
        ScanphasecorrectCheckBox        matlab.ui.control.CheckBox
        RandomdenosiingCheckBox         matlab.ui.control.CheckBox
        RegistrationCheckBox            matlab.ui.control.CheckBox
        FPAimagingreconstructCheckBox   matlab.ui.control.CheckBox
        ProcessButton                   matlab.ui.control.Button
        OpenfolderButton                matlab.ui.control.Button
        RemoveperiodicnoiseCheckBox     matlab.ui.control.CheckBox
        PostprocessingDropDown          matlab.ui.control.DropDown
        PostprocessingDropDownLabel     matlab.ui.control.Label
        FileSelectButton                matlab.ui.control.Button
        TiffRangeLabel                  matlab.ui.control.Label
        TifffileLabel                   matlab.ui.control.Label
        UpdateButton                    matlab.ui.control.Button
        FolderEditField                 matlab.ui.control.EditField
        FolderDropDown                  matlab.ui.control.DropDown
        StartSpinnerLabel               matlab.ui.control.Label
        StartSpinner                    matlab.ui.control.Spinner
        EndSpinnerLabel                 matlab.ui.control.Label
        EndSpinner                      matlab.ui.control.Spinner
        ConsoleTextAreaLabel            matlab.ui.control.Label
        ConsoleTextArea                 matlab.ui.control.TextArea
        nChannelSpinnerLabel            matlab.ui.control.Label
        nChannelSpinner                 matlab.ui.control.Spinner
        ClearButton                     matlab.ui.control.Button
        PeriodicdenoisingTab            matlab.ui.container.Tab
        PeriodicDenoisingConsoleTextArea  matlab.ui.control.TextArea
        PeriodicDenoisinConsoleTextAreaLabel  matlab.ui.control.Label
        PeriodicDenoisinClearButton     matlab.ui.control.Button
        PeriodicDenoisinOpenfolderButton  matlab.ui.control.Button
        PeriodicDenoisinOutputFolderLabel  matlab.ui.control.Label
        PeriodicDenoisinOutputFolderEditField  matlab.ui.control.EditField
        PeriodicDenoisinProcessButton   matlab.ui.control.Button
        PeriodicDenoisinFileSelectButton  matlab.ui.control.Button
        PeriodicDenoisinFolderEditField  matlab.ui.control.EditField
        PeriodicDenoisinFolderDropDown  matlab.ui.control.DropDown
        FPAreconstructionTab            matlab.ui.container.Tab
        FileSelectButton_ROIRebuild     matlab.ui.control.Button
        FolderEditField_ROIRebuild      matlab.ui.control.EditField
        RegisterAfterRebuildCheckBox_ROIRebuild  matlab.ui.control.CheckBox
        RunButton_ROIRebuild            matlab.ui.control.Button
        ConsoleTextArea_ROIRebuild      matlab.ui.control.TextArea
        ConsoleTextAreaLabel_ROIRebuild  matlab.ui.control.Label
        ClearButton_ROIRebuild          matlab.ui.control.Button
        RegTab                          matlab.ui.container.Tab
        regFileSelectButton             matlab.ui.control.Button
        ProcessButton_2                 matlab.ui.control.Button
        OpenFolderButton_2              matlab.ui.control.Button
        FolderEditField_2               matlab.ui.control.EditField
        ScanphaseSpinner_2              matlab.ui.control.Spinner
        FolderDropDown_2                matlab.ui.control.DropDown
        OutputFolderEditField_2Label    matlab.ui.control.Label
        OutputFolderEditField_2         matlab.ui.control.EditField
        scanphasecorrectLabel           matlab.ui.control.Label
        ScanphaseCorrectDropDown_2      matlab.ui.control.DropDown
        smooth_sigmaEditFieldLabel      matlab.ui.control.Label
        smooth_sigmaEditField           matlab.ui.control.NumericEditField
        maxregshiftEditFieldLabel       matlab.ui.control.Label
        maxregshiftEditField            matlab.ui.control.NumericEditField
        ConsoleTextArea_2Label          matlab.ui.control.Label
        ConsoleTextArea_2               matlab.ui.control.TextArea
        nimg_initEditFieldLabel         matlab.ui.control.Label
        nimg_initEditField              matlab.ui.control.NumericEditField
        batch_sizeEditFieldLabel        matlab.ui.control.Label
        batch_sizeEditField             matlab.ui.control.NumericEditField
        refFilePathEditField            matlab.ui.control.EditField
        refImgFileSelectButton          matlab.ui.control.Button
        RefimgLabel                     matlab.ui.control.Label
        OutputFolderEditFieldLabel_3    matlab.ui.control.Label
        refImgSaveCheckBox              matlab.ui.control.CheckBox
        refImgFileDeleteButton          matlab.ui.control.Button
        ClearButton_2                   matlab.ui.control.Button
        ManualRegButton                 matlab.ui.control.Button
        ScanphaseMethodDropDownLabel    matlab.ui.control.Label
        ScanphaseMethodDropDown_2       matlab.ui.control.DropDown
        ImportOffsetsButton             matlab.ui.control.Button
        RandomdenoisingTab              matlab.ui.container.Tab
        RandomdenoisingConsoleTextArea  matlab.ui.control.TextArea
        RandomdenoisingConsoleTextAreaLabel  matlab.ui.control.Label
        RandomdenoisingClearButton      matlab.ui.control.Button
        RandomdenoisingOpenFolderButton  matlab.ui.control.Button
        RandomdenoisingOutputFolderLabel  matlab.ui.control.Label
        RandomdenoisingOutputFolderEditField  matlab.ui.control.EditField
        RandomdenoisingProcessButton    matlab.ui.control.Button
        RandomdenoisingrFileSelectButton  matlab.ui.control.Button
        RandomdenoisingFolderEditField  matlab.ui.control.EditField
        RandomdenoisingFolderDropDown   matlab.ui.control.DropDown
        ScanphasecorrectTab             matlab.ui.container.Tab
        FolderDropDown_SC               matlab.ui.control.DropDown
        FolderEditField_SC              matlab.ui.control.EditField
        SelectPathButton_SC             matlab.ui.control.Button
        Label_SC_Mode                   matlab.ui.control.Label
        ScanphaseCorrectDropDown_SC     matlab.ui.control.DropDown
        ScanphaseSpinner_SC             matlab.ui.control.Spinner
        SelectROIButton_SC              matlab.ui.control.Button
        ROIInfoEditField_SC             matlab.ui.control.EditField
        Label_SC_Method                 matlab.ui.control.Label
        ScanphaseMethodDropDown_SC      matlab.ui.control.DropDown
        Label_SC_BatchSize              matlab.ui.control.Label
        ScanphaseBatchSpinner_SC        matlab.ui.control.Spinner
        ProcessButton_SC                matlab.ui.control.Button
        Label_SC_Console                matlab.ui.control.Label
        ConsoleTextArea_SC              matlab.ui.control.TextArea
        ClearButton_SC                  matlab.ui.control.Button
        ExportCSVCheckBox_SC            matlab.ui.control.CheckBox
        ImportCSVRunButton_SC           matlab.ui.control.Button
    end
    
    
    properties (Access = public)
        folder;
        folder2;
        folderToEnhance;
        tiffToEnhancePath;
        tiffpath; % 选择单个文件进行处理，保存文件路径
        tiffpath2; % 选择单个文件进行处理，保存文件路径
        tiffToExtractFolder;
        tiffToExtractPath;
        zstackProcessFolder
        zstackProcessPath
        scanphaseCorrectPath; % Path for the dedicated scanphase correction tab
        scanphaseCorrectFolder;
        scanphaseROI = []; % ROI for scanphase correction [xmin ymin width height]
        scanphaseCorrectBatchPaths = {}; % Paths for batch processing
        correctionResults; % Table to store correction results for CSV export
        roiRebuildPath; % Path for the ROI rebuild tab
        roiRebuildFolder = "";
        
        index_updated = false; % 是否选择文件夹并且点击update成功update了
        fileStartIndex;
        fileEndIndex;
        lastEndIndex;
        onlyOne = false;
        processed = 0;
        cellArrayText;
        cellArrayText2;
        cellArrayText_SC; % Console text for Scanphase Correct Tab
        cellArrayText_FPAreconstruction; % Console text for ROI Rebuild Tab
        cellArrayText_Periodicdenoising
        cellArrayText_Randomdenoising
        exePath;% app 或者exe地址
        reg_tifFiles;
    end
    
    methods (Access = private)
        
        function results = core_correct_scanphase(app, inputPath, mode, fixed_offset, method, batch_size, roi, parentProgressDlg, varargin)
            % Core function for scanphase correction. Independent of UI controls.
            
            % --- Start of modification: Input parser for optional OffsetMap ---
            p = inputParser;
            addParameter(p, 'OffsetMap', containers.Map('KeyType','double','ValueType','double'), @(x) isa(x, 'containers.Map'));
            parse(p, varargin{:});
            offsetMap = p.Results.OffsetMap;
            useOffsetMap = ~isempty(offsetMap.keys);
            % --- End of modification ---
            
            % Initialize results structure
            results = struct('FilePath', string(inputPath), 'CorrectionMode', "N/A", 'FinalOffset', NaN, ...
                'OffsetLog', "", 'ROI', "N/A", 'Status', "Failed", 'Message', "Initialization failed", 'Timestamp', datetime('now'));
            
            offset_log_entries = {}; % To store detailed offset log
            
            try
                [inputFolder, fname, fext] = fileparts(inputPath);
                
                % Define output folder and filename
                outputFolder = fullfile(inputFolder);
                if ~exist(outputFolder, 'dir')
                    mkdir(outputFolder);
                end
                outputFilename = strcat(fname, '_scancorrected', fext);
                outputPath = fullfile(outputFolder, outputFilename);
                
                app.print_console_sc(sprintf('Starting correction for: %s', fname));
                
                % Read Tiff info
                tiffInput = Tiff(inputPath, 'r');
                info = imfinfo(inputPath);
                numFrames = numel(info);
                if numFrames <= 1
                    msg = 'File has only one frame. Nothing to correct.';
                    app.print_console_sc(msg);
                    results.Status = 'Skipped';
                    results.Message = msg;
                    tiffInput.close();
                    return;
                end
                
                % Get image dimensions and tags
                tiffInput.setDirectory(1);
                sampleFrame = tiffInput.read();
                [imgHeight, imgWidth] = size(sampleFrame);
                tags = utils.tiff_read_tag(inputPath);
                
                if isfield(tags, 'ImageDescription')
                    desc = tags.ImageDescription;
                else
                    desc = [];
                end
                
                % --- Determine bidiphase offset ---
                bidphase = 0;
                
                % --- Start of modification: Handle OffsetMap ---
                if useOffsetMap
                    app.print_console_sc('Using offsets from provided map (from CSV).');
                    % bidphase remains 0 here, it will be set per batch from the map
                    % --- End of modification ---
                elseif strcmp(mode, 'Fixed')
                    bidphase = fixed_offset;
                    app.print_console_sc(sprintf('Using fixed scanphase offset: %d', bidphase));
                elseif strcmp(mode, 'Auto')
                    app.print_console_sc('Starting auto prediction of scanphase offset.');
                    if isvalid(parentProgressDlg)
                        parentProgressDlg.Message = sprintf('Predicting scanphase for %s...', fname);
                        parentProgressDlg.Indeterminate = 'on';
                    end
                    
                    nimg_init = min(300, numFrames);
                    init_frames = zeros(imgHeight, imgWidth, nimg_init, 'like', sampleFrame);
                    for i = 1:nimg_init
                        tiffInput.setDirectory(i);
                        init_frames(:, :, i) = tiffInput.read();
                    end
                    
                    if ~isempty(roi)
                        x_start = floor(roi(1)); y_start = floor(roi(2));
                        x_end = floor(roi(1) + roi(3) - 1); y_end = floor(roi(2) + roi(4) - 1);
                        x_end = min(x_end, imgWidth); y_end = min(y_end, imgHeight);
                        cropped_frames = init_frames(y_start:y_end, x_start:x_end, :);
                        bidphase = RIMA.scanphase_predict(cropped_frames);
                        app.print_console_sc(sprintf('Predicted scanphase from ROI: %d', bidphase));
                    else
                        bidphase = RIMA.scanphase_predict(init_frames);
                        app.print_console_sc(sprintf('Predicted scanphase from full frame: %d', bidphase));
                    end
                    clear init_frames;
                end
                
                results.FinalOffset = bidphase; % Log the main/initial offset
                
                if ~useOffsetMap && bidphase == 0 && ~strcmp(method, 'Batch')
                    msg = 'Scanphase offset is 0. No correction needed.';
                    app.print_console_sc(msg);
                    tiffInput.close();
                    results.Status = 'Skipped';
                    results.Message = msg;
                    results.FinalOffset = 0;
                    results.OffsetLog = '0';
                    results.CorrectionMode = string(mode);
                    return;
                end
                
                if isvalid(parentProgressDlg)
                    parentProgressDlg.Indeterminate = 'off';
                end
                
                % --- Prepare for writing output ---
                fileInfo = dir(inputPath);
                isBigTiff = fileInfo.bytes > 4e9;
                
                if isBigTiff
                    tiffOutput = Fast_BigTiff_Write(outputPath, tags.XResolution, 0, desc);
                else
                    tiffOutput = Fast_Tiff_Write(outputPath, tags.XResolution, 0, desc);
                end
                
                % --- Apply correction ---
                for startFrame = 1:batch_size:numFrames
                    if isvalid(parentProgressDlg) && parentProgressDlg.CancelRequested
                        app.print_console_sc('Process cancelled by user.');
                        break;
                    end
                    
                    endFrame = min(startFrame + batch_size - 1, numFrames);
                    numBatchFrames = endFrame - startFrame + 1;
                    
                    framesBatch = zeros(imgHeight, imgWidth, numBatchFrames, 'like', sampleFrame);
                    for i = 1:numBatchFrames
                        tiffInput.setDirectory(startFrame + i - 1);
                        framesBatch(:, :, i) = tiffInput.read();
                    end
                    
                    % --- Start of modification: Determine current_bidphase logic ---
                    current_bidphase = bidphase; % Default to the initial value
                    if useOffsetMap
                        if isKey(offsetMap, startFrame)
                            current_bidphase = offsetMap(startFrame);
                        else
                            app.print_console_sc(sprintf('WARNING: No offset in map for frame %d. Using 0.', startFrame));
                            current_bidphase = 0;
                        end
                    elseif strcmp(method, 'Batch') && strcmp(mode, 'Auto')
                        if ~isempty(roi)
                            x_start = floor(roi(1)); y_start = floor(roi(2));
                            x_end = floor(roi(1)+roi(3)-1); y_end = floor(roi(2)+roi(4)-1);
                            x_end = min(x_end, imgWidth); y_end = min(y_end, imgHeight);
                            cropped_batch = framesBatch(y_start:y_end, x_start:x_end, :);
                            current_bidphase = RIMA.scanphase_predict(cropped_batch);
                        else
                            current_bidphase = RIMA.scanphase_predict(framesBatch);
                        end
                        app.print_console_sc(sprintf('Frames %d-%d, Scanphase predicted: %d', startFrame, endFrame, current_bidphase));
                        offset_log_entries{end+1} = sprintf('%d-%d:%d', startFrame, endFrame, current_bidphase);
                    end
                    % --- End of modification ---
                    
                    if current_bidphase ~= 0
                        framesBatch = RIMA.scanphase_correct(framesBatch, current_bidphase);
                    end
                    
                    for i = 1:numBatchFrames
                        tiffOutput.WriteIMG(framesBatch(:, :, i)');
                    end
                    
                    if isvalid(parentProgressDlg)
                        parentProgressDlg.Message = sprintf('Correcting %s [%d/%d]', fname, endFrame, numFrames);
                        parentProgressDlg.Value = endFrame / numFrames;
                    end
                end
                
                tiffInput.close();
                close(tiffOutput);
                
                if isvalid(parentProgressDlg) && parentProgressDlg.CancelRequested
                    delete(outputPath);
                    results.Status = 'Cancelled';
                    results.Message = 'User cancelled operation.';
                else
                    app.print_console_sc(sprintf('Correction completed. Saved to: %s', outputPath));
                    results.Status = 'Success';
                    results.Message = ['Saved to ' outputPath];
                end
                
            catch ME
                utils.report_error(ME);
                app.print_console_sc(['ERROR: ' ME.message]);
                if exist('tiffInput', 'var') && tiffInput.isOpen()
                    tiffInput.close();
                end
                if exist('tiffOutput', 'var')
                    close(tiffOutput);
                end
                results.Status = 'Failed';
                results.Message = ME.message;
            end
            
            % --- Start of modification: Finalize results log ---
            if isempty(offset_log_entries)
                if useOffsetMap
                    offset_log_entries{end+1} = 'Applied from CSV Map';
                elseif bidphase ~= 0
                    offset_log_entries{end+1} = sprintf('1-%d:%d', numFrames, bidphase);
                else
                    offset_log_entries{end+1} = '0';
                end
            end
            results.OffsetLog = strjoin(offset_log_entries, '; ');
            results.CorrectionMode = string(mode);
            if useOffsetMap
                results.CorrectionMode = "FromCSV";
            end
            
            if ~isempty(roi)
                results.ROI = mat2str(roi);
            else
                results.ROI = "None";
            end
            % --- End of modification ---
        end
        
        
        function update_tiff_index(app)
            % 获取指定文件的编号范围
            [app.fileStartIndex,app.fileEndIndex] = utils.get_tiff_num_range(app.folder);
            
            if isempty(app.fileEndIndex)
                errordlg('该文件夹不存在待分割的tif图片！');
                app.StartSpinner.Enable = "off";
                app.EndSpinner.Enable = "off";
                app.ProcessButton.Enable = "off";
                app.OpenfolderButton.Enable = "off";
                return;
            end
            
            fileNum = app.fileEndIndex- app.fileStartIndex+1;
            
            if fileNum > 1
                app.onlyOne = false;
            else
                app.onlyOne = true;
            end
            % 更新文件编号范围
            app.TiffRangeLabel.Text = sprintf('file_%05d ~ file_%05d', app.fileStartIndex,app.fileEndIndex);
            
            % 点击Update，更新start index 和 end index
            app.StartSpinner.Value = app.fileStartIndex;
            app.EndSpinner.Value =  app.fileEndIndex;
            
            if  ~isempty(app.lastEndIndex)
                if app.lastEndIndex == app.fileEndIndex
                    % 反复点击update，而文件没有新增，strat index依然为上次处理的文件编号
                    app.StartSpinner.Value = app.lastEndIndex;
                elseif app.lastEndIndex < app.fileEndIndex
                    % 如果文件新增，strat index为上次处理的文件编号+1
                    app.StartSpinner.Value = app.lastEndIndex+1;
                end
            end
            
            % update ui
            app.StartSpinner.Enable = "on";
            app.EndSpinner.Enable = "on";
            app.ProcessButton.Enable = "on";
            app.OpenfolderButton.Enable = "on";
            app.index_updated = true;
        end
        
        function print_console(app, str)
            % 获取当前选择的选项卡
            selectedTab = app.TabGroup.SelectedTab;
            
            % 根据选择的选项卡确定目标控制台和文本缓冲区
            switch selectedTab
                case app.SplitandprocessTab
                    targetConsole = app.ConsoleTextArea;
                    bufferProperty = 'cellArrayText';
                case app.RegTab
                    targetConsole = app.ConsoleTextArea_2;
                    bufferProperty = 'cellArrayText2';
                case app.ScanphasecorrectTab
                    targetConsole = app.ConsoleTextArea_SC;
                    bufferProperty = 'cellArrayText_SC';
                case app.FPAreconstructionTab
                    targetConsole = app.ConsoleTextArea_ROIRebuild;
                    bufferProperty = 'cellArrayText_FPAreconstruction';
                case app.PeriodicdenoisingTab
                    targetConsole = app.PeriodicDenoisingConsoleTextArea;
                    bufferProperty = 'cellArrayText_Periodicdenoising';
                case app.RandomdenoisingTab
                    targetConsole = app.RandomdenoisingConsoleTextArea;
                    bufferProperty = 'cellArrayText_Randomdenoising';
                otherwise
                    % 如果找不到匹配的选项卡，则在命令行窗口中显示警告
                    warning('无法找到目标控制台。消息: %s', str);
                    return;
            end
            
            % 格式化并更新日志消息
            time = datetime("now", "Format", "HH:mm:ss");
            string = sprintf('%s\n%s\n', time, str);
            
            % 从app属性中获取并更新缓冲区
            currentBuffer = app.(bufferProperty);
            newBuffer = horzcat(currentBuffer, string);
            app.(bufferProperty) = newBuffer;
            
            % 更新UI中的TextArea并滚动到底部
            targetConsole.Value = newBuffer;
            scroll(targetConsole, 'bottom');
        end
        
        function print_console2(app,str)
            time = datetime("now","Format","HH:mm:ss");
            string = sprintf('%s\n%s\n', time,str); % 将数据格式化为字符串或字符向量
            app.cellArrayText2=horzcat(app.cellArrayText2,string); % 水平串联数组
            app.ConsoleTextArea_2.Value = app.cellArrayText2; % 给TextArea赋值
            % 自动翻滚到底端
            scroll(app.ConsoleTextArea_2,'bottom');
        end
        
        function print_console_sc(app, str)
            time = datetime("now", "Format", "HH:mm:ss");
            string = sprintf('%s\n%s\n', time, str);
            app.cellArrayText_SC = horzcat(app.cellArrayText_SC, string);
            app.ConsoleTextArea_SC.Value = app.cellArrayText_SC;
            scroll(app.ConsoleTextArea_SC, 'bottom');
        end
        
        function process_folder(app)
            % 定义放置处理图像的文件夹
            folderProcessed = fullfile(app.folder, app.OutputFolderEditField.Value);
            
            % 如果文件夹不存在，创建新的文件夹
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed);
            end
            
            
            % 指定的起始和结束编号
            startIdx = app.StartSpinner.Value;
            endIdx = app.EndSpinner.Value;
            
            % 调用进度条
            progressDlg = uiprogressdlg(app.UIFigure,'Title','Processing',...
                'Cancelable','on','Interpreter','html');
            numFiles = endIdx-startIdx+1; % 要处理的文件
            count = 1; % 开始计数
            isRight = true;
            for idx = startIdx:endIdx
                % 为了进度条的取消可以中断处理
                if progressDlg.CancelRequested
                    break
                end
                
                % 构建文件名
                try
                    filename = sprintf('file_%05d.tif', idx);
                    filepath = fullfile(app.folder, filename);
                    progressDlg.Message = sprintf('<b>%d/%d</b> files: <b>%s</b>', count, numFiles, filename);
                    
                    % 分割通道
                    split_channel(app,filepath,folderProcessed,app.nChannelSpinner.Value,progressDlg);
                    
                    % 处理完成
                    app.print_console(sprintf('Processed: file_%05d.tif', idx));
                catch ME
                    if ME.identifier == "MATLAB:imagesci:imfinfo:fileOpen"
                        app.print_console('文件不存在或者正在生成！');
                    else
                        app.print_console(ME.message);
                        utils.report_error(ME);
                    end
                    
                    isRight =false;
                end
                % Update progress, report current estimate
                progressDlg.Value = count/numFiles;
                count = count + 1;
                
            end
            if isRight
                app.lastEndIndex = app.fileEndIndex;
            end
            % Close the dialog box
            close(progressDlg)
        end
        
        
        function process_file(app)
            % 定义放置处理图像的文件夹
            [directory, fname, fext] = fileparts(app.tiffpath);
            filename = strcat(fname, fext);
            folderProcessed = fullfile(directory, app.OutputFolderEditField.Value);
            
            % 如果文件夹不存在，创建新的文件夹
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed);
            end
            
            % 调用进度条
            progressDlg = uiprogressdlg(app.UIFigure,'Title','Processing',...
                'Cancelable','on','Interpreter','html');
            
            
            % 构建文件名
            try
                progressDlg.Message = sprintf('<b>%s</b>', filename);
                
                % 分割通道
                split_channel(app,app.tiffpath,folderProcessed,app.nChannelSpinner.Value,progressDlg);
                
                % 处理完成
                app.print_console(sprintf('Processed: %s', app.tiffpath));
            catch ME
                if ME.identifier == "MATLAB:imagesci:Tiff:unableToOpenFile"
                    app.print_console('文件不存在或者正在生成！');
                else
                    app.print_console(ME.message);
                    utils.report_error(ME);
                end
                
            end
            
            
            % Close the dialog box
            close(progressDlg)
        end
        
        function split_channel(app,filepath,folderProcessed,nChannels,progressDlg)
            progressDlgMessage = progressDlg.Message;
            [~, fname, ~] = fileparts(filepath);
            
            % Step 1: Split channels (ripple noise correction happens here)
            utils.tiff_split(filepath, nChannels, 'FolderProcessed',folderProcessed, 'AvgOutput', true, 'rippleNoiseEnable',false,'rippleNoise', 0,'progressDlg',progressDlg);
            
            % Step 2: Process each channel (Scanphase, Registration, JSON logging)
            initial_bidphase = 0;
            ch1_motion_offsets = [];
            
            selectedChannel = app.PostprocessingDropDown.Value; % 'All', 'CH1', 'CH2', etc.
            
            
            for i = 1:nChannels
                % Filtering by selected channel
                if ~strcmp(selectedChannel, 'All')
                    targetCh = sscanf(selectedChannel, 'CH%d');
                    if i ~= targetCh
                        continue;
                    end
                end
                % Reset progress bar message
                progressDlg.Message = sprintf("%s <b>CH%d</b>", progressDlgMessage, i);
                
                baseFilename = sprintf('%s_ch%d.tif', fname, i);
                currentFilePath = fullfile(folderProcessed, baseFilename);
                % 1. Remove periodic noise
                if app.RemoveperiodicnoiseCheckBox.Value
                    currentFilePath = app.remove_periodic_noise(currentFilePath);
                end
                % 2. FPA imaging reconstruct
                if app.FPAimagingreconstructCheckBox.Value
                    currentFilePath = app.fpa_reconstruct(currentFilePath);
                end
                
                % 3. --- Scanphase Correction ---
                if app.ScanphasecorrectCheckBox.Value
                    mode = app.ScanphaseCorrectDropDown_SC.Value;
                    fixed_offset = app.ScanphaseSpinner_SC.Value;
                    
                    if app.ScanphaseCopyCH1toothersCheckBox.Value
                        if i == 1 || (strcmp(selectedChannel, sprintf('CH%d', i)) && initial_bidphase == 0)
                            [initial_bidphase, ~]  = app.scanphase_correct(currentFilePath, folderProcessed,mode, fixed_offset,progressDlg);
                        else
                            app.scanphase_correct(currentFilePath,folderProcessed, 'Fixed', initial_bidphase,  progressDlg);
                        end
                    else
                        app.scanphase_correct(currentFilePath,folderProcessed, mode, fixed_offset,progressDlg);
                    end
                end
                
                % 4. Motion Registration (using RegTab parameters)
                if app.RegistrationCheckBox.Value
                    progressDlg.Message = sprintf("%s <b>CH%d Registration</b>",progressDlgMessage,i);
                    
                    % We use settings from RegTab
                    scanphase_mode = app.ScanphaseCorrectDropDown_2.Value;
                    scanphase_offset = app.ScanphaseSpinner_2.Value;
                    refimg = app.refFilePathEditField.Value;
                    
                    if app.RegCopyCH1toothersCheckBox.Value
                        % This logic is a bit tricky if we have multiple steps before reg.
                        % For now, we follow the user's intent to use RegTab settings.
                        if i == 1
                            [ch1_motion_offsets, currentFilePath] = registration(app, currentFilePath, folderProcessed, true, scanphase_mode, scanphase_offset, refimg, progressDlg, @app.print_console);
                        else
                            if ~isempty(ch1_motion_offsets)
                                [~, currentFilePath] = registration(app, currentFilePath, folderProcessed, true, "Off", 0, "", progressDlg, @app.print_console, 'ApplyOffsets', ch1_motion_offsets);
                            else
                                app.print_console(sprintf('CH%d: Skipping registration, no offsets from CH1.', i));
                            end
                        end
                    else
                        [~, currentFilePath] = registration(app, currentFilePath, folderProcessed, true, scanphase_mode, scanphase_offset, refimg, progressDlg, @app.print_console);
                    end
                end
                
                % 5. Remove random noise
                if app.RandomdenosiingCheckBox.Value
                    currentFilePath = app.remove_random_noise(currentFilePath);
                end
                
                % Update progress
                progressDlg.Value = i / nChannels;
            end
        end
        function saveOrUpdateProcessJSON(app, processName, paramsStruct)
            % 保存或更新一个包含处理参数的JSON文件。
            % 如果一个具有相同 processName 和 outputFile 的条目已存在，则更新它。
            % 否则，将新条目追加到文件末尾。
            
            if ~isfield(paramsStruct, 'outputFile') || isempty(paramsStruct.outputFile)
                app.print_console('警告: 在参数中找不到 outputFile，无法保存JSON日志。');
                return;
            end
            
            [folder, baseName, ~] = fileparts(paramsStruct.outputFile);
            % 标准化JSON文件名，使其基于被处理的TIFF文件
            jsonFilePath = fullfile(folder, [baseName '_processed.json']);
            
            allProcesses = {};
            if exist(jsonFilePath, 'file')
                try
                    jsonText = fileread(jsonFilePath);
                    if ~isempty(jsonText)
                        allProcesses = jsondecode(jsonText);
                        % 确保 allProcesses 是一个 cell 数组以便于处理
                        if ~iscell(allProcesses)
                            allProcesses = {allProcesses};
                        end
                    end
                catch ME
                    app.print_console(sprintf('警告: 无法读取JSON日志文件 %s。将创建一个新文件。错误: %s', jsonFilePath, ME.message));
                    allProcesses = {};
                end
            end
            
            % 为当前处理创建一个新的条目
            newProcessEntry = struct();
            newProcessEntry.processName = processName;
            newProcessEntry.timestamp = datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z''');
            newProcessEntry.parameters = paramsStruct;
            
            entryUpdated = false;
            % 循环遍历已有的处理记录，查找匹配项以进行更新
            for i = 1:numel(allProcesses)
                % 检查条目是否为有效的结构体并包含必要的字段
                if isstruct(allProcesses{i}) && isfield(allProcesses{i}, 'processName') && isfield(allProcesses{i}, 'parameters') && isfield(allProcesses{i}.parameters, 'outputFile')
                    
                    % 基于处理名称 和 被处理的具体文件 进行匹配
                    isMatch = strcmp(allProcesses{i}.processName, processName) && ...
                        strcmp(allProcesses{i}.parameters.outputFile, paramsStruct.outputFile);
                    
                    if isMatch
                        allProcesses{i} = newProcessEntry; % 更新条目
                        entryUpdated = true;
                        break;
                    end
                end
            end
            
            % 如果没有更新任何现有条目，则将新条目追加到末尾
            if ~entryUpdated
                allProcesses{end+1} = newProcessEntry;
            end
            
            % 转换为JSON并保存
            try
                jsonStr = jsonencode(allProcesses, 'PrettyPrint', true);
                fid = fopen(jsonFilePath, 'w', 'n', 'UTF-8');
                if fid == -1
                    app.print_console(sprintf('错误: 无法创建或写入JSON日志文件: %s', jsonFilePath));
                    return;
                end
                fprintf(fid, '%s', jsonStr);
                fclose(fid);
            catch ME
                app.print_console(sprintf('保存JSON日志文件时出错: %s', ME.message));
            end
        end
        
        function reg_folder(app)
            % 定义放置处理图像的文件夹
            folderProcessed = fullfile(app.folder2, app.OutputFolderEditField_2.Value);
            % 文件夹有多少tif
            filePattern = fullfile(app.folder2, '*.tif');
            app.reg_tifFiles = dir(filePattern);
            % 如果文件夹不存在，创建新的文件夹
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed);
            end
            
            % --- 预处理：筛选需要处理的多帧文件 ---
            allFiles = app.reg_tifFiles; % 获取所有候选文件列表
            numTotalFiles = length(allFiles);
            filesToProcess = struct('name', {}, 'folder', {}, 'date', {}, 'bytes', {}, 'isdir', {}, 'datenum', {}); % 初始化一个空的结构体数组来存储有效文件
            validIndices = []; % 存储有效文件在原列表中的索引 (可选)
            validFileCount = 0; % 计数有效文件
            
            
            % （可选）为文件扫描添加一个简单的进度提示
            scanDlg = uiprogressdlg(app.UIFigure,'Title','扫描文件',...
                'Message','正在检查文件帧数...','Indeterminate','off', 'Cancelable','on');
            
            for i = 1:numTotalFiles
                % 检查扫描进度条是否被取消
                if scanDlg.CancelRequested
                    app.print_console2('文件扫描已取消。');
                    close(scanDlg);
                    return; % 如果扫描被取消，则退出函数
                end
                scanDlg.Value = i / numTotalFiles; % 更新扫描进度
                
                filename = allFiles(i).name;
                filepath = fullfile(app.folder2, filename);
                scanDlg.Message = sprintf('正在检查 (%d/%d): %s', i, numTotalFiles, filename);
                
                try
                    % 获取图像文件的信息
                    info = imfinfo(filepath);
                    % 获取帧数
                    numFrames = numel(info);
                    if numFrames > 1 % 只处理多帧文件
                        validFileCount = validFileCount + 1;
                        filesToProcess(validFileCount) = allFiles(i); % 将有效文件添加到新列表
                        validIndices(validFileCount) = i; % (可选) 记录索引
                    else
                        app.print_console2(sprintf('跳过单帧文件: %s', filename));
                    end
                catch ME
                    app.print_console2(sprintf('读取文件信息时出错 %s: %s. 跳过此文件。', filename, ME.message));
                end
            end
            close(scanDlg); % 关闭扫描进度条
            
            % 获取真正要处理的文件数量
            numFilesToProcess = validFileCount;
            
            if numFilesToProcess == 0
                uialert(app.UIFigure, '在文件夹中未找到多帧 TIFF', '无文件处理');
                return; % 如果没有文件需要处理，则退出
            end
            
            app.print_console2(sprintf('找到 %d 个多帧文件进行处理。', numFilesToProcess));
            
            % --- 开始处理有效文件 ---
            % 调用进度条，总数使用筛选后的文件数
            progressDlg = uiprogressdlg(app.UIFigure,'Title','正在配准',...
                'Cancelable','on','Interpreter','html'); % 可以先设置为 Indeterminate='off', Value=0
            progressDlg.Value = 0; % 明确从0开始
            
            isRight = true;
            
            for k = 1:numFilesToProcess % 循环遍历筛选后的文件列表
                % 为了进度条的取消可以中断处理
                if progressDlg.CancelRequested
                    % isRight = false; % 如果取消，设置标志位（如果需要）
                    app.print_console2('用户取消了配准过程。');
                    break;
                end
                
                % 从筛选后的列表中获取当前文件信息
                currentFile = filesToProcess(k);
                filename = currentFile.name;
                filepath = fullfile(app.folder2, filename); % 重新构建完整路径
                
                % 更新进度条消息，使用筛选后的总数和当前计数
                progressDlg.Message = sprintf('<b>%d/%d</b> 文件: <b>%s</b>', k, numFilesToProcess, filename);
                
                try
                    % --- MODIFICATION START: Updated registration call ---
                    % The saving of the motion offset CSV is now handled inside the registration function.
                    [~, ~] = registration(app, filepath, folderProcessed, true, app.ScanphaseCorrectDropDown_2.Value, app.ScanphaseSpinner_2.Value, app.refFilePathEditField.Value, progressDlg, @app.print_console2);
                    % --- MODIFICATION END ---
                    
                    % 处理完成
                    app.print_console2(sprintf('已处理: %s', filepath));
                    
                catch ME
                    app.print_console2(sprintf('处理文件 %s 时发生错误: %s', filename, ME.message));
                    isRight = false; % 如果出错，设置标志位（如果需要）
                    % 根据需要决定是继续处理下一个文件还是中断
                    continue; % 继续下一个
                    % break; % 中断循环
                end
                
                % 更新进度条的值
                progressDlg.Value = k / numFilesToProcess;
                
            end
            
            if isRight % 这部分逻辑根据 isRight 的实际用途来决定如何处理
                app.lastEndIndex = app.fileEndIndex;
            end
            
            % 关闭进度条对话框
            close(progressDlg);
            
        end
        
        
        
        function reg_file(app)
            % 定义放置处理图像的文件夹
            [directory, fname, fext] = fileparts(app.tiffpath2);
            filename = strcat(fname, fext);
            folderProcessed = fullfile(directory, app.OutputFolderEditField_2.Value);
            
            % 如果文件夹不存在，创建新的文件夹
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed);
            end
            
            
            
            % 调用进度条
            progressDlg = uiprogressdlg(app.UIFigure,'Title','Processing',...
                'Indeterminate','on','Interpreter','html');
            
            
            
            try
                progressDlg.Message = sprintf('<b>%s</b>', filename);
                
                % 获取图像文件的信息
                info = imfinfo(app.tiffpath2);
                % 获取帧数
                numFrames = numel(info);
                if numFrames == 1
                    app.print_console2(sprintf('%s: 帧数为1，不进行配准', app.tiffpath2));
                else
                    
                    % --- MODIFICATION START: Updated registration call ---
                    % The saving of the motion offset CSV is now handled inside the registration function.
                    [~, ~] = registration(app,app.tiffpath2,folderProcessed,true,app.ScanphaseCorrectDropDown_2.Value,app.ScanphaseSpinner_2.Value,app.refFilePathEditField.Value,progressDlg,@app.print_console2);
                    % --- MODIFICATION END ---
                    
                    % 处理完成
                    app.print_console2(sprintf('Processed: %s', app.tiffpath2));
                end
                
            catch ME
                utils.report_error(ME);
                app.print_console2(ME.message);
            end
            
            
            % Close the dialog box
            close(progressDlg)
        end
        
        function [bidphase, offsetLog] = scanphase_correct(app,inputPath,folderProcessed,ScanphaseCorrectDropDownValue,ScanphaseSpinnerValue,progressDlg)
            % This function now returns both the initial bidphase and a detailed offsetLog map.
            offsetLog = containers.Map('KeyType','char','ValueType','any'); % Initialize log
            progressDlg_messages = progressDlg.Message;
            
            if ScanphaseCorrectDropDownValue == "Off"
                bidphase = 0;
                logKey = sprintf('1-%d', length(imfinfo(inputPath)));
                offsetLog(logKey) = 0; % Log that no offset was applied
                return
            end
            
            %% Reading parameters
            nimg_init = app.nimg_initEditField.Value;
            batch_size = app.ScanphaseBatchSpinner_SC.Value;
            
            %% Process
            [~, fname, ~] = fileparts(inputPath);
            tiffInput = Tiff(inputPath, 'r');
            numFrames = length(imfinfo(inputPath));
            if numFrames <= 1
                bidphase = 0;
                tiffInput.close();
                return;
            end
            
            tiffInput.setDirectory(1);
            sampleFrame = tiffInput.read();
            [imgHeight, imgWidth] = size(sampleFrame);
            tags = utils.tiff_read_tag(inputPath);
            if isfield(tags,'ImageDescription'), desc=tags.ImageDescription; else, desc=[]; end
            
            nimg_init= min(nimg_init, numFrames);
            init_frames = zeros(imgHeight, imgWidth, nimg_init, 'like', sampleFrame);
            for i = 1:nimg_init
                tiffInput.setDirectory(i);
                init_frames(:, :, i) = tiffInput.read();
            end
            
            switch ScanphaseCorrectDropDownValue
                case 'Fixed'
                    bidphase = ScanphaseSpinnerValue;
                case 'Auto'
                    progressDlg.Message = sprintf('%s丨Predicting Scanphase',progressDlg_messages);
                    progressDlg.Indeterminate = 'on';
                    bidphase = RIMA.scanphase_predict(init_frames);
                    app.print_console(sprintf("Scanphase predicted: %d", bidphase));
            end
            clear init_frames;
            
            fileInfo = dir(inputPath);
            isBigTiff = fileInfo.bytes > 4e9;
            outputPath  = fullfile(folderProcessed, strcat(fname,'_temp'));
            if isBigTiff
                tiffOutput = Fast_BigTiff_Write(outputPath,tags.XResolution,0,desc);
            else
                tiffOutput = Fast_Tiff_Write(outputPath,tags.XResolution,0,desc);
            end
            
            progressDlg.Indeterminate = 'off';
            try
                for startFrame = 1:batch_size:numFrames
                    if progressDlg.CancelRequested, break; end
                    
                    endFrame = min(startFrame + batch_size - 1, numFrames);
                    numBatchFrames = endFrame - startFrame + 1;
                    
                    framesBatch = zeros(imgHeight, imgWidth, numBatchFrames, 'like', sampleFrame);
                    for i = 1:numBatchFrames
                        tiffInput.setDirectory(startFrame + i - 1);
                        framesBatch(:, :, i) = tiffInput.read();
                    end
                    
                    % Determine current bidphase and log it
                    if app.ScanphaseMethodDropDown_SC.Value == "Batch" && app.ScanphaseCorrectDropDown_SC.Value == "Auto"
                        current_bidphase = RIMA.scanphase_predict(framesBatch);
                        app.print_console(sprintf("Frames %d-%d, Scanphase predicted: %d", startFrame, endFrame, current_bidphase));
                        logKey = sprintf('%d-%d', startFrame, endFrame);
                        offsetLog(logKey) = current_bidphase;
                    else
                        current_bidphase = bidphase;
                    end
                    
                    if current_bidphase ~= 0
                        framesBatch = RIMA.scanphase_correct(framesBatch, current_bidphase);
                    end
                    
                    for i = 1:numBatchFrames
                        tiffOutput.WriteIMG(framesBatch(:, :, i)');
                    end
                    
                    progressDlg.Message = sprintf('%s丨Correcting Scanphase [%d/%d]', progressDlg_messages,endFrame, numFrames);
                    progressDlg.Value = endFrame/numFrames;
                end
                tiffInput.close();
                close(tiffOutput);
                
                % Finalize log if it's empty (e.g., for 'Fixed' or 'Auto' with 'All' method)
                if isempty(keys(offsetLog))
                    logKey = sprintf('1-%d', numFrames);
                    offsetLog(logKey) = bidphase;
                end
                
                % Generate average projection
                progressDlg.Message = sprintf('%s丨Generating Average Projection Image.',progressDlg_messages);
                progressDlg.Indeterminate = 'on';
                % 计算并保存平均投影
                imgStackAvg = utils.avg_big_tiff(outputPath);
                avg_tagstruct = utils.tiff_generate_tagstruct(imgStackAvg, tags);
                avgFilename = sprintf('%s_%d_Frames_AVG.tif', fname, numFrames);
                utils.tiff_save(imgStackAvg, fullfile(folderProcessed, avgFilename), avg_tagstruct);
                % 自动调整对比度并保存
                enhanceFilename = sprintf('%s_%d_Frames_AVG_EnhanceContrast.tif', fname, numFrames);
                utils.tiff_save(imadjust(imgStackAvg), fullfile(folderProcessed, enhanceFilename), avg_tagstruct);
                
                movefile(outputPath, inputPath, 'f');
            catch ME
                utils.report_error(ME);
                errordlg(ME.message, 'Error');
                tiffInput.close();
                if exist('tiffOutput','var'), close(tiffOutput); end
            end
        end
        
        % --- MODIFICATION START: Update function signature and add an input parser ---
        function [motion_offsets, outputPath] = registration(app, inputPath, folderProcessed, needReg, ScanphaseCorrectDropDownValue, ScanphaseSpinnerValue, refimg_filepath, progressDlg, print_console, varargin)
            
            p = inputParser;
            addParameter(p, 'ApplyOffsets', [], @(x) isnumeric(x) && (isempty(x) || ismatrix(x)));
            parse(p, varargin{:});
            offsets_to_apply = p.Results.ApplyOffsets;
            is_apply_only_mode = ~isempty(offsets_to_apply);
            
            motion_offsets = []; % Initialize output variable
            % --- MODIFICATION END ---
            
            if ~needReg && ~is_apply_only_mode
                outputPath = inputPath;
                return
            end
            
            batch_size = app.batch_sizeEditField.Value;
            refImg_save = app.refImgSaveCheckBox.Value;
            nimg_init = app.nimg_initEditField.Value;
            reg_ops.init_frames = app.nimg_initEditField.Value;
            reg_ops.smooth_sigma = app.smooth_sigmaEditField.Value;
            reg_ops.max_shift = app.maxregshiftEditField.Value;
            progressDlg_messages = progressDlg.Message;
            
            %% 读取参数
            [~, fname, fext] = fileparts(inputPath);
            
            % --- MODIFICATION START: Define outputPath earlier ---
            if is_apply_only_mode
                % In apply only mode, the input file may not end with _reg
                % so we add it to avoid overwriting.
                if ~contains(fname, '_reg')
                    outputPath  = fullfile(folderProcessed, strcat(fname,'_reg',fext));
                else
                    outputPath  = fullfile(folderProcessed, strcat(fname,fext));
                end
            else
                outputPath  = fullfile(folderProcessed, strcat(fname,'_reg',fext));
            end
            % --- MODIFICATION END ---
            
            % 读取Tiff
            tiffInput = Tiff(inputPath, 'r');
            numFrames = length(imfinfo(inputPath)); % 获取总帧数
            if numFrames == 1
                return
            end
            % 读取一次以获取数据类型和尺寸
            tiffInput.setDirectory(1);
            sampleFrame = tiffInput.read();
            imgHeight = size(sampleFrame, 1);
            imgWidth = size(sampleFrame, 2);
            % 读取X和Y分辨率
            tags = utils.tiff_read_tag(inputPath);
            tagsSimple= tags;
            % 如果tiffSimple Tag有Software标签，则删除
            if isfield(tagsSimple,'Software')
                tagsSimple = rmfield(tagsSimple,'Software');
            end
            % 如果有Artist标签，则删除
            if isfield(tagsSimple,'Artist')
                tagsSimple = rmfield(tagsSimple,'Artist');
            end
            if isfield(tags,'ImageDescription')
                desc=tags.ImageDescription;
            else
                desc=[];
            end
            
            % --- MODIFICATION START: Conditional Logic for Registration Mode ---
            if ~is_apply_only_mode
                % This is the original "Calculate and Apply" mode
                print_console('Calculating and applying new motion offsets.');
                % 读取前nimg_init帧用于生成参考图像
                nimg_init = min(nimg_init, numFrames);
                init_frames = zeros(imgHeight, imgWidth, nimg_init, 'like', sampleFrame);
                
                for i = 1:nimg_init
                    tiffInput.setDirectory(i);
                    init_frames(:, :, i) = tiffInput.read();
                end
                
                % scanphase predict and correct
                switch ScanphaseCorrectDropDownValue
                    case 'Fixed'
                        do_bidiphase = true;
                        bidphase = ScanphaseSpinnerValue;
                        init_frames = RIMA.scanphase_correct(init_frames, bidphase);
                    case 'Off'
                        do_bidiphase = false;
                        bidphase = 0;
                    case 'Auto'
                        do_bidiphase = true;
                        progressDlg.Message = sprintf('%s丨Registering: Predicting Scanphase',progressDlg_messages);
                        progressDlg.Indeterminate = 'on';
                        bidphase = RIMA.scanphase_predict(init_frames);
                        print_console(sprintf("Scanphase predicted: %d", bidphase));
                        init_frames = RIMA.scanphase_correct(init_frames, bidphase);
                end
                
                % 生成或载入参考图像
                if needReg
                    if strlength(refimg_filepath)
                        refImg = imread(refimg_filepath);
                        progressDlg.Message = sprintf('%s丨Registering: Use Ref Image to Register',progressDlg_messages);
                    else
                        progressDlg.Message = sprintf('%s丨Registering: Generating Ref Image',progressDlg_messages);
                        progressDlg.Indeterminate = 'on';
                        refImg = RIMA.RIMAClass.compute_reference(init_frames, reg_ops);
                        progressDlg.Message = sprintf('%s丨Registering: Ref image Generated',progressDlg_messages);
                        
                        if refImg_save
                            outputRefPath = fullfile(folderProcessed, strcat(fname,'_ref',fext));
                            tiffRef = Tiff(outputRefPath, "w");
                            ref_tags = utils.tiff_generate_tagstruct(refImg,tags);
                            tiffRef.setTag(ref_tags);
                            tiffRef.write(refImg);
                            tiffRef.close();
                        end
                    end
                end
                clear init_frames;
                
            else
                % This is the new "Apply Only" mode
                print_console('Applying pre-calculated motion offsets.');
                progressDlg.Message = sprintf('%s丨Applying Motion Offsets', progressDlg_messages);
                do_bidiphase = false; % Scanphase should be corrected before applying offsets
                needReg = true; % We are applying registration
            end
            % --- MODIFICATION END ---
            
            % 确定是否使用BigTIFF
            fileInfo = dir(inputPath);
            isBigTiff = fileInfo.bytes > 4e9; % 4GB为BigTIFF的阈值
            
            % 初始化输出Tiff对象
            if isBigTiff
                tiffOutput = Fast_BigTiff_Write(outputPath,tags.XResolution,0,desc);
            else
                tiffOutput = Fast_Tiff_Write(outputPath,tags.XResolution,0,desc);
            end
            
            progressDlg.Indeterminate = 'off';
            
            % --- MODIFICATION START: Initialize offset accumulators ---
            all_y_shifts = [];
            all_x_shifts = [];
            all_corr = [];
            % --- MODIFICATION END ---
            
            % 进行配准
            try
                % 分批读取和配准
                for startFrame = 1:batch_size:numFrames
                    if progressDlg.CancelRequested
                        break
                    end
                    
                    endFrame = min(startFrame + batch_size - 1, numFrames);
                    numBatchFrames = endFrame - startFrame + 1;
                    
                    % 读取当前批次的帧
                    framesBatch = zeros(imgHeight, imgWidth, numBatchFrames, 'like', sampleFrame);
                    for i = 1:numBatchFrames
                        tiffInput.setDirectory(startFrame + i - 1);
                        framesBatch(:, :, i) = tiffInput.read();
                    end
                    
                    % 进行scanphase调整 (only in calculate mode)
                    if do_bidiphase
                        if app.ScanphaseMethodDropDown_2.Value == "Batch" && app.ScanphaseCorrectDropDown_2.Value == "Auto"
                            current_bidphase = RIMA.scanphase_predict(framesBatch);
                            print_console(sprintf("Frames %d-%d, Scanphase predicted: %d", startFrame, endFrame, current_bidphase));
                        else
                            current_bidphase = bidphase;
                        end
                        if current_bidphase ~= 0
                            framesBatch = RIMA.scanphase_correct(framesBatch, current_bidphase);
                        end
                    end
                    
                    %  Apply Registration Offsets ---
                    if needReg
                        if ~is_apply_only_mode
                            % Calculate shifts for the current batch
                            [framesBatch, ~, offsets, corr_values] = RIMA.RIMAClass.register(framesBatch, 'refImg',refImg,'max_shift',app.maxregshiftEditField.Value);
                            all_y_shifts = [all_y_shifts; offsets(:,2)];
                            all_x_shifts = [all_x_shifts; offsets(:,1)];
                            all_corr = [all_corr; corr_values];
                        else
                            % Apply pre-calculated shifts for the current batch
                            batch_indices = startFrame:endFrame;
                            y_shifts = offsets_to_apply(batch_indices, 1);
                            x_shifts = offsets_to_apply(batch_indices, 2);
                            for i=1:size(framesBatch,3)
                                framesBatch(:,:,i) = RIMA.RIMAClass.shift_frame(framesBatch(:,:,i), y_shifts(i), x_shifts(i));
                            end
                            
                            % Also save applied offsets for other channels ---
                            all_y_shifts = [all_y_shifts; y_shifts];
                            all_x_shifts = [all_x_shifts; x_shifts];
                        end
                    end
                    
                    % 写入配准后的帧到输出文件
                    for i = 1:numBatchFrames
                        tiffOutput.WriteIMG(framesBatch(:, :, i)');
                    end
                    
                    % 更新进度
                    if do_bidiphase && ~needReg
                        progressDlg.Message = sprintf('%s丨Correcting scanphase [%d/%d]', progressDlg_messages,endFrame, numFrames);
                    elseif needReg
                        progressDlg.Message = sprintf('%s丨Registering [%d/%d]', progressDlg_messages,endFrame, numFrames);
                    end
                    progressDlg.Value = endFrame/numFrames;
                end
                
                % 关闭Tiff对象
                tiffInput.close();
                close(tiffOutput);
                
                % --- MODIFICATION START: Save CSV with frame, xoffset, yoffset only ---
                if needReg && (~isempty(all_y_shifts) || ~isempty(all_x_shifts))
                    % Create frame indices
                    frame_indices = (1:length(all_y_shifts))';
                    
                    % Create simplified offset table with only frame, xoffset, yoffset
                    offset_data = [frame_indices, all_x_shifts, all_y_shifts];
                    offset_table = array2table(offset_data, 'VariableNames', {'Frame', 'XOffset', 'YOffset'});
                    
                    [~, base_fname, ~] = fileparts(outputPath);
                    csv_path = fullfile(folderProcessed, [base_fname '_motion_offset.csv']);
                    writetable(offset_table, csv_path);
                    
                    if is_apply_only_mode
                        print_console(sprintf('Applied motion offsets saved to: %s', csv_path));
                    else
                        print_console(sprintf('Calculated motion offsets saved to: %s', csv_path));
                    end
                    
                    % Return motion_offsets including correlation for compatibility (if calculated)
                    if ~isempty(all_corr)
                        motion_offsets = [all_y_shifts, all_x_shifts, all_corr];
                    else
                        motion_offsets = [all_y_shifts, all_x_shifts];
                    end
                end
                % --- MODIFICATION END ---
                
                if do_bidiphase || needReg
                    % 求平均投影
                    progressDlg.Message = sprintf('%s丨Registering: Generating Avg Image',progressDlg_messages);
                    progressDlg.Indeterminate = 'on';
                    % 计算并保存平均投影
                    imgStackAvg = utils.avg_big_tiff(outputPath);
                    avg_tagstruct = utils.tiff_generate_tagstruct(imgStackAvg, tags);
                    avgFilename = sprintf('%s_%d_Frames_AVG.tif', fname, numFrames);
                    utils.tiff_save(imgStackAvg, fullfile(folderProcessed, avgFilename), avg_tagstruct);
                    % 自动调整对比度并保存
                    enhanceFilename = sprintf('%s_%d_Frames_AVG_EnhanceContrast.tif', fname, numFrames);
                    utils.tiff_save(imadjust(imgStackAvg), fullfile(folderProcessed, enhanceFilename), avg_tagstruct);
                end
            catch ME
                % 捕获并显示错误信息
                errordlg(ME.message, 'Error');
                utils.report_error(ME);
                % 关闭Tiff对象
                tiffInput.close();
                close(tiffOutput);
            end
        end
        
        % --- ROI REBUILD TAB CALLBACKS ---
        
        function FileSelectButton_ROIRebuildPushed(app, event)
            if strlength(app.roiRebuildFolder)
                [filename, selectedDir] = utils.select_file({'*.tif;*.tiff'}, app.folder);
            else
                [filename, selectedDir] = utils.select_file({'*.tif;*.tiff'}, app.roiRebuildFolder);
            end
            
            if filename == 0 % User cancelled
                uialert(app.UIFigure, 'No file selected.', 'Warning', 'Icon', 'warning');
                return;
            end
            app.roiRebuildFolder = selectedDir;
            app.roiRebuildPath = fullfile(selectedDir, filename);
            app.FolderEditField_ROIRebuild.Value = app.roiRebuildPath;
            app.RunButton_ROIRebuild.Enable = 'on';
            app.print_console(sprintf('File selected for rebuild: %s', app.roiRebuildPath));
        end
        
        function RunButton_ROIRebuildPushed(app, event)
            if isempty(app.roiRebuildPath) || ~isfile(app.roiRebuildPath)
                uialert(app.UIFigure, 'Please select a valid TIFF file first.', 'File Not Found', 'Icon', 'error');
                return;
            end
            
            app.fpa_reconstruct(app.roiRebuildPath);
        end
        
        function ClearButton_ROIRebuildPushed(app, event)
            app.ConsoleTextArea_ROIRebuild.Value = '';
            app.cellArrayText_FPAreconstruction = {};
        end
        
        function rebuiltPath = fpa_reconstruct(app,filepath)
            % Create a progress dialog
            progressDlg = uiprogressdlg(app.UIFigure, 'Title', 'ROI Rebuild', ...
                'Cancelable', 'on', 'Interpreter', 'html');
            
            try
                app.print_console('Starting FPA reconstruction process...');
                [folder, fname, fext] = fileparts(filepath);
                
                % --- Step 1: Read TIFF stack ---
                progressDlg.Message = 'Reading source TIFF file...';
                progressDlg.Indeterminate = 'on';
                imgStack = utils.tiff_read(filepath);
                tags = utils.tiff_read_tag(filepath);
                
                % --- Step 2: Rebuild image ---
                progressDlg.Message = 'Reconstructing from subframes...';
                imgStackRebuilt = roiImaging.subframe_rebuild(imgStack);
                app.print_console('Subframe rebuild completed.');
                
                % --- Step 3: Save rebuilt image ---
                progressDlg.Message = 'Saving reconstructed TIFF file...';
                rebuiltFname = strcat(fname, '_reconstructed');
                rebuiltPath = fullfile(folder, [rebuiltFname, fext]);
                
                % Create a valid tag structure for the new image dimensions
                rebuilt_tags = utils.tiff_generate_tagstruct(imgStackRebuilt(:,:,1), tags);
                
                utils.tiff_save(imgStackRebuilt, rebuiltPath, rebuilt_tags);
                app.print_console(sprintf('Reconstructed file saved to: %s', rebuiltPath));
                
                % --- Step 4: Generate average projection ---
                progressDlg.Message = 'Generating average projection...';
                progressDlg.Indeterminate = 'on';
                
                numFrames = size(imgStackRebuilt, 3);
                if numFrames > 1
                    % Calculate average projection
                    originalType = class(imgStackRebuilt);
                    switch originalType
                        case {'uint8', 'uint16'}
                            % Convert to single for calculation, then back to original type
                            imgStackAvg = mean(single(imgStackRebuilt), 3);
                            imgStackAvg = cast(imgStackAvg, originalType);
                        otherwise
                            imgStackAvg = mean(imgStackRebuilt, 3);
                    end
                    
                    % Save average projection
                    avg_tagstruct = utils.tiff_generate_tagstruct(imgStackAvg, tags);
                    avgFilename = sprintf('%s_%d_Frames_AVG%s', rebuiltFname, numFrames, fext);
                    avgPath = fullfile(folder, avgFilename);
                    utils.tiff_save(imgStackAvg, avgPath, avg_tagstruct);
                    app.print_console(sprintf('Average projection saved to: %s', avgPath));
                    
                    % Save contrast-enhanced version
                    enhanceFilename = sprintf('%s_%d_Frames_AVG_EnhanceContrast%s', rebuiltFname, numFrames, fext);
                    enhancePath = fullfile(folder, enhanceFilename);
                    utils.tiff_save(imadjust(imgStackAvg), enhancePath, avg_tagstruct);
                    app.print_console(sprintf('Enhanced average projection saved to: %s', enhancePath));
                end
                
                
                % --- Step 5: Conditional Registration ---
                if progressDlg.CancelRequested, error('Operation cancelled by user.'); end
                
                if app.RegisterAfterRebuildCheckBox_ROIRebuild.Value
                    app.print_console('Starting registration on the rebuilt file...');
                    
                    
                    % Call the existing registration function
                    registration(app, rebuiltPath, folder, true, 'Off', 0, '', progressDlg, @app.print_console);
                    
                    app.print_console('Registration process finished.');
                end
                
                
                if progressDlg.CancelRequested
                    app.print_console('Process cancelled by user.');
                else
                    app.print_console('ROI rebuild process completed successfully.');
                    uialert(app.UIFigure, 'Process completed successfully.', 'Done', 'Icon', 'success');
                end
                
            catch ME
                utils.report_error(ME);
                app.print_console(sprintf('ERROR: %s', ME.message));
                uialert(app.UIFigure, ['An error occurred: ' ME.message], 'Error', 'Icon', 'error');
            end
            
            % Close the dialog box
            if isvalid(progressDlg)
                close(progressDlg);
            end
        end
        
        function output_file = remove_periodic_noise(app, input_file,output_folder)
            arguments
                app
                input_file
                output_folder = ''
            end
            [input_path, input_name, input_ext] = fileparts(input_file);
            output_file = fullfile(input_path, output_folder,[input_name '_deripple' input_ext]);
            
            % Set path to OptiCal periodic denoise model
            model_path_relative = fullfile('..', 'OptiCal_denoising_model', 'periodic_denoising_model', 'train_out', '3PM', 'net_dependent_noise_G20.pth');
            
            model_path = fullfile(app.exePath, model_path_relative);
            
            block_size = int32(128);
            device = 'cuda';
            
            % Add module search path
            script_folder = fullfile(app.exePath, '..', 'OptiCal_denoising_model', 'periodic_denoising_model');
            if count(py.sys.path, script_folder) == 0
                insert(py.sys.path, int32(0), script_folder);
            end
            
            % Run the Python script
            try
                progressDlg = uiprogressdlg(app.UIFigure,'Title','Periodic Denoising','Indeterminate','on','Message','Running OptiCal periodic denoise...');
                pyrunfile(fullfile(script_folder, 'Inference_periodic_denoise.py'),  ...
                    'input', input_file, ...
                    'output', output_file, ...
                    'model', model_path, ...
                    'block_size', block_size, ...
                    'device', device);
                close(progressDlg);
                app.print_console(sprintf('Periodic denoising completed: %s', output_file));
            catch ME
                if exist('progressDlg', 'var') && isvalid(progressDlg), close(progressDlg); end
                app.print_console(sprintf('Error in Periodic Denoising: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function output_file = remove_random_noise(app, input_file,output_folder)
            arguments
                app
                input_file
                output_folder = ''
            end
            [input_path, input_name, input_ext] = fileparts(input_file);
            output_file = fullfile(input_path, output_folder,[input_name '_denoised' input_ext]);
            
            GPU = '0';
            denoise_model = '3PM';
            pth_path = fullfile(app.exePath, '..', 'OptiCal_denoising_model', 'random_denoising_model', 'pth');
            script_folder = fullfile(app.exePath, '..', 'OptiCal_denoising_model', 'random_denoising_model');
            
            if count(py.sys.path, script_folder) == 0
                insert(py.sys.path, int32(0), script_folder);
            end
            
            try
                progressDlg = uiprogressdlg(app.UIFigure,'Title','Random Denoising','Indeterminate','on','Message','Running OptiCal random denoise...');
                pyrunfile(fullfile(script_folder, 'test.py'), ...
                    'GPU', GPU, ...
                    'denoise_model', denoise_model, ...
                    'input', input_file, ...
                    'output', output_file, ...
                    'pth_path', pth_path);
                close(progressDlg);
                app.print_console(sprintf('Random denoising completed: %s', output_file));
            catch ME
                if exist('progressDlg', 'var') && isvalid(progressDlg), close(progressDlg); end
                app.print_console(sprintf('Error in Random Denoising: %s', ME.message));
                rethrow(ME);
            end
        end
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app)
            warning('off','imageio:tiffutils:libtiffWarning') % 抑制fast write导致的warning
            addpath('libs')
            addpath('libs/ReadImageJROI')
            addpath('libs/FastTiffReadWrite')
            % assignin('base', 'app',app)
            app.StartSpinner.Enable = "off";
            app.EndSpinner.Enable = "off";
            app.ProcessButton.Enable = "off";
            app.OpenfolderButton.Enable = "off";
            app.ConsoleTextArea.Value = '';
            
            app.ProcessButton_2.Enable = "off";
            app.OpenFolderButton_2.Enable = "off";
            app.ConsoleTextArea_2.Value = '';
            
            % --- Scanphase Correct Tab Startup ---
            app.ProcessButton_SC.Enable = "off";
            app.SelectROIButton_SC.Enable = "off";
            app.ConsoleTextArea_SC.Value = '';
            % app.ScanphaseBatchSpinner_SC.Visible = 'off';
            % app.Label_SC_BatchSize.Visible = 'off';
            app.ScanphaseSpinner_SC.Visible = 'off';
            app.correctionResults = table(); % Initialize results table
            % --- End Scanphase Correct Tab Startup ---
            
            % --- ROI Rebuild Tab Startup ---
            app.RunButton_ROIRebuild.Enable = 'off';
            app.ConsoleTextArea_ROIRebuild.Value = '';
            app.cellArrayText_FPAreconstruction = {}; % Initialize buffer
            
            % Update Postprocessing dropdown based on initial nChannel value
            app.nChannelSpinnerValueChanged();
            
            % 检测是否存在config_tiff_process.json文件，如果没有，则新建
            app.exePath = utils.GetExecutableFolder();
            
            if isfile(fullfile(app.exePath, 'config/config_tiff_process.json'))
                text = fileread(fullfile(app.exePath, 'config/config_tiff_process.json'));
                config = jsondecode(text);
                
                if isfield(config, 'last_select_path')
                    app.folder = config.last_select_path;
                    app.folder2 = config.last_select_path;
                    app.scanphaseCorrectFolder = config.last_select_path;
                end
                
                if isfield(config, 'nChannel')
                    app.nChannelSpinner.Value = config.nChannel;
                end
                
            else
                % 创建新的config_tiff_process.json文件
                config.last_select_path = '';
                config.nChannel = app.nChannelSpinner.Value;
                json_data = jsonencode(config);
                
                fileID = fopen(fullfile(app.exePath, 'config/config_tiff_process.json'), 'w');
                fprintf(fileID, json_data);
                fclose(fileID);
                
            end
            
        end
        
        % Button pushed function: FileSelectButton
        function FileSelectButtonPushed(app, event)
            switch app.FolderDropDown.Value
                case 'Folder'
                    % 选择文件夹
                    path = utils.select_dir(app.folder);
                    if path == 0
                        uialert(app.UIFigure,'未选择文件夹','Warning','Icon','warning');
                        return;
                    end
                    % 保存文件夹信息到变量
                    app.folder = path;
                    app.FolderEditField.Value = app.folder;
                    
                    % 获取文件index范围
                    app.UpdateButton.Enable ='on';
                    app.update_tiff_index()
                case 'File'
                    [filename,selectedDir] = utils.select_file({'.tif'},app.folder);
                    if filename == 0 % 如果不选择文件返回为0
                        uialert(app.UIFigure,'未选择文件','Warning','Icon','warning');
                        return;
                    end
                    app.folder = selectedDir;
                    app.tiffpath = fullfile(selectedDir,filename);
                    app.FolderEditField.Value = app.tiffpath;
                    app.ProcessButton.Enable = "on";
                    app.OpenfolderButton.Enable = "on";
                    app.index_updated = false;
            end
            
            
        end
        
        % Button pushed function: ProcessButton
        function ProcessButtonPushed(app, event)
            
            switch app.FolderDropDown.Value
                case 'Folder'
                    process_folder(app);
                case 'File'
                    process_file(app);
            end
            
            
        end
        
        % Value changed function: StartSpinner
        function StartSpinnerValueChanged(app, event)
            value = app.StartSpinner.Value;
            if app.onlyOne
                app.StartSpinner.Value =app.fileStartIndex;
                app.EndSpinner.Value = app.fileEndIndex;
            end
            
        end
        
        % Value changed function: EndSpinner
        function EndSpinnerValueChanged(app, event)
            value = app.EndSpinner.Value;
            if app.onlyOne
                app.EndSpinner.Value =app.fileEndIndex;
            end
        end
        
        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            app.update_tiff_index()
        end
        
        % Button pushed function: OpenfolderButton
        function OpenfolderButtonPushed(app, event)
            
            winopen(app.folder);
        end
        
        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % 软件关闭前，保存ripple设置到文件
            config.last_select_path = strrep(app.folder, '\', '\\');
            config.nChannel = app.nChannelSpinner.Value;
            json_data = jsonencode(config);
            
            
            fileID = fopen( fullfile(app.exePath, 'config/config_tiff_process.json'), 'w');
            fprintf(fileID, json_data);
            fclose(fileID);
            
            
            delete(app)
            
        end
        
        % Value changed function: FolderDropDown
        function FolderDropDownValueChanged(app, event)
            app.FolderEditField.Value = '';
            app.StartSpinner.Enable = 'off';
            app.EndSpinner.Enable = 'off';
            app.UpdateButton.Enable = 'off';
            app.ProcessButton.Enable = 'off';
            app.TiffRangeLabel.Text = 'file_0000a ~ file_0000b';
            app.OpenfolderButton.Enable="off";
        end
        
        % Button pushed function: regFileSelectButton
        function regFileSelectButtonPushed(app, event)
            switch app.FolderDropDown_2.Value
                case 'Folder'
                    % 选择文件夹
                    path = utils.select_dir(app.folder2);
                    if path == 0
                        uialert(app.UIFigure,'未选择文件夹','Warning','Icon','warning');
                        return;
                    end
                    % 保存文件夹信息到变量
                    app.folder2 = path;
                    app.FolderEditField_2.Value = app.folder2;
                    filePattern = fullfile(app.folder2, '*.tif');
                    app.reg_tifFiles = dir(filePattern);
                    app.ProcessButton_2.Enable = 'on';
                    app.OpenFolderButton_2.Enable = "on";
                case 'File'
                    [filename,selectedDir] = utils.select_file({'.tif'},app.folder2);
                    if filename == 0 % 如果不选择文件返回为0
                        uialert(app.UIFigure,'未选择文件夹','Warning','Icon','warning');
                        return;
                    end
                    app.folder2 = selectedDir;
                    app.tiffpath2 = fullfile(selectedDir,filename);
                    app.FolderEditField_2.Value = app.tiffpath2;
                    app.ProcessButton_2.Enable = "on";
                    app.OpenFolderButton_2.Enable = "on";
            end
            
        end
        
        % Button pushed function: ProcessButton_2
        function ProcessButton_2Pushed(app, event)
            switch app.FolderDropDown_2.Value
                case 'Folder'
                    reg_folder(app);
                case 'File'
                    reg_file(app);
            end
        end
        
        % Button pushed function: OpenFolderButton_2
        function OpenFolderButton_2Pushed(app, event)
            winopen(app.folder2);
        end
        
        % Value changed function: FolderDropDown_2
        function FolderDropDown_2ValueChanged(app, event)
            app.FolderEditField_2.Value = '';
            app.ProcessButton_2.Enable = 'off';
            app.OpenFolderButton_2.Enable="off";
            switch app.FolderDropDown_2.Value
                case "Folder"
                    app.OutputFolderEditField_2.Value = 'Reg';
                case 'File'
                    app.OutputFolderEditField_2.Value = '';
            end
        end
        
        % Value changed function: ScanphaseCorrectDropDown_2
        function ScanphaseCorrectDropDown_2ValueChanged(app, event)
            value = app.ScanphaseCorrectDropDown_2.Value;
            switch value
                case 'Fixed'
                    app.ScanphaseSpinner_2.Visible = 'on';
                case {'Off','Auto'}
                    app.ScanphaseSpinner_2.Visible = 'off';
            end
        end
        
        % Button pushed function: refImgFileSelectButton
        function refImgFileSelectButtonPushed(app, event)
            [filename,selectedDir] = utils.select_file({'.tif'},app.folder2);
            if filename == 0 % 如果不选择文件返回为0g');
                return;
            end
            app.refFilePathEditField.Value = fullfile(selectedDir,filename);
        end
        
        % Button pushed function: refImgFileDeleteButton
        function refImgFileDeleteButtonPushed(app, event)
            app.refFilePathEditField.Value = '';
        end
        
        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.ConsoleTextArea.Value = '';
            app.cellArrayText = {};
        end
        
        % Button pushed function: ClearButton_2
        function ClearButton_2Pushed(app, event)
            app.ConsoleTextArea_2.Value = '';
            app.cellArrayText2 = {};
        end
        
        % Button pushed function: SelectPathButton_SC
        function SelectPathButton_SCPushed(app, event)
            selectionMode = app.FolderDropDown_SC.Value;
            
            if strcmp(selectionMode, 'Single File')
                [filename, selectedDir] = utils.select_file({'*.tif;*.tiff'}, app.scanphaseCorrectFolder);
                if filename == 0
                    return;
                end
                app.scanphaseCorrectFolder = selectedDir;
                app.scanphaseCorrectPath = fullfile(selectedDir, filename);
                app.FolderEditField_SC.Value = app.scanphaseCorrectPath;
                app.scanphaseCorrectBatchPaths = {}; % Clear batch paths
                app.ProcessButton_SC.Enable = 'on';
                app.SelectROIButton_SC.Enable = 'on';
                app.print_console_sc(sprintf('File selected: %s', app.scanphaseCorrectPath));
            else % Batch Folder
                selectedDir = uigetdir(app.scanphaseCorrectFolder, 'Select Folder for Batch Processing');
                if selectedDir == 0
                    return;
                end
                app.scanphaseCorrectFolder = selectedDir;
                app.FolderEditField_SC.Value = selectedDir;
                
                tiffFiles = [dir(fullfile(selectedDir, '*.tif')); dir(fullfile(selectedDir, '*.tiff'))];
                if isempty(tiffFiles)
                    app.print_console_sc('No TIFF files found in the selected folder.');
                    app.ProcessButton_SC.Enable = 'off';
                    app.SelectROIButton_SC.Enable = 'off';
                    app.scanphaseCorrectBatchPaths = {};
                    return;
                end
                
                app.scanphaseCorrectBatchPaths = fullfile({tiffFiles.folder}, {tiffFiles.name});
                app.scanphaseCorrectPath = ''; % Clear single file path
                app.ProcessButton_SC.Enable = 'on';
                app.SelectROIButton_SC.Enable = 'on';
                app.print_console_sc(sprintf('Batch mode: %d files selected in folder: %s', numel(app.scanphaseCorrectBatchPaths), selectedDir));
            end
            % Reset ROI when a new file/folder is selected
            app.scanphaseROI = [];
            app.ROIInfoEditField_SC.Value = '';
        end
        
        % Button pushed function: SelectROIButton_SC
        function SelectROIButton_SCPushed(app, event)
            % Determine which file to use for ROI selection
            if strcmp(app.FolderDropDown_SC.Value, 'Single File')
                roiFilePath = app.scanphaseCorrectPath;
            elseif ~isempty(app.scanphaseCorrectBatchPaths)
                roiFilePath = app.scanphaseCorrectBatchPaths{1}; % Use first file in batch
                app.print_console_sc(sprintf('Using first file of batch for ROI selection: %s', roiFilePath));
            else
                uialert(app.UIFigure, 'Please select a file or folder first.', 'No File Selected');
                return;
            end
            
            if isempty(roiFilePath) || ~isfile(roiFilePath)
                uialert(app.UIFigure, 'Please select a valid TIFF file first.', 'No File Selected');
                return;
            end
            
            try
                app.print_console_sc('Reading first frame for ROI selection...');
                firstFrame = imread(roiFilePath, 1);
                
                fig = figure('Name', 'Select Region of Interest', 'NumberTitle', 'off', 'ToolBar', 'none', 'MenuBar', 'none');
                imshow(firstFrame, []);
                title('Draw a rectangle. Click it to confirm. Press Esc to cancel.');
                
                hRect = drawrectangle;
                
                % Wait for user to confirm position
                l = addlistener(hRect,'ROIClicked',@(~,evt) onROIClick(evt));
                uiwait(fig); % Wait until figure is closed or ui-resumed
                
                
                
                if isvalid(fig) % If user closed window without double-clicking
                    if isempty(app.scanphaseROI)
                        app.print_console_sc('ROI selection cancelled.');
                    end
                    if isvalid(l)
                        delete(l);
                    end
                    if isvalid(fig)
                        close(fig);
                    end
                end
                
            catch ME
                uialert(app.UIFigure, ['Failed to open image for ROI selection: ' ME.message], 'Error');
                app.print_console_sc(['ERROR: ' ME.message]);
                if isvalid(fig)
                    close(fig);
                end
            end
            
            % --- Start of modification: onROIClick automatically adjusts even rows ---
            function onROIClick(evt)
                pos = hRect.Position;
                
                % VALIDATION: Check if the starting row is odd, if not, adjust it.
                startY = floor(pos(2));
                if mod(startY, 2) == 0 % If the starting row is even...
                    if startY > 1
                        pos(2) = startY - 1; % ...adjust to the previous (odd) row.
                        hRect.Position = pos; % Update the visual rectangle.
                        app.print_console_sc(sprintf('ROI starting row was even (%d), automatically adjusted to odd row %d.', startY, floor(pos(2))));
                    else
                        % This case (row 2) is the only one where we can't just subtract, but it works.
                        pos(2) = 1;
                        hRect.Position = pos;
                        app.print_console_sc(sprintf('ROI starting row was even (%d), automatically adjusted to odd row %d.', startY, floor(pos(2))));
                    end
                end
                
                app.scanphaseROI = pos;
                app.ROIInfoEditField_SC.Value = sprintf('[%.1f, %.1f, %.1f, %.1f]', pos(1), pos(2), pos(3), pos(4));
                app.print_console_sc(sprintf('ROI confirmed: %s', app.ROIInfoEditField_SC.Value));
                
                if isvalid(l)
                    delete(l);
                end
                if isvalid(fig)
                    close(fig);
                end
            end
            % --- End of modification ---
        end
        
        % Button pushed function: ProcessButton_SC
        function ProcessButton_SCPushed(app, event)
            app.correctionResults = table(); % Initialize results table
            
            if strcmp(app.FolderDropDown_SC.Value, 'Single File')
                fileList = {app.scanphaseCorrectPath};
                if isempty(fileList{1}) || ~isfile(fileList{1}), uialert(app.UIFigure, 'Please select a valid file.', 'File Not Found'); return; end
            else
                fileList = app.scanphaseCorrectBatchPaths;
                if isempty(fileList), uialert(app.UIFigure, 'No files found for batch processing.', 'No Files'); return; end
            end
            
            mode = app.ScanphaseCorrectDropDown_SC.Value;
            fixed_offset = app.ScanphaseSpinner_SC.Value;
            method = app.ScanphaseMethodDropDown_SC.Value;
            batch_size = app.ScanphaseBatchSpinner_SC.Value;
            roi = app.scanphaseROI;
            
            progressDlg = uiprogressdlg(app.UIFigure, 'Title', 'Scanphase Correction', 'Cancelable', 'on', 'Interpreter', 'html');
            
            numFiles = numel(fileList);
            for i = 1:numFiles
                if progressDlg.CancelRequested, app.print_console_sc('Batch processing cancelled by user.'); break; end
                
                currentFile = fileList{i};
                progressDlg.Message = sprintf('Processing file %d/%d: %s', i, numFiles, currentFile);
                progressDlg.Value = (i-1)/numFiles;
                
                results = app.core_correct_scanphase(currentFile, mode, fixed_offset, method, batch_size, roi, progressDlg);
                app.correctionResults = [app.correctionResults; struct2table(results, 'AsArray', true)];
                
                % --- MODIFIED: JSON LOGGING with standardized structure ---
                if strcmp(results.Status, 'Success')
                    % Parse the offset log string back into a map for structured JSON
                    offsetLogMap = containers.Map('KeyType','char','ValueType','any');
                    try
                        entries = strsplit(char(results.OffsetLog), ';');
                        for k = 1:numel(entries)
                            if contains(entries{k}, ':')
                                parts = strsplit(strtrim(entries{k}), ':');
                                key = strrep(parts{1}, '-', '_'); % Convert '1-100' to 'x1_100' for valid field name
                                offsetLogMap(['x' key]) = str2double(parts{2});
                            else
                                if ~isempty(strtrim(entries{k}))
                                    offsetLogMap('value') = str2double(entries{k});
                                end
                            end
                        end
                    catch
                        offsetLogMap('raw_log') = results.OffsetLog;
                    end
                    
                    % Prepare parameter struct for JSON
                    params = struct();
                    [~, fname, fext] = fileparts(currentFile);
                    params.sourceFile = currentFile;
                    params.outputFile = fullfile(fileparts(currentFile), [fname, '_scancorrected', fext]);
                    
                    % Create the nested scanphaseCorrect struct
                    sc_params = struct();
                    sc_params.mode = results.CorrectionMode;
                    sc_params.method = method;
                    sc_params.roi = results.ROI;
                    sc_params.offsetLog = offsetLogMap;
                    
                    params.scanphaseCorrect = sc_params; % Nest the parameters
                    
                    % Call the centralized logging function
                    app.saveOrUpdateProcessJSON('ScanphaseCorrect', params);
                end
                % --- END MODIFICATION ---
            end
            
            close(progressDlg);
            uialert(app.UIFigure, 'Processing complete.', 'Done', 'Icon', 'success');
        end
        
        % Button pushed function: ClearButton_SC
        function ClearButton_SCPushed(app, event)
            app.ConsoleTextArea_SC.Value = '';
            app.cellArrayText_SC = {};
        end
        
        % Value changed function: ScanphaseCorrectDropDown_SC
        function ScanphaseCorrectDropDown_SCValueChanged(app, event)
            value = app.ScanphaseCorrectDropDown_SC.Value;
            if strcmp(value, 'Fixed')
                app.ScanphaseSpinner_SC.Visible = 'on';
            else
                app.ScanphaseSpinner_SC.Visible = 'off';
            end
        end
        
        % Value changed function: ScanphaseMethodDropDown_SC
        function ScanphaseMethodDropDown_SCValueChanged(app, event)
            value = app.ScanphaseMethodDropDown_SC.Value;
            if strcmp(value, 'Batch')
                app.ScanphaseBatchSpinner_SC.Visible = 'on';
                app.Label_SC_BatchSize.Visible = 'on';
            else
                app.ScanphaseBatchSpinner_SC.Visible = 'off';
                app.Label_SC_BatchSize.Visible = 'off';
            end
        end
        
        % Value changed function: FolderDropDown_SC
        function FolderDropDown_SCValueChanged(app, event)
            % Reset paths and UI state when changing mode
            app.FolderEditField_SC.Value = '';
            app.ProcessButton_SC.Enable = 'off';
            app.SelectROIButton_SC.Enable = 'off';
            app.scanphaseCorrectPath = '';
            app.scanphaseCorrectBatchPaths = {};
            app.scanphaseROI = [];
            app.ROIInfoEditField_SC.Value = '';
        end
        
        % Button pushed function: ImportCSVRunButton_SC
        function ImportCSVRunButton_SCPushed(app, event)
            % This function imports an offset log from either a .csv or a
            % _processed.json file and applies it to a pre-selected TIFF file.
            
            % 1. Ensure a target TIFF file is already selected in 'Single File' mode.
            if ~strcmp(app.FolderDropDown_SC.Value, 'Single File') || isempty(app.scanphaseCorrectPath) || ~isfile(app.scanphaseCorrectPath)
                uialert(app.UIFigure, 'This function requires a single TIFF file to be selected first.', 'Target File Required', 'Icon', 'warning');
                app.print_console_sc('Import Aborted: Please select a single target file first.');
                return;
            end
            
            % 2. Ask user to select the scanphase offset file (.csv or .json).
            [defaultFolder, ~, ~] = fileparts(app.scanphaseCorrectPath);
            [file, path] = uigetfile({'*.csv;*.json','Offset Files (*.csv, *.json)'; ...
                '*.csv','CSV offset file (*.csv)'; ...
                '*.json','Processed JSON log (*.json)'}, ...
                'Select Scanphase Offset File (.csv or .json)', defaultFolder);
            if file == 0, return; end % User cancelled
            importFilePath = fullfile(path, file);
            app.print_console_sc(['Importing offset file: ' importFilePath]);
            
            offsetMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
            
            % 3. Read the file and create the offset map based on extension.
            [~, ~, fext] = fileparts(importFilePath);
            
            try
                if strcmpi(fext, '.csv')
                    % --- CSV Parsing Logic ---
                    app.print_console_sc('Parsing CSV file...');
                    offsetTable = readtable(importFilePath);
                    requiredCols = ["FrameRange", "Offset"];
                    if ~all(ismember(requiredCols, offsetTable.Properties.VariableNames))
                        uialert(app.UIFigure, 'Imported CSV must contain "FrameRange" and "Offset" columns.', 'Invalid CSV Format');
                        return;
                    end
                    
                    for i = 1:height(offsetTable)
                        rangeStr = offsetTable.FrameRange{i};
                        offsetVal = offsetTable.Offset(i);
                        rangeParts = strsplit(rangeStr, '-');
                        startFrame = str2double(rangeParts{1});
                        if ~isnan(startFrame) && ~isnan(offsetVal)
                            offsetMap(startFrame) = offsetVal;
                        end
                    end
                    
                elseif strcmpi(fext, '.json')
                    % --- JSON Parsing Logic ---
                    app.print_console_sc('Parsing JSON file...');
                    jsonText = fileread(importFilePath);
                    allProcesses = jsondecode(jsonText);
                    if ~iscell(allProcesses), allProcesses = {allProcesses}; end
                    
                    foundLog = false;
                    % Search backwards to find the most recent relevant entry
                    for i = numel(allProcesses):-1:1
                        proc = allProcesses{i};
                        % Simplified check: just look for the scanphaseCorrect field
                        if isfield(proc, 'parameters') && isfield(proc.parameters, 'scanphaseCorrect') && isfield(proc.parameters.scanphaseCorrect, 'offsetLog')
                            
                            offsetLogStruct = proc.parameters.scanphaseCorrect.offsetLog;
                            logFields = fields(offsetLogStruct);
                            
                            for k = 1:numel(logFields)
                                rangeStr = logFields{k};
                                offsetVal = offsetLogStruct.(rangeStr);
                                
                                % Handle keys like 'x1_100' from JSON struct
                                rangeStr = strrep(rangeStr, 'x', '');
                                rangeParts = strsplit(rangeStr, '_');
                                startFrame = str2double(rangeParts{1});
                                
                                if ~isnan(startFrame) && ~isnan(offsetVal)
                                    offsetMap(startFrame) = offsetVal;
                                end
                            end
                            foundLog = true;
                            app.print_console_sc(sprintf('Found and parsed offset log from ''%s'' process.', proc.processName));
                            break; % Stop after finding the first relevant log
                        end
                    end
                    
                    if ~foundLog
                        uialert(app.UIFigure, 'No compatible scanphase offset log found in the selected JSON file.', 'Log Not Found');
                        return;
                    end
                else
                    uialert(app.UIFigure, 'Unsupported file type. Please select a .csv or .json file.', 'Unsupported File');
                    return;
                end
                
                if isempty(offsetMap.keys)
                    uialert(app.UIFigure, 'File was read, but no valid offsets were found or parsed.', 'Empty Offset Map');
                    return;
                end
                
            catch ME
                uialert(app.UIFigure, ['Failed to read or parse the import file: ' ME.message], 'Import Error');
                utils.report_error(ME);
                return;
            end
            
            % 4. Get other parameters from the UI.
            batch_size = app.ScanphaseBatchSpinner_SC.Value;
            method = app.ScanphaseMethodDropDown_SC.Value;
            roi = app.scanphaseROI;
            
            app.print_console_sc(sprintf('Applying %d custom offsets from file to %s.', ...
                length(offsetMap.keys), app.scanphaseCorrectPath));
            
            progressDlg = uiprogressdlg(app.UIFigure, 'Title', 'Applying Custom Offsets', ...
                'Cancelable', 'on', 'Interpreter', 'html');
            
            % 5. Call the core processing function, passing the offsetMap.
            results = app.core_correct_scanphase(app.scanphaseCorrectPath, 'Fixed', 0, ...
                method, batch_size, roi, progressDlg, ...
                'OffsetMap', offsetMap);
            
            close(progressDlg);
            
            % Append results to the main results table
            if ~isempty(results)
                app.correctionResults = [app.correctionResults; struct2table(results, 'AsArray', true)];
            end
            if strcmp(results.Status, 'Success')
                uialert(app.UIFigure, 'Correction using imported offsets completed successfully.', 'Done', 'Icon', 'success');
                app.print_console_sc('Correction from imported file finished.');
                
                % --- MODIFIED: Update the JSON log for the target file with standardized structure ---
                params = struct();
                [~, fname, fext] = fileparts(app.scanphaseCorrectPath);
                params.sourceFile = app.scanphaseCorrectPath;
                params.outputFile = fullfile(fileparts(app.scanphaseCorrectPath), [fname, '_scancorrected', fext]);
                
                % Create the nested scanphaseCorrect struct
                sc_params = struct();
                sc_params.mode = "FromImport";
                sc_params.importedFromFile = importFilePath;
                sc_params.method = method;
                sc_params.roi = results.ROI;
                offsetLogStruct = struct();
                mapKeys = keys(offsetMap);
                for k = 1:length(mapKeys)
                    keyAsDouble = mapKeys{k};
                    keyAsString = sprintf('frame_%d', keyAsDouble); % Prepend 'frame_' to make it a valid field name
                    offsetLogStruct.(keyAsString) = offsetMap(keyAsDouble);
                end
                sc_params.offsetLog = offsetLogStruct; % Save the struct instead of the map
                params.scanphaseCorrect = sc_params; % Nest the parameters
                disp(params);
                app.saveOrUpdateProcessJSON('ScanphaseCorrect', params);
                
            else
                uialert(app.UIFigure, ['Operation failed or was cancelled. Message: ' results.Message], 'Error');
                app.print_console_sc(['ERROR during imported correction: ' results.Message]);
            end
        end
        
        % Button pushed function: ImportOffsetsButton
        function ImportOffsetsButtonPushed(app, event)
            % 1. Check that a single file is selected
            if ~strcmp(app.FolderDropDown_2.Value, 'File') || isempty(app.tiffpath2)
                uialert(app.UIFigure, 'Please select a single TIFF file to apply offsets to.', 'File Not Selected', 'Icon', 'warning');
                return;
            end
            
            % 2. Prompt user to select the motion offset CSV file
            [csvFile, csvPath] = utils.select_file('*.csv', app.folder2 ,'Select Motion Offset CSV File');
            if isequal(csvFile, 0)
                return; % User cancelled
            end
            offsetFilePath = fullfile(csvPath, csvFile);
            
            % 3. Read the offsets from the CSV
            try
                offset_table = readtable(offsetFilePath);
                % Assuming columns are 'XOffset' and 'YOffset'
                if ~all(ismember({'XOffset', 'YOffset'}, offset_table.Properties.VariableNames))
                    error('CSV file must contain "YOffset" and "XOffset" columns.');
                end
                offsets_to_apply = [offset_table.YOffset, offset_table.XOffset];
                app.print_console2(sprintf('Successfully imported %d offsets from %s', height(offsets_to_apply), csvFile));
            catch ME
                uialert(app.UIFigure, ['Failed to read or parse CSV file. Error: ' ME.message], 'CSV Read Error');
                app.print_console2(['ERROR reading offset CSV: ' ME.message]);
                return;
            end
            
            % 4. Call the registration function in "Apply Only" mode
            [directory, ~, ~] = fileparts(app.tiffpath2);
            folderProcessed = fullfile(directory, app.OutputFolderEditField_2.Value);
            if ~exist(folderProcessed, 'dir')
                mkdir(folderProcessed);
            end
            
            progressDlg = uiprogressdlg(app.UIFigure, 'Title', 'Applying Offsets', 'Cancelable', 'on', 'Interpreter', 'html');
            
            try
                registration(app, app.tiffpath2, folderProcessed, true, 'Off', 0, '', progressDlg, @app.print_console2, 'ApplyOffsets', offsets_to_apply);
                app.print_console2(sprintf('Finished applying offsets to: %s', app.tiffpath2));
            catch ME
                utils.report_error(ME);
                app.print_console2(ME.message);
                uialert(app.UIFigure, ['An error occurred during offset application: ' ME.message], 'Error');
            end
            
            close(progressDlg);
        end
        
        % Button pushed function: ManualRegButton
        function ManualRegButtonPushed(app, event)
            ManualImageRegistration;
        end
        
        % Value changed function: nChannelSpinner
        function nChannelSpinnerValueChanged(app, event)
            numChannels = app.nChannelSpinner.Value;
            items = {'All'};
            for i = 1:numChannels
                items{end+1} = sprintf('CH%d', i);
            end
            app.PostprocessingDropDown.Items = items;
            % Default to CH1 if possible, or All
            if ismember('CH1', items)
                app.PostprocessingDropDown.Value = 'CH1';
            else
                app.PostprocessingDropDown.Value = 'All';
            end
        end
        
        % Button pushed function: RandomdenoisingProcessButton
        function RandomdenoisingProcessButtonPushed(app, event)
            inputPath = app.RandomdenoisingFolderEditField.Value;
            if isempty(inputPath), return; end
            output_folder = app.RandomdenoisingOutputFolderEditField.Value;
            
            if isfolder(inputPath)
                files = dir(fullfile(inputPath, '*.tif'));
                for i = 1:length(files)
                    app.remove_random_noise(fullfile(inputPath, files(i).name), output_folder);
                end
            else
                app.remove_random_noise(inputPath, output_folder);
            end
        end
        
        % Button pushed function: PeriodicDenoisinProcessButton
        function PeriodicDenoisinProcessButtonPushed(app, event)
            inputPath = app.PeriodicDenoisinFolderEditField.Value;
            if isempty(inputPath), return; end
            output_folder = app.PeriodicDenoisinOutputFolderEditField.Value;
            
            if isfolder(inputPath)
                files = dir(fullfile(inputPath, '*.tif'));
                for i = 1:length(files)
                    app.remove_periodic_noise(fullfile(inputPath, files(i).name), output_folder);
                end
            else
                app.remove_periodic_noise(inputPath, output_folder);
            end
        end
        
        % Button pushed function: PeriodicDenoisinFileSelectButton
        function PeriodicDenoisinFileSelectButtonPushed(app, event)
            switch app.PeriodicDenoisinFolderDropDown.Value
                case 'Folder'
                    path = utils.select_dir(app.folder);
                    if path == 0, return; end
                    app.folder = path;
                    app.PeriodicDenoisinFolderEditField.Value = path;
                case 'File'
                    [filename, selectedDir] = utils.select_file({'.tif'}, app.folder);
                    if filename == 0, return; end
                    app.folder = selectedDir;
                    app.PeriodicDenoisinFolderEditField.Value = fullfile(selectedDir, filename);
            end
        end
        
        % Button pushed function: PeriodicDenoisinOpenfolderButton
        function PeriodicDenoisinOpenfolderButtonPushed(app, event)
            path = app.PeriodicDenoisinFolderEditField.Value;
            if isempty(path), return; end
            if isfile(path), [path, ~, ~] = fileparts(path); end
            winopen(path);
        end
        
        % Button pushed function: PeriodicDenoisinClearButton
        function PeriodicDenoisinClearButtonPushed(app, event)
            app.PeriodicDenoisingConsoleTextArea.Value = '';
        end
        
        % Button pushed function: RandomdenoisingClearButton
        function RandomdenoisingClearButtonPushed(app, event)
            app.RandomdenoisingConsoleTextArea.Value = '';
        end
        
        % Button pushed function: RandomdenoisingOpenFolderButton
        function RandomdenoisingOpenFolderButtonPushed(app, event)
            path = app.RandomdenoisingFolderEditField.Value;
            if isempty(path), return; end
            if isfile(path), [path, ~, ~] = fileparts(path); end
            winopen(path);
        end
        
        % Button pushed function: RandomdenoisingrFileSelectButton
        function RandomdenoisingrFileSelectButtonPushed(app, event)
            switch app.RandomdenoisingFolderDropDown.Value
                case 'Folder'
                    path = utils.select_dir(app.folder);
                    if path == 0, return; end
                    app.folder = path;
                    app.RandomdenoisingFolderEditField.Value = path;
                case 'File'
                    [filename, selectedDir] = utils.select_file({'.tif'}, app.folder);
                    if filename == 0, return; end
                    app.folder = selectedDir;
                    app.RandomdenoisingFolderEditField.Value = fullfile(selectedDir, filename);
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
            app.UIFigure.Position = [100.333333333333 100.333333333333 651 382];
            app.UIFigure.Name = 'Tiff Process';
            app.UIFigure.Icon = fullfile(pathToMLAPP, '+assets', 'split.png');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            
            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [-1 -9 653 395];
            
            % Create SplitandprocessTab
            app.SplitandprocessTab = uitab(app.TabGroup);
            app.SplitandprocessTab.Tooltip = {'Split Scanimage tiff file into single tiff file'};
            app.SplitandprocessTab.Title = 'Split and process';
            
            % Create ClearButton
            app.ClearButton = uibutton(app.SplitandprocessTab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Tooltip = {'Clear Console'};
            app.ClearButton.Position = [568 300 44 23];
            app.ClearButton.Text = 'Clear';
            
            % Create nChannelSpinner
            app.nChannelSpinner = uispinner(app.SplitandprocessTab);
            app.nChannelSpinner.Limits = [1 Inf];
            app.nChannelSpinner.ValueDisplayFormat = '%.0f';
            app.nChannelSpinner.ValueChangedFcn = createCallbackFcn(app, @nChannelSpinnerValueChanged, true);
            app.nChannelSpinner.Tooltip = {'Set the number of channels'};
            app.nChannelSpinner.Position = [110 267 68 22];
            app.nChannelSpinner.Value = 2;
            
            % Create nChannelSpinnerLabel
            app.nChannelSpinnerLabel = uilabel(app.SplitandprocessTab);
            app.nChannelSpinnerLabel.FontWeight = 'bold';
            app.nChannelSpinnerLabel.Position = [27 267 81 22];
            app.nChannelSpinnerLabel.Text = 'Channel num';
            
            % Create ConsoleTextArea
            app.ConsoleTextArea = uitextarea(app.SplitandprocessTab);
            app.ConsoleTextArea.Position = [343 33 270 264];
            
            % Create ConsoleTextAreaLabel
            app.ConsoleTextAreaLabel = uilabel(app.SplitandprocessTab);
            app.ConsoleTextAreaLabel.FontWeight = 'bold';
            app.ConsoleTextAreaLabel.Position = [343 300 53 22];
            app.ConsoleTextAreaLabel.Text = 'Console';
            
            % Create EndSpinner
            app.EndSpinner = uispinner(app.SplitandprocessTab);
            app.EndSpinner.Limits = [1 Inf];
            app.EndSpinner.ValueDisplayFormat = '%.0f';
            app.EndSpinner.ValueChangedFcn = createCallbackFcn(app, @EndSpinnerValueChanged, true);
            app.EndSpinner.Tooltip = {'Set the ending index for processing'};
            app.EndSpinner.Position = [198 235 62 22];
            app.EndSpinner.Value = 1;
            
            % Create EndSpinnerLabel
            app.EndSpinnerLabel = uilabel(app.SplitandprocessTab);
            app.EndSpinnerLabel.FontWeight = 'bold';
            app.EndSpinnerLabel.Position = [159 236 32 22];
            app.EndSpinnerLabel.Text = 'End:';
            
            % Create StartSpinner
            app.StartSpinner = uispinner(app.SplitandprocessTab);
            app.StartSpinner.Limits = [1 Inf];
            app.StartSpinner.ValueDisplayFormat = '%.0f';
            app.StartSpinner.ValueChangedFcn = createCallbackFcn(app, @StartSpinnerValueChanged, true);
            app.StartSpinner.Tooltip = {'Set the starting index for processing'};
            app.StartSpinner.Position = [69 236 58 22];
            app.StartSpinner.Value = 1;
            
            % Create StartSpinnerLabel
            app.StartSpinnerLabel = uilabel(app.SplitandprocessTab);
            app.StartSpinnerLabel.FontWeight = 'bold';
            app.StartSpinnerLabel.Position = [27 235 71 22];
            app.StartSpinnerLabel.Text = 'Start :';
            
            % Create FolderDropDown
            app.FolderDropDown = uidropdown(app.SplitandprocessTab);
            app.FolderDropDown.Items = {'Folder', 'File'};
            app.FolderDropDown.ValueChangedFcn = createCallbackFcn(app, @FolderDropDownValueChanged, true);
            app.FolderDropDown.Tooltip = {'File mode or folder mode'};
            app.FolderDropDown.Position = [24 338 69 22];
            app.FolderDropDown.Value = 'Folder';
            
            % Create FolderEditField
            app.FolderEditField = uieditfield(app.SplitandprocessTab, 'text');
            app.FolderEditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField.Tooltip = {'Selected Path'};
            app.FolderEditField.Position = [105 338 464 22];
            
            % Create UpdateButton
            app.UpdateButton = uibutton(app.SplitandprocessTab, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Enable = 'off';
            app.UpdateButton.Tooltip = {'Update the TIFF files located in the selected folder.'};
            app.UpdateButton.Position = [240 299 51 23];
            app.UpdateButton.Text = 'Update';
            
            % Create TifffileLabel
            app.TifffileLabel = uilabel(app.SplitandprocessTab);
            app.TifffileLabel.FontWeight = 'bold';
            app.TifffileLabel.Position = [27 299 44 22];
            app.TifffileLabel.Text = 'Tiff file';
            
            % Create TiffRangeLabel
            app.TiffRangeLabel = uilabel(app.SplitandprocessTab);
            app.TiffRangeLabel.Position = [81 299 150 22];
            app.TiffRangeLabel.Text = 'file_0000a ~ file_0000b';
            
            % Create FileSelectButton
            app.FileSelectButton = uibutton(app.SplitandprocessTab, 'push');
            app.FileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @FileSelectButtonPushed, true);
            app.FileSelectButton.Tooltip = {'Choose a file or folder'};
            app.FileSelectButton.Position = [580 338 25 23];
            app.FileSelectButton.Text = '...';
            
            % Create PostprocessingDropDownLabel
            app.PostprocessingDropDownLabel = uilabel(app.SplitandprocessTab);
            app.PostprocessingDropDownLabel.FontWeight = 'bold';
            app.PostprocessingDropDownLabel.Position = [28 205 99 22];
            app.PostprocessingDropDownLabel.Text = 'Post-processing';
            
            % Create PostprocessingDropDown
            app.PostprocessingDropDown = uidropdown(app.SplitandprocessTab);
            app.PostprocessingDropDown.Items = {'All', 'CH1', 'CH2'};
            app.PostprocessingDropDown.Position = [135 205 100 22];
            app.PostprocessingDropDown.Value = 'CH1';
            
            % Create RemoveperiodicnoiseCheckBox
            app.RemoveperiodicnoiseCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RemoveperiodicnoiseCheckBox.Text = 'Remove periodic noise';
            app.RemoveperiodicnoiseCheckBox.Position = [35 179 144 22];
            
            % Create OpenfolderButton
            app.OpenfolderButton = uibutton(app.SplitandprocessTab, 'push');
            app.OpenfolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenfolderButtonPushed, true);
            app.OpenfolderButton.FontWeight = 'bold';
            app.OpenfolderButton.Tooltip = {'Open selected path'};
            app.OpenfolderButton.Position = [166 21 100 23];
            app.OpenfolderButton.Text = 'Open folder';
            
            % Create ProcessButton
            app.ProcessButton = uibutton(app.SplitandprocessTab, 'push');
            app.ProcessButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessButtonPushed, true);
            app.ProcessButton.FontWeight = 'bold';
            app.ProcessButton.Tooltip = {'start splitting Scanimage tiff file into single tiff file'};
            app.ProcessButton.Position = [24 21 100 23];
            app.ProcessButton.Text = 'Process';
            
            % Create FPAimagingreconstructCheckBox
            app.FPAimagingreconstructCheckBox = uicheckbox(app.SplitandprocessTab);
            app.FPAimagingreconstructCheckBox.Text = 'FPA imaging reconstruct';
            app.FPAimagingreconstructCheckBox.Position = [35 153 152 22];
            
            % Create RegistrationCheckBox
            app.RegistrationCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RegistrationCheckBox.Text = 'Registration';
            app.RegistrationCheckBox.Position = [35 102 86 22];
            
            % Create RandomdenosiingCheckBox
            app.RandomdenosiingCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RandomdenosiingCheckBox.Text = 'Random denosiing';
            app.RandomdenosiingCheckBox.Position = [35 77 122 22];
            
            % Create ScanphasecorrectCheckBox
            app.ScanphasecorrectCheckBox = uicheckbox(app.SplitandprocessTab);
            app.ScanphasecorrectCheckBox.Text = 'Scanphase correct';
            app.ScanphasecorrectCheckBox.Position = [35 127 122 22];
            
            % Create RegCopyCH1toothersCheckBox
            app.RegCopyCH1toothersCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RegCopyCH1toothersCheckBox.Tooltip = {'Copy CH1 reg result  to other CH'};
            app.RegCopyCH1toothersCheckBox.Text = 'Copy CH1 to others';
            app.RegCopyCH1toothersCheckBox.Position = [137 102 127 22];
            app.RegCopyCH1toothersCheckBox.Value = true;
            
            % Create OutputFolderEditField
            app.OutputFolderEditField = uieditfield(app.SplitandprocessTab, 'text');
            app.OutputFolderEditField.HorizontalAlignment = 'right';
            app.OutputFolderEditField.Tooltip = {'Set output folder name'};
            app.OutputFolderEditField.Position = [121 49 100 22];
            app.OutputFolderEditField.Value = 'Processed';
            
            % Create OutputFolderEditFieldLabel
            app.OutputFolderEditFieldLabel = uilabel(app.SplitandprocessTab);
            app.OutputFolderEditFieldLabel.FontWeight = 'bold';
            app.OutputFolderEditFieldLabel.Position = [30 49 85 22];
            app.OutputFolderEditFieldLabel.Text = 'Output folder';
            
            % Create ScanphaseCopyCH1toothersCheckBox
            app.ScanphaseCopyCH1toothersCheckBox = uicheckbox(app.SplitandprocessTab);
            app.ScanphaseCopyCH1toothersCheckBox.Tooltip = {'Copy CH1 reg result  to other CH'};
            app.ScanphaseCopyCH1toothersCheckBox.Text = 'Copy CH1 to others';
            app.ScanphaseCopyCH1toothersCheckBox.Position = [161 127 127 22];
            app.ScanphaseCopyCH1toothersCheckBox.Value = true;
            
            % Create PeriodicdenoisingTab
            app.PeriodicdenoisingTab = uitab(app.TabGroup);
            app.PeriodicdenoisingTab.Title = 'Periodic denoising';
            
            % Create PeriodicDenoisinFolderDropDown
            app.PeriodicDenoisinFolderDropDown = uidropdown(app.PeriodicdenoisingTab);
            app.PeriodicDenoisinFolderDropDown.Items = {'Folder', 'File'};
            app.PeriodicDenoisinFolderDropDown.Tooltip = {'File mode or folder mode'};
            app.PeriodicDenoisinFolderDropDown.Position = [14 339 69 22];
            app.PeriodicDenoisinFolderDropDown.Value = 'Folder';
            
            % Create PeriodicDenoisinFolderEditField
            app.PeriodicDenoisinFolderEditField = uieditfield(app.PeriodicdenoisingTab, 'text');
            app.PeriodicDenoisinFolderEditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.PeriodicDenoisinFolderEditField.Tooltip = {'Selected Path'};
            app.PeriodicDenoisinFolderEditField.Position = [95 339 464 22];
            
            % Create PeriodicDenoisinFileSelectButton
            app.PeriodicDenoisinFileSelectButton = uibutton(app.PeriodicdenoisingTab, 'push');
            app.PeriodicDenoisinFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @PeriodicDenoisinFileSelectButtonPushed, true);
            app.PeriodicDenoisinFileSelectButton.Tooltip = {'Choose a file or folder'};
            app.PeriodicDenoisinFileSelectButton.Position = [570 339 25 23];
            app.PeriodicDenoisinFileSelectButton.Text = '...';
            
            % Create PeriodicDenoisinProcessButton
            app.PeriodicDenoisinProcessButton = uibutton(app.PeriodicdenoisingTab, 'push');
            app.PeriodicDenoisinProcessButton.ButtonPushedFcn = createCallbackFcn(app, @PeriodicDenoisinProcessButtonPushed, true);
            app.PeriodicDenoisinProcessButton.FontWeight = 'bold';
            app.PeriodicDenoisinProcessButton.Tooltip = {'Start image registration'};
            app.PeriodicDenoisinProcessButton.Position = [11 253 100 23];
            app.PeriodicDenoisinProcessButton.Text = 'Process';
            
            % Create PeriodicDenoisinOutputFolderEditField
            app.PeriodicDenoisinOutputFolderEditField = uieditfield(app.PeriodicdenoisingTab, 'text');
            app.PeriodicDenoisinOutputFolderEditField.HorizontalAlignment = 'right';
            app.PeriodicDenoisinOutputFolderEditField.Tooltip = {'Set output folder name'};
            app.PeriodicDenoisinOutputFolderEditField.Position = [148 293 100 22];
            
            % Create PeriodicDenoisinOutputFolderLabel
            app.PeriodicDenoisinOutputFolderLabel = uilabel(app.PeriodicdenoisingTab);
            app.PeriodicDenoisinOutputFolderLabel.FontWeight = 'bold';
            app.PeriodicDenoisinOutputFolderLabel.Position = [17 293 85 22];
            app.PeriodicDenoisinOutputFolderLabel.Text = 'Output folder';
            
            % Create PeriodicDenoisinOpenfolderButton
            app.PeriodicDenoisinOpenfolderButton = uibutton(app.PeriodicdenoisingTab, 'push');
            app.PeriodicDenoisinOpenfolderButton.ButtonPushedFcn = createCallbackFcn(app, @PeriodicDenoisinOpenfolderButtonPushed, true);
            app.PeriodicDenoisinOpenfolderButton.FontWeight = 'bold';
            app.PeriodicDenoisinOpenfolderButton.Tooltip = {'Open selected path'};
            app.PeriodicDenoisinOpenfolderButton.Position = [132 254 100 23];
            app.PeriodicDenoisinOpenfolderButton.Text = 'Open folder';
            
            % Create PeriodicDenoisinClearButton
            app.PeriodicDenoisinClearButton = uibutton(app.PeriodicdenoisingTab, 'push');
            app.PeriodicDenoisinClearButton.ButtonPushedFcn = createCallbackFcn(app, @PeriodicDenoisinClearButtonPushed, true);
            app.PeriodicDenoisinClearButton.Tooltip = {'Clear Console'};
            app.PeriodicDenoisinClearButton.Position = [568 300 44 23];
            app.PeriodicDenoisinClearButton.Text = 'Clear';
            
            % Create PeriodicDenoisinConsoleTextAreaLabel
            app.PeriodicDenoisinConsoleTextAreaLabel = uilabel(app.PeriodicdenoisingTab);
            app.PeriodicDenoisinConsoleTextAreaLabel.FontWeight = 'bold';
            app.PeriodicDenoisinConsoleTextAreaLabel.Position = [343 300 53 22];
            app.PeriodicDenoisinConsoleTextAreaLabel.Text = 'Console';
            
            % Create PeriodicDenoisingConsoleTextArea
            app.PeriodicDenoisingConsoleTextArea = uitextarea(app.PeriodicdenoisingTab);
            app.PeriodicDenoisingConsoleTextArea.Position = [343 33 270 264];
            
            % Create FPAreconstructionTab
            app.FPAreconstructionTab = uitab(app.TabGroup);
            app.FPAreconstructionTab.Title = 'FPA  reconstruction';
            
            % Create ClearButton_ROIRebuild
            app.ClearButton_ROIRebuild = uibutton(app.FPAreconstructionTab, 'push');
            app.ClearButton_ROIRebuild.ButtonPushedFcn = createCallbackFcn(app, @ClearButton_ROIRebuildPushed, true);
            app.ClearButton_ROIRebuild.Tooltip = {'Clear Console'};
            app.ClearButton_ROIRebuild.Position = [568 300 44 23];
            app.ClearButton_ROIRebuild.Text = 'Clear';
            
            % Create ConsoleTextAreaLabel_ROIRebuild
            app.ConsoleTextAreaLabel_ROIRebuild = uilabel(app.FPAreconstructionTab);
            app.ConsoleTextAreaLabel_ROIRebuild.FontWeight = 'bold';
            app.ConsoleTextAreaLabel_ROIRebuild.Position = [343 300 53 22];
            app.ConsoleTextAreaLabel_ROIRebuild.Text = 'Console';
            
            % Create ConsoleTextArea_ROIRebuild
            app.ConsoleTextArea_ROIRebuild = uitextarea(app.FPAreconstructionTab);
            app.ConsoleTextArea_ROIRebuild.Position = [343 33 270 264];
            
            % Create RunButton_ROIRebuild
            app.RunButton_ROIRebuild = uibutton(app.FPAreconstructionTab, 'push');
            app.RunButton_ROIRebuild.ButtonPushedFcn = createCallbackFcn(app, @RunButton_ROIRebuildPushed, true);
            app.RunButton_ROIRebuild.FontWeight = 'bold';
            app.RunButton_ROIRebuild.Position = [23 240 103 23];
            app.RunButton_ROIRebuild.Text = 'Reconstruction';
            
            % Create RegisterAfterRebuildCheckBox_ROIRebuild
            app.RegisterAfterRebuildCheckBox_ROIRebuild = uicheckbox(app.FPAreconstructionTab);
            app.RegisterAfterRebuildCheckBox_ROIRebuild.Text = 'Register after reconstruct';
            app.RegisterAfterRebuildCheckBox_ROIRebuild.Position = [24 290 157 22];
            app.RegisterAfterRebuildCheckBox_ROIRebuild.Value = true;
            
            % Create FolderEditField_ROIRebuild
            app.FolderEditField_ROIRebuild = uieditfield(app.FPAreconstructionTab, 'text');
            app.FolderEditField_ROIRebuild.Editable = 'off';
            app.FolderEditField_ROIRebuild.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_ROIRebuild.Tooltip = {'Selected Path'};
            app.FolderEditField_ROIRebuild.Position = [24 339 545 22];
            
            % Create FileSelectButton_ROIRebuild
            app.FileSelectButton_ROIRebuild = uibutton(app.FPAreconstructionTab, 'push');
            app.FileSelectButton_ROIRebuild.ButtonPushedFcn = createCallbackFcn(app, @FileSelectButton_ROIRebuildPushed, true);
            app.FileSelectButton_ROIRebuild.Tooltip = {'Choose a file'};
            app.FileSelectButton_ROIRebuild.Position = [580 338 25 23];
            app.FileSelectButton_ROIRebuild.Text = '...';
            
            % Create RegTab
            app.RegTab = uitab(app.TabGroup);
            app.RegTab.Tooltip = {'Perform Image Registration'};
            app.RegTab.Title = 'Reg';
            
            % Create ImportOffsetsButton
            app.ImportOffsetsButton = uibutton(app.RegTab, 'push');
            app.ImportOffsetsButton.ButtonPushedFcn = createCallbackFcn(app, @ImportOffsetsButtonPushed, true);
            app.ImportOffsetsButton.Position = [134 45 140 23];
            app.ImportOffsetsButton.Text = 'Import Offsets & Run';
            
            % Create ScanphaseMethodDropDown_2
            app.ScanphaseMethodDropDown_2 = uidropdown(app.RegTab);
            app.ScanphaseMethodDropDown_2.Items = {'All', 'Batch'};
            app.ScanphaseMethodDropDown_2.Position = [151 109 100 22];
            app.ScanphaseMethodDropDown_2.Value = 'All';
            
            % Create ScanphaseMethodDropDownLabel
            app.ScanphaseMethodDropDownLabel = uilabel(app.RegTab);
            app.ScanphaseMethodDropDownLabel.FontWeight = 'bold';
            app.ScanphaseMethodDropDownLabel.Position = [20 109 115 22];
            app.ScanphaseMethodDropDownLabel.Text = 'Scanphase method';
            
            % Create ManualRegButton
            app.ManualRegButton = uibutton(app.RegTab, 'push');
            app.ManualRegButton.ButtonPushedFcn = createCallbackFcn(app, @ManualRegButtonPushed, true);
            app.ManualRegButton.Position = [134 17 100 23];
            app.ManualRegButton.Text = 'Manual Reg';
            
            % Create ClearButton_2
            app.ClearButton_2 = uibutton(app.RegTab, 'push');
            app.ClearButton_2.ButtonPushedFcn = createCallbackFcn(app, @ClearButton_2Pushed, true);
            app.ClearButton_2.Tooltip = {'Clear Console'};
            app.ClearButton_2.Position = [568 293 44 23];
            app.ClearButton_2.Text = 'Clear';
            
            % Create refImgFileDeleteButton
            app.refImgFileDeleteButton = uibutton(app.RegTab, 'push');
            app.refImgFileDeleteButton.ButtonPushedFcn = createCallbackFcn(app, @refImgFileDeleteButtonPushed, true);
            app.refImgFileDeleteButton.Icon = fullfile(pathToMLAPP, '+assets', 'clear.svg');
            app.refImgFileDeleteButton.Tooltip = {'Clear Selected Ref Image'};
            app.refImgFileDeleteButton.Position = [287 293 20 23];
            app.refImgFileDeleteButton.Text = '';
            
            % Create refImgSaveCheckBox
            app.refImgSaveCheckBox = uicheckbox(app.RegTab);
            app.refImgSaveCheckBox.Tooltip = {'Whether to save ref image after egistration'};
            app.refImgSaveCheckBox.Text = '';
            app.refImgSaveCheckBox.Position = [152 172 26 22];
            
            % Create OutputFolderEditFieldLabel_3
            app.OutputFolderEditFieldLabel_3 = uilabel(app.RegTab);
            app.OutputFolderEditFieldLabel_3.FontWeight = 'bold';
            app.OutputFolderEditFieldLabel_3.Position = [20 170 85 22];
            app.OutputFolderEditFieldLabel_3.Text = 'Save ref img';
            
            % Create RefimgLabel
            app.RefimgLabel = uilabel(app.RegTab);
            app.RefimgLabel.FontWeight = 'bold';
            app.RefimgLabel.Position = [20 293 49 22];
            app.RefimgLabel.Text = 'Ref img';
            
            % Create refImgFileSelectButton
            app.refImgFileSelectButton = uibutton(app.RegTab, 'push');
            app.refImgFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @refImgFileSelectButtonPushed, true);
            app.refImgFileSelectButton.Tooltip = {'Select ref image'};
            app.refImgFileSelectButton.Position = [261 293 25 23];
            app.refImgFileSelectButton.Text = '...';
            
            % Create refFilePathEditField
            app.refFilePathEditField = uieditfield(app.RegTab, 'text');
            app.refFilePathEditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.refFilePathEditField.Tooltip = {'Selected path of ref image'};
            app.refFilePathEditField.Position = [151 293 96 22];
            
            % Create batch_sizeEditField
            app.batch_sizeEditField = uieditfield(app.RegTab, 'numeric');
            app.batch_sizeEditField.Limits = [0 Inf];
            app.batch_sizeEditField.Tooltip = {'Number of frames per batch (reduce the value for big tiff file)'};
            app.batch_sizeEditField.Position = [151 244 100 22];
            app.batch_sizeEditField.Value = 200;
            
            % Create batch_sizeEditFieldLabel
            app.batch_sizeEditFieldLabel = uilabel(app.RegTab);
            app.batch_sizeEditFieldLabel.FontWeight = 'bold';
            app.batch_sizeEditFieldLabel.Position = [20 244 66 22];
            app.batch_sizeEditFieldLabel.Text = 'batch_size';
            
            % Create nimg_initEditField
            app.nimg_initEditField = uieditfield(app.RegTab, 'numeric');
            app.nimg_initEditField.Limits = [0 Inf];
            app.nimg_initEditField.Tooltip = {'Subsampled frames for finding reference image'};
            app.nimg_initEditField.Position = [151 268 100 22];
            app.nimg_initEditField.Value = 300;
            
            % Create nimg_initEditFieldLabel
            app.nimg_initEditFieldLabel = uilabel(app.RegTab);
            app.nimg_initEditFieldLabel.FontWeight = 'bold';
            app.nimg_initEditFieldLabel.Position = [20 268 58 22];
            app.nimg_initEditFieldLabel.Text = 'nimg_init';
            
            % Create ConsoleTextArea_2
            app.ConsoleTextArea_2 = uitextarea(app.RegTab);
            app.ConsoleTextArea_2.Position = [336 17 270 273];
            
            % Create ConsoleTextArea_2Label
            app.ConsoleTextArea_2Label = uilabel(app.RegTab);
            app.ConsoleTextArea_2Label.FontWeight = 'bold';
            app.ConsoleTextArea_2Label.Position = [336 293 53 22];
            app.ConsoleTextArea_2Label.Text = 'Console';
            
            % Create maxregshiftEditField
            app.maxregshiftEditField = uieditfield(app.RegTab, 'numeric');
            app.maxregshiftEditField.Limits = [0 1];
            app.maxregshiftEditField.Tooltip = {'Max allowed registration shift, as a fraction of frame max(width and height)'};
            app.maxregshiftEditField.Position = [149 194 100 22];
            app.maxregshiftEditField.Value = 0.1;
            
            % Create maxregshiftEditFieldLabel
            app.maxregshiftEditFieldLabel = uilabel(app.RegTab);
            app.maxregshiftEditFieldLabel.FontWeight = 'bold';
            app.maxregshiftEditFieldLabel.Position = [20 194 73 22];
            app.maxregshiftEditFieldLabel.Text = 'maxregshift';
            
            % Create smooth_sigmaEditField
            app.smooth_sigmaEditField = uieditfield(app.RegTab, 'numeric');
            app.smooth_sigmaEditField.Limits = [0 Inf];
            app.smooth_sigmaEditField.Tooltip = {'Gaussian smoothing in time'};
            app.smooth_sigmaEditField.Position = [151 220 100 22];
            app.smooth_sigmaEditField.Value = 1.125;
            
            % Create smooth_sigmaEditFieldLabel
            app.smooth_sigmaEditFieldLabel = uilabel(app.RegTab);
            app.smooth_sigmaEditFieldLabel.FontWeight = 'bold';
            app.smooth_sigmaEditFieldLabel.Position = [20 220 90 22];
            app.smooth_sigmaEditFieldLabel.Text = 'smooth_sigma';
            
            % Create ScanphaseCorrectDropDown_2
            app.ScanphaseCorrectDropDown_2 = uidropdown(app.RegTab);
            app.ScanphaseCorrectDropDown_2.Items = {'Off', 'Auto', 'Fixed'};
            app.ScanphaseCorrectDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ScanphaseCorrectDropDown_2ValueChanged, true);
            app.ScanphaseCorrectDropDown_2.Tooltip = {'Whether to do bidirectional correction'};
            app.ScanphaseCorrectDropDown_2.Position = [151 138 100 22];
            app.ScanphaseCorrectDropDown_2.Value = 'Off';
            
            % Create scanphasecorrectLabel
            app.scanphasecorrectLabel = uilabel(app.RegTab);
            app.scanphasecorrectLabel.FontWeight = 'bold';
            app.scanphasecorrectLabel.Position = [20 140 112 22];
            app.scanphasecorrectLabel.Text = 'Scanphase correct';
            
            % Create OutputFolderEditField_2
            app.OutputFolderEditField_2 = uieditfield(app.RegTab, 'text');
            app.OutputFolderEditField_2.HorizontalAlignment = 'right';
            app.OutputFolderEditField_2.Tooltip = {'Set output folder name'};
            app.OutputFolderEditField_2.Position = [151 77 100 22];
            
            % Create OutputFolderEditField_2Label
            app.OutputFolderEditField_2Label = uilabel(app.RegTab);
            app.OutputFolderEditField_2Label.FontWeight = 'bold';
            app.OutputFolderEditField_2Label.Position = [20 77 85 22];
            app.OutputFolderEditField_2Label.Text = 'Output Folder';
            
            % Create FolderDropDown_2
            app.FolderDropDown_2 = uidropdown(app.RegTab);
            app.FolderDropDown_2.Items = {'Folder', 'File'};
            app.FolderDropDown_2.ValueChangedFcn = createCallbackFcn(app, @FolderDropDown_2ValueChanged, true);
            app.FolderDropDown_2.Tooltip = {'File mode or folder mode'};
            app.FolderDropDown_2.Position = [14 339 69 22];
            app.FolderDropDown_2.Value = 'Folder';
            
            % Create ScanphaseSpinner_2
            app.ScanphaseSpinner_2 = uispinner(app.RegTab);
            app.ScanphaseSpinner_2.Visible = 'off';
            app.ScanphaseSpinner_2.Tooltip = {'Bidirectional Phase offset from line scanning (set by user)'};
            app.ScanphaseSpinner_2.Position = [259 137 49 22];
            
            % Create FolderEditField_2
            app.FolderEditField_2 = uieditfield(app.RegTab, 'text');
            app.FolderEditField_2.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_2.Tooltip = {'Selected Path'};
            app.FolderEditField_2.Position = [95 339 464 22];
            
            % Create OpenFolderButton_2
            app.OpenFolderButton_2 = uibutton(app.RegTab, 'push');
            app.OpenFolderButton_2.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButton_2Pushed, true);
            app.OpenFolderButton_2.FontWeight = 'bold';
            app.OpenFolderButton_2.Tooltip = {'Open selected path'};
            app.OpenFolderButton_2.Position = [23 17 100 23];
            app.OpenFolderButton_2.Text = 'Open Folder';
            
            % Create ProcessButton_2
            app.ProcessButton_2 = uibutton(app.RegTab, 'push');
            app.ProcessButton_2.ButtonPushedFcn = createCallbackFcn(app, @ProcessButton_2Pushed, true);
            app.ProcessButton_2.FontWeight = 'bold';
            app.ProcessButton_2.Tooltip = {'Start image registration'};
            app.ProcessButton_2.Position = [23 45 100 23];
            app.ProcessButton_2.Text = 'Process';
            
            % Create regFileSelectButton
            app.regFileSelectButton = uibutton(app.RegTab, 'push');
            app.regFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @regFileSelectButtonPushed, true);
            app.regFileSelectButton.Tooltip = {'Choose a file or folder'};
            app.regFileSelectButton.Position = [570 339 25 23];
            app.regFileSelectButton.Text = '...';
            
            % Create RandomdenoisingTab
            app.RandomdenoisingTab = uitab(app.TabGroup);
            app.RandomdenoisingTab.Title = 'Random denoising';
            
            % Create RandomdenoisingFolderDropDown
            app.RandomdenoisingFolderDropDown = uidropdown(app.RandomdenoisingTab);
            app.RandomdenoisingFolderDropDown.Items = {'Folder', 'File'};
            app.RandomdenoisingFolderDropDown.Tooltip = {'File mode or folder mode'};
            app.RandomdenoisingFolderDropDown.Position = [14 339 69 22];
            app.RandomdenoisingFolderDropDown.Value = 'Folder';
            
            % Create RandomdenoisingFolderEditField
            app.RandomdenoisingFolderEditField = uieditfield(app.RandomdenoisingTab, 'text');
            app.RandomdenoisingFolderEditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.RandomdenoisingFolderEditField.Tooltip = {'Selected Path'};
            app.RandomdenoisingFolderEditField.Position = [95 339 464 22];
            
            % Create RandomdenoisingrFileSelectButton
            app.RandomdenoisingrFileSelectButton = uibutton(app.RandomdenoisingTab, 'push');
            app.RandomdenoisingrFileSelectButton.ButtonPushedFcn = createCallbackFcn(app, @RandomdenoisingrFileSelectButtonPushed, true);
            app.RandomdenoisingrFileSelectButton.Tooltip = {'Choose a file or folder'};
            app.RandomdenoisingrFileSelectButton.Position = [570 339 25 23];
            app.RandomdenoisingrFileSelectButton.Text = '...';
            
            % Create RandomdenoisingProcessButton
            app.RandomdenoisingProcessButton = uibutton(app.RandomdenoisingTab, 'push');
            app.RandomdenoisingProcessButton.ButtonPushedFcn = createCallbackFcn(app, @RandomdenoisingProcessButtonPushed, true);
            app.RandomdenoisingProcessButton.FontWeight = 'bold';
            app.RandomdenoisingProcessButton.Tooltip = {'Start image registration'};
            app.RandomdenoisingProcessButton.Position = [11 253 100 23];
            app.RandomdenoisingProcessButton.Text = 'Process';
            
            % Create RandomdenoisingOutputFolderEditField
            app.RandomdenoisingOutputFolderEditField = uieditfield(app.RandomdenoisingTab, 'text');
            app.RandomdenoisingOutputFolderEditField.HorizontalAlignment = 'right';
            app.RandomdenoisingOutputFolderEditField.Tooltip = {'Set output folder name'};
            app.RandomdenoisingOutputFolderEditField.Position = [148 293 100 22];
            
            % Create RandomdenoisingOutputFolderLabel
            app.RandomdenoisingOutputFolderLabel = uilabel(app.RandomdenoisingTab);
            app.RandomdenoisingOutputFolderLabel.FontWeight = 'bold';
            app.RandomdenoisingOutputFolderLabel.Position = [17 293 85 22];
            app.RandomdenoisingOutputFolderLabel.Text = 'Output Folder';
            
            % Create RandomdenoisingOpenFolderButton
            app.RandomdenoisingOpenFolderButton = uibutton(app.RandomdenoisingTab, 'push');
            app.RandomdenoisingOpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @RandomdenoisingOpenFolderButtonPushed, true);
            app.RandomdenoisingOpenFolderButton.FontWeight = 'bold';
            app.RandomdenoisingOpenFolderButton.Tooltip = {'Open selected path'};
            app.RandomdenoisingOpenFolderButton.Position = [132 254 100 23];
            app.RandomdenoisingOpenFolderButton.Text = 'Open Folder';
            
            % Create RandomdenoisingClearButton
            app.RandomdenoisingClearButton = uibutton(app.RandomdenoisingTab, 'push');
            app.RandomdenoisingClearButton.ButtonPushedFcn = createCallbackFcn(app, @RandomdenoisingClearButtonPushed, true);
            app.RandomdenoisingClearButton.Tooltip = {'Clear Console'};
            app.RandomdenoisingClearButton.Position = [568 300 44 23];
            app.RandomdenoisingClearButton.Text = 'Clear';
            
            % Create RandomdenoisingConsoleTextAreaLabel
            app.RandomdenoisingConsoleTextAreaLabel = uilabel(app.RandomdenoisingTab);
            app.RandomdenoisingConsoleTextAreaLabel.FontWeight = 'bold';
            app.RandomdenoisingConsoleTextAreaLabel.Position = [343 300 53 22];
            app.RandomdenoisingConsoleTextAreaLabel.Text = 'Console';
            
            % Create RandomdenoisingConsoleTextArea
            app.RandomdenoisingConsoleTextArea = uitextarea(app.RandomdenoisingTab);
            app.RandomdenoisingConsoleTextArea.Position = [343 33 270 264];
            
            % Create ScanphasecorrectTab
            app.ScanphasecorrectTab = uitab(app.TabGroup);
            app.ScanphasecorrectTab.Title = 'Scanphase correct';
            
            % Create ImportCSVRunButton_SC
            app.ImportCSVRunButton_SC = uibutton(app.ScanphasecorrectTab, 'push');
            app.ImportCSVRunButton_SC.ButtonPushedFcn = createCallbackFcn(app, @ImportCSVRunButton_SCPushed, true);
            app.ImportCSVRunButton_SC.Position = [18 34 127 23];
            app.ImportCSVRunButton_SC.Text = 'Import Offsets & Run';
            
            % Create ExportCSVCheckBox_SC
            app.ExportCSVCheckBox_SC = uicheckbox(app.ScanphasecorrectTab);
            app.ExportCSVCheckBox_SC.Text = 'Export results to CSV';
            app.ExportCSVCheckBox_SC.Position = [21 108 150 22];
            app.ExportCSVCheckBox_SC.Value = true;
            
            % Create ClearButton_SC
            app.ClearButton_SC = uibutton(app.ScanphasecorrectTab, 'push');
            app.ClearButton_SC.ButtonPushedFcn = createCallbackFcn(app, @ClearButton_SCPushed, true);
            app.ClearButton_SC.Position = [562 293 44 23];
            app.ClearButton_SC.Text = 'Clear';
            
            % Create ConsoleTextArea_SC
            app.ConsoleTextArea_SC = uitextarea(app.ScanphasecorrectTab);
            app.ConsoleTextArea_SC.Position = [336 17 270 273];
            
            % Create Label_SC_Console
            app.Label_SC_Console = uilabel(app.ScanphasecorrectTab);
            app.Label_SC_Console.FontWeight = 'bold';
            app.Label_SC_Console.Position = [336 293 53 22];
            app.Label_SC_Console.Text = 'Console';
            
            % Create ProcessButton_SC
            app.ProcessButton_SC = uibutton(app.ScanphasecorrectTab, 'push');
            app.ProcessButton_SC.ButtonPushedFcn = createCallbackFcn(app, @ProcessButton_SCPushed, true);
            app.ProcessButton_SC.FontWeight = 'bold';
            app.ProcessButton_SC.Position = [21 68 100 23];
            app.ProcessButton_SC.Text = 'Process';
            
            % Create ScanphaseBatchSpinner_SC
            app.ScanphaseBatchSpinner_SC = uispinner(app.ScanphasecorrectTab);
            app.ScanphaseBatchSpinner_SC.Limits = [1 Inf];
            app.ScanphaseBatchSpinner_SC.Position = [140 174 100 22];
            app.ScanphaseBatchSpinner_SC.Value = 100;
            
            % Create Label_SC_BatchSize
            app.Label_SC_BatchSize = uilabel(app.ScanphasecorrectTab);
            app.Label_SC_BatchSize.Position = [21 174 60 22];
            app.Label_SC_BatchSize.Text = 'Batch Size';
            
            % Create ScanphaseMethodDropDown_SC
            app.ScanphaseMethodDropDown_SC = uidropdown(app.ScanphasecorrectTab);
            app.ScanphaseMethodDropDown_SC.Items = {'All', 'Batch'};
            app.ScanphaseMethodDropDown_SC.ValueChangedFcn = createCallbackFcn(app, @ScanphaseMethodDropDown_SCValueChanged, true);
            app.ScanphaseMethodDropDown_SC.Position = [140 214 100 22];
            app.ScanphaseMethodDropDown_SC.Value = 'All';
            
            % Create Label_SC_Method
            app.Label_SC_Method = uilabel(app.ScanphasecorrectTab);
            app.Label_SC_Method.Position = [21 214 114 22];
            app.Label_SC_Method.Text = 'Correction Method';
            
            % Create ROIInfoEditField_SC
            app.ROIInfoEditField_SC = uieditfield(app.ScanphasecorrectTab, 'text');
            app.ROIInfoEditField_SC.Editable = 'off';
            app.ROIInfoEditField_SC.Position = [130 254 170 22];
            
            % Create SelectROIButton_SC
            app.SelectROIButton_SC = uibutton(app.ScanphasecorrectTab, 'push');
            app.SelectROIButton_SC.ButtonPushedFcn = createCallbackFcn(app, @SelectROIButton_SCPushed, true);
            app.SelectROIButton_SC.Position = [21 254 100 23];
            app.SelectROIButton_SC.Text = 'Select ROI';
            
            % Create ScanphaseSpinner_SC
            app.ScanphaseSpinner_SC = uispinner(app.ScanphasecorrectTab);
            app.ScanphaseSpinner_SC.Visible = 'off';
            app.ScanphaseSpinner_SC.Position = [250 294 50 22];
            
            % Create ScanphaseCorrectDropDown_SC
            app.ScanphaseCorrectDropDown_SC = uidropdown(app.ScanphasecorrectTab);
            app.ScanphaseCorrectDropDown_SC.Items = {'Auto', 'Fixed'};
            app.ScanphaseCorrectDropDown_SC.ValueChangedFcn = createCallbackFcn(app, @ScanphaseCorrectDropDown_SCValueChanged, true);
            app.ScanphaseCorrectDropDown_SC.Position = [140 294 100 22];
            app.ScanphaseCorrectDropDown_SC.Value = 'Auto';
            
            % Create Label_SC_Mode
            app.Label_SC_Mode = uilabel(app.ScanphasecorrectTab);
            app.Label_SC_Mode.Position = [21 294 114 22];
            app.Label_SC_Mode.Text = 'Correction Mode';
            
            % Create SelectPathButton_SC
            app.SelectPathButton_SC = uibutton(app.ScanphasecorrectTab, 'push');
            app.SelectPathButton_SC.ButtonPushedFcn = createCallbackFcn(app, @SelectPathButton_SCPushed, true);
            app.SelectPathButton_SC.Position = [570 338 25 23];
            app.SelectPathButton_SC.Text = '...';
            
            % Create FolderEditField_SC
            app.FolderEditField_SC = uieditfield(app.ScanphasecorrectTab, 'text');
            app.FolderEditField_SC.Editable = 'off';
            app.FolderEditField_SC.Position = [130 339 429 22];
            
            % Create FolderDropDown_SC
            app.FolderDropDown_SC = uidropdown(app.ScanphasecorrectTab);
            app.FolderDropDown_SC.Items = {'Single File', 'Batch Folder'};
            app.FolderDropDown_SC.ValueChangedFcn = createCallbackFcn(app, @FolderDropDown_SCValueChanged, true);
            app.FolderDropDown_SC.Position = [21 338 100 22];
            app.FolderDropDown_SC.Value = 'Single File';
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = TiffProcess_exported
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            % Execute the startup function
            runStartupFcn(app, @startupFcn)
            
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