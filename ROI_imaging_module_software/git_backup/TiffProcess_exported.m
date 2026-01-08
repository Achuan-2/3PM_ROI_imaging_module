classdef TiffProcess_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        SplitandprocessTab              matlab.ui.container.Tab
        RippleNoiseCheckBox             matlab.ui.control.CheckBox
        ScanphaseSpinner                matlab.ui.control.Spinner
        OutputFolderEditFieldLabel      matlab.ui.control.Label
        OutputFolderEditField           matlab.ui.control.EditField
        RemoveRippleNoiseSpinner        matlab.ui.control.Spinner
        ScanphaseCorrectDropDownLabel   matlab.ui.control.Label
        ScanphaseCorrectDropDown        matlab.ui.control.DropDown
        OutputFolderEditFieldLabel_2    matlab.ui.control.Label
        RegisterCheckBox                matlab.ui.control.CheckBox
        EnableRippleNoiseCheckBox       matlab.ui.control.CheckBox
        RemoveRippleNoiseLabel          matlab.ui.control.Label
        SetLabel                        matlab.ui.control.Label
        ScanphaseMethodDropDown_2Label  matlab.ui.control.Label
        ScanphaseMethodDropDown_1       matlab.ui.control.DropDown
        ScanphaseBatchSpinner           matlab.ui.control.Spinner
        CopyCH1CheckBox                 matlab.ui.control.CheckBox
        ScanphasecorrectCheckBox        matlab.ui.control.CheckBox
        RandomdenosiingCheckBox         matlab.ui.control.CheckBox
        RegisterationCheckBox           matlab.ui.control.CheckBox
        FPAimagingreconstructCheckBox   matlab.ui.control.CheckBox
        ProcessButton                   matlab.ui.control.Button
        OpenFolderButton                matlab.ui.control.Button
        RemoveperiodicnoiseCheckBox     matlab.ui.control.CheckBox
        PostprocessingDropDown          matlab.ui.control.DropDown
        PostprocessingDropDownLabel     matlab.ui.control.Label
        FileSelectButton                matlab.ui.control.Button
        TiffRangeLabel                  matlab.ui.control.Label
        TiffLabel                       matlab.ui.control.Label
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
        OpenFolderButton_3              matlab.ui.control.Button
        OutputFolderEditField_2Label_2  matlab.ui.control.Label
        OutputFolderEditField_3         matlab.ui.control.EditField
        ProcessButton_3                 matlab.ui.control.Button
        regFileSelectButton_2           matlab.ui.control.Button
        FolderEditField_5               matlab.ui.control.EditField
        FolderDropDown_3                matlab.ui.control.DropDown
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
        OpenFolderButton_4              matlab.ui.control.Button
        OutputFolderEditField_2Label_3  matlab.ui.control.Label
        OutputFolderEditField_4         matlab.ui.control.EditField
        ProcessButton_4                 matlab.ui.control.Button
        regFileSelectButton_3           matlab.ui.control.Button
        FolderEditField_6               matlab.ui.control.EditField
        FolderDropDown_4                matlab.ui.control.DropDown
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
        TiffenhancedTab                 matlab.ui.container.Tab
        FileSelectButton_2              matlab.ui.control.Button
        FolderEditField_3               matlab.ui.control.EditField
        TopSpinnerLabel                 matlab.ui.control.Label
        TopSpinner                      matlab.ui.control.Spinner
        SaturateLabel                   matlab.ui.control.Label
        BottomSpinnerLabel              matlab.ui.control.Label
        BottomSpinner                   matlab.ui.control.Spinner
        AddLutDropDownLabel             matlab.ui.control.Label
        AddLutDropDown                  matlab.ui.control.DropDown
        outputButton                    matlab.ui.control.Button
        TiffextractTab                  matlab.ui.container.Tab
        FileSelectButton_3              matlab.ui.control.Button
        FolderEditField_4               matlab.ui.control.EditField
        outputButton_2                  matlab.ui.control.Button
        FrameStartLabel                 matlab.ui.control.Label
        FrameStartSpinner               matlab.ui.control.Spinner
        FrameEndSpinnerLabel            matlab.ui.control.Label
        FrameEndSpinner                 matlab.ui.control.Spinner
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
        cellArrayText_ROIRebuild; % Console text for ROI Rebuild Tab
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
                app.OpenFolderButton.Enable = "off";
                return;
            end

            fileNum = app.fileEndIndex- app.fileStartIndex+1;

            if fileNum > 1
                app.EndSpinner.Limits = [app.fileStartIndex,app.fileEndIndex];
                app.StartSpinner.Limits = [app.fileStartIndex,app.fileEndIndex];
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
            app.OpenFolderButton.Enable = "on";
            app.RippleNoiseCheckBox.Enable = "on";
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
                    bufferProperty = 'cellArrayText_ROIRebuild';
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
            progressDlgMessage  =progressDlg.Message;
            [~, fname, ~] = fileparts(filepath);

            % Step 1: Split channels (ripple noise correction happens here)
            utils.tiff_split(filepath, nChannels, 'FolderProcessed',folderProcessed, 'AvgOutput', true, 'rippleNoiseEnable',app.EnableRippleNoiseCheckBox.Value,'rippleNoise', app.RemoveRippleNoiseSpinner.Value,'progressDlg',progressDlg);

            % Step 2: Process each channel (Scanphase, Registration, JSON logging)
            initial_bidphase = 0; % To store the bidphase from the first channel
            % --- MODIFICATION START ---
            ch1_motion_offsets = []; % Variable to hold offsets from the first channel
            % --- MODIFICATION END ---


            for i = 1:nChannels
                % Reset progress bar message
                progressDlg.Message = sprintf("%s <b>CH%d</b>",progressDlgMessage,i);

                baseFilename = sprintf('%s_ch%d.tif', fname, i);
                channelFilePath = fullfile(folderProcessed, baseFilename);

                % --- Scanphase Correction ---
                channel_scanphase_mode = app.ScanphaseCorrectDropDown.Value;
                current_bidphase = app.ScanphaseSpinner.Value;
                offsetLog = containers.Map('KeyType','char','ValueType','any');

                if i == 1
                    % For the first channel, run correction as selected
                    [initial_bidphase, offsetLog] = scanphase_correct(app, channelFilePath, folderProcessed, channel_scanphase_mode, current_bidphase, progressDlg, @app.print_console);
                else
                    % For subsequent channels, reuse the first channel's 'Auto' result if applicable
                    if channel_scanphase_mode == "Auto" && initial_bidphase ~= 0
                        [~, offsetLog] = scanphase_correct(app, channelFilePath, folderProcessed, 'Fixed', initial_bidphase, progressDlg, @app.print_console);
                    else % 'Off' or 'Fixed' mode
                        [~, offsetLog] = scanphase_correct(app, channelFilePath, folderProcessed, channel_scanphase_mode, current_bidphase, progressDlg, @app.print_console);
                    end
                end

                % ---  Registration Logic ---
                if app.RegisterCheckBox.Value
                    progressDlg.Message = sprintf("%s <b>CH%d Registration</b>",progressDlgMessage,i);
                    if app.CopyCH1CheckBox.Value
                        if i == 1
                            % For CH1, run full registration and get the offsets
                            [ch1_motion_offsets, ~] = registration(app, channelFilePath, folderProcessed, true, "Off", 0, "", progressDlg, @app.print_console);
                        else
                            % For subsequent channels, apply the offsets from CH1
                            if ~isempty(ch1_motion_offsets)
                                registration(app, channelFilePath, folderProcessed, true, "Off", 0, "", progressDlg, @app.print_console, 'ApplyOffsets', ch1_motion_offsets);
                            else
                                app.print_console(sprintf('CH%d: Skipping registration, no offsets from CH1.', i));
                            end
                        end
                    else
                        registration(app, channelFilePath, folderProcessed, true, "Off", 0, "", progressDlg, @app.print_console);
                    end
                end


                % --- JSON Logging ---
                params = struct();
                params.sourceFile = filepath;
                params.outputFile = channelFilePath;
                params.channelNumber = i;
                params.totalChannels = nChannels;

                params.rippleNoise = struct();
                params.rippleNoise.enabled = app.EnableRippleNoiseCheckBox.Value;
                params.rippleNoise.threshold = app.RemoveRippleNoiseSpinner.Value;

                params.scanphaseCorrect = struct();
                params.scanphaseCorrect.mode = app.ScanphaseCorrectDropDown.Value;
                params.scanphaseCorrect.method = app.ScanphaseMethodDropDown_1.Value;
                params.scanphaseCorrect.userSetValue = app.ScanphaseSpinner.Value; % The value from the spinner
                params.scanphaseCorrect.offsetLog = offsetLog; % The detailed log

                params.registration = struct();
                params.registration.enabled = app.RegisterCheckBox.Value;

                % Call the centralized logging function
                app.saveOrUpdateProcessJSON('TiffSplit_Channel', params);
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

        function [bidphase, offsetLog] = scanphase_correct(app,inputPath,folderProcessed,ScanphaseCorrectDropDownValue,ScanphaseSpinnerValue,progressDlg,print_console)
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
            batch_size = app.ScanphaseBatchSpinner.Value;

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
                    print_console(sprintf("Scanphase predicted: %d", bidphase));
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
                    if app.ScanphaseMethodDropDown_1.Value == "Batch" && app.ScanphaseCorrectDropDown.Value == "Auto"
                        current_bidphase = RIMA.scanphase_predict(framesBatch);
                        print_console(sprintf("Frames %d-%d, Scanphase predicted: %d", startFrame, endFrame, current_bidphase));
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
            
            app.process_roi_rebuild();
        end

        function ClearButton_ROIRebuildPushed(app, event)
            app.ConsoleTextArea_ROIRebuild.Value = '';
            app.cellArrayText_ROIRebuild = {};
        end

        function process_roi_rebuild(app)
            % Create a progress dialog
            progressDlg = uiprogressdlg(app.UIFigure, 'Title', 'ROI Rebuild', ...
                'Cancelable', 'on', 'Interpreter', 'html');
            
            try
                app.print_console('Starting ROI rebuild process...');
                [folder, fname, fext] = fileparts(app.roiRebuildPath);

                % --- Step 1: Read TIFF stack ---
                progressDlg.Message = 'Reading source TIFF file...';
                progressDlg.Indeterminate = 'on';
                imgStack = utils.tiff_read(app.roiRebuildPath);
                tags = utils.tiff_read_tag(app.roiRebuildPath);
                
                % --- Step 2: Rebuild image ---
                progressDlg.Message = 'Rebuilding from subframes...';
                imgStackRebuilt = roiImaging.subframe_rebuild(imgStack);
                app.print_console('Subframe rebuild completed.');

                % --- Step 3: Save rebuilt image ---
                progressDlg.Message = 'Saving rebuilt TIFF file...';
                rebuiltFname = strcat(fname, '_rebuilt');
                rebuiltPath = fullfile(folder, [rebuiltFname, fext]);
                
                % Create a valid tag structure for the new image dimensions
                rebuilt_tags = utils.tiff_generate_tagstruct(imgStackRebuilt(:,:,1), tags);
                
                utils.tiff_save(imgStackRebuilt, rebuiltPath, rebuilt_tags);
                app.print_console(sprintf('Rebuilt file saved to: %s', rebuiltPath));

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
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            warning('off','imageio:tiffutils:libtiffWarning') % 抑制fast write导致的warning
            addpath('libs')
            addpath('libs/vol3d')
            addpath('libs/ReadImageJROI')
            addpath('libs/FastTiffReadWrite')
            % assignin('base', 'app',app)
            app.StartSpinner.Enable = "off";
            app.EndSpinner.Enable = "off";
            app.ProcessButton.Enable = "off";
            app.OpenFolderButton.Enable = "off";
            app.RippleNoiseCheckBox.Enable = "off";
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
            app.cellArrayText_ROIRebuild = {}; % Initialize buffer


            % 检测是否存在config_tiff_process.json文件，如果没有，则新建

            app.exePath = utils.GetExecutableFolder();

            if isfile(fullfile(app.exePath, 'config_tiff_process.json'))
                text = fileread(fullfile(app.exePath, 'config_tiff_process.json'));
                config = jsondecode(text);
                if isfield(config, 'ripple_noise')
                    app.RemoveRippleNoiseSpinner.Value = config.ripple_noise;
                end

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
                config.ripple_noise = app.RemoveRippleNoiseSpinner.Value;
                config.last_select_path = '';
                config.nChannel = app.nChannelSpinner.Value;
                json_data = jsonencode(config);

                fileID = fopen(fullfile(app.exePath, 'config_tiff_process.json'), 'w');
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
                    app.OpenFolderButton.Enable = "on";
                    app.RippleNoiseCheckBox.Enable = "on";
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
            else
                if value < app.fileEndIndex
                    app.EndSpinner.Limits = [value,app.fileEndIndex];
                end
            end

        end

        % Value changed function: EndSpinner
        function EndSpinnerValueChanged(app, event)
            value = app.EndSpinner.Value;
            if app.onlyOne
                app.EndSpinner.Value =app.fileEndIndex;
            else
                if value > 1
                    app.StartSpinner.Limits = [1,value];
                end
            end
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            app.update_tiff_index()
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)

            winopen(app.folder);
        end

        % Value changed function: RippleNoiseCheckBox
        function RippleNoiseCheckBoxValueChanged(app, event)
            value = app.RippleNoiseCheckBox.Value;
            if value
                app.RemoveRippleNoiseSpinner.Enable = 'on';
            else
                app.RemoveRippleNoiseSpinner.Enable = 'off';
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % 软件关闭前，保存ripple设置到文件
            config.ripple_noise = app.RemoveRippleNoiseSpinner.Value;
            config.last_select_path = strrep(app.folder, '\', '\\');
            config.nChannel = app.nChannelSpinner.Value;
            json_data = jsonencode(config);


            fileID = fopen( fullfile(app.exePath, 'config_tiff_process.json'), 'w');
            fprintf(fileID, json_data);
            fclose(fileID);


            delete(app)

        end

        % Value changed function: ScanphaseCorrectDropDown
        function ScanphaseCorrectDropDownValueChanged(app, event)
            value = app.ScanphaseCorrectDropDown.Value;
            switch value
                case 'Fixed'
                    app.ScanphaseSpinner.Visible = 'on';
                case {'Off','Auto'}
                    app.ScanphaseSpinner.Visible = 'off';
            end
        end

        % Value changed function: FolderDropDown
        function FolderDropDownValueChanged(app, event)
            app.FolderEditField.Value = '';
            app.StartSpinner.Enable = 'off';
            app.EndSpinner.Enable = 'off';
            app.UpdateButton.Enable = 'off';
            app.ProcessButton.Enable = 'off';
            app.TiffRangeLabel.Text = 'file_0000a ~ file_0000b';
            app.OpenFolderButton.Enable="off";
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

        % Callback function: not associated with a component
        function HelpMenuSelected(app, event)
            message = fileread('README.md');
            uialert(app.UIFigure,message,'Help','Icon','info',"Interpreter","html");
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

        % Button pushed function: FileSelectButton_2
        function FileSelectButton_2Pushed(app, event)
            [filename,selectedDir] = utils.select_file({'.tif'},app.folderToEnhance);
            if filename == 0 % 如果不选择文件返回为0
                uialert(app.UIFigure,'未选择文件','Warning','Icon','warning');
                return;
            end
            app.folderToEnhance = selectedDir;
            app.tiffToEnhancePath = fullfile(selectedDir,filename);
            app.FolderEditField_3.Value = filename;
        end

        % Button pushed function: outputButton
        function outputButtonPushed(app, event)
            d = uiprogressdlg(app.UIFigure,'Title','Processing',...
                'Indeterminate','on');
            drawnow
            img = utils.tiff_read(app.tiffToEnhancePath);
            frames = size(img,3);
            isNeedAvg = false;
            if frames > 1
                % 多帧，需要取平均
                originalType = class(img);  % 获取原始数据类型
                switch originalType
                    case {'uint8', 'uint16'}
                        % 转换为single类型计算平均值
                        img = mean(single(img), 3);
                        % 转换回原始类型
                        img = cast(img, originalType);
                    otherwise
                        % 其他类型直接计算平均值
                        img = mean(img, 3);
                end
                isNeedAvg = true;
            else
                % 单帧，无需处理
            end


            max_val = app.TopSpinner.Value/100;
            min_val = app.BottomSpinner.Value /100;
            tol = [min_val 1-max_val]; % top 0.5%饱和
            limits = stretchlim(img, tol);
            normalizedImage = imadjust(img, limits, []);

            top_percentage_str = num2str(app.TopSpinner.Value);
            bottom_percentage_str = num2str(app.BottomSpinner.Value);
            percentage_suffix = strcat("(top", top_percentage_str,"%" ,"bottom", bottom_percentage_str,"%" ,")");

            addlut = true;
            switch app.AddLutDropDown.Value
                case 'none'
                    addlut = false;
                case 'green'
                    normalizedImageRGB = cat(3,zeros(size(img)),normalizedImage,zeros(size(img)));
                case 'red'
                    normalizedImageRGB = cat(3,normalizedImage,zeros(size(img)),zeros(size(img)));
                case 'cyan'
                    lut = zeros(256, 3);
                    % R 分量 (保持较低值以强调青蓝色)
                    lut(:,1) = linspace(0, 0.2, 256)';
                    % G 分量 (中等强度)
                    lut(:,2) = linspace(0, 0.8, 256)';
                    % B 分量 (最高强度以产生青蓝色)
                    lut(:,3) = linspace(0.3, 1, 256)';

                    % 将灰度图像应用 LUT
                    normalizedImageRGB = ind2rgb(normalizedImage, lut);
                case 'megenta'
                    num_levels = 256;
                    magenta_lut = zeros(num_levels, 3);
                    magenta_lut(:, 1) = linspace(0, 1, num_levels)'; % 红色分量线性增加
                    magenta_lut(:, 2) = zeros(num_levels, 1);        % 绿色分量保持为 0，以获得品红色
                    magenta_lut(:, 3) = linspace(0, 1, num_levels)'; % 蓝色分量线性增加
                    normalizedImageRGB = ind2rgb(normalizedImage, magenta_lut);
            end
            [folder,fname,fext]= fileparts(app.tiffToEnhancePath);
            if app.TopSpinner.Value>0 || app.BottomSpinner.Value>0
                if isNeedAvg
                    utils.tiff_save(img,fullfile(folder,strcat(fname,"_",num2str(frames),"_Frames","_AVG", fext)));
                    utils.tiff_save(normalizedImage,fullfile(folder,strcat(fname,"_",num2str(frames),"_Frames","_AVG_EnhanceContrast", percentage_suffix, fext)));
                    if addlut
                        imwrite(normalizedImageRGB,fullfile(folder,strcat(fname,"_",num2str(frames),"_Frames","_AVG_EnhanceContrast", percentage_suffix,"_",app.AddLutDropDown.Value, percentage_suffix, ".png")));
                    end
                else
                    utils.tiff_save(normalizedImage,fullfile(folder,strcat(fname,"_EnhanceContrast", percentage_suffix, fext)));
                    if addlut
                        imwrite(normalizedImageRGB,fullfile(folder,strcat(fname,"_EnhanceContrast", percentage_suffix,"_",app.AddLutDropDown.Value, percentage_suffix, ".png")));
                    end
                end
            else
                % 如果不需要增强
                if isNeedAvg

                    utils.tiff_save(img,fullfile(folder,strcat(fname,"_",num2str(frames),"_Frames","_AVG", fext)));
                    if addlut
                        imwrite(normalizedImageRGB,fullfile(folder,strcat(fname,"_",num2str(frames),"_Frames","_AVG", "_",app.AddLutDropDown.Value, percentage_suffix, ".png")));
                    end
                else

                    if addlut
                        imwrite(normalizedImageRGB,fullfile(folder,strcat(fname,"_",app.AddLutDropDown.Value, percentage_suffix, ".png")));
                    end
                end
            end

            close(d);
            selection = uiconfirm(app.UIFigure, 'Saved successfully.', 'Save Done', ...
                'Options', {'OK', 'Open Export Folder'}, ...
                'DefaultOption', 1, ... % Default button is OK
                'Icon', 'success');
            if strcmp(selection, 'Open Export Folder')
                if isfolder(app.folderToEnhance)
                    winopen(app.folderToEnhance); % Open folder in Windows
                    % For macOS or Linux compatibility, you can use open(exportFolderPath);
                else
                    uialert(app.UIFigure, 'Invalid export folder path!', 'Error', 'Icon', 'error');
                end
            end


        end

        % Button pushed function: ManualRegButton
        function ManualRegButtonPushed(app, event)
            ManualImageRegistration;
        end

        % Value changed function: ScanphaseMethodDropDown_1
        function ScanphaseMethodDropDown_1ValueChanged(app, event)
            value = app.ScanphaseMethodDropDown_1.Value;
            switch value
                case 'Batch'
                    app.ScanphaseBatchSpinner.Visible = 'on';
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
            app.nChannelSpinner.Tooltip = {'Set the number of channels'};
            app.nChannelSpinner.Position = [110 267 51 22];
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
            app.EndSpinner.Position = [198 235 51 22];
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
            app.StartSpinner.Position = [69 236 55 22];
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

            % Create TiffLabel
            app.TiffLabel = uilabel(app.SplitandprocessTab);
            app.TiffLabel.FontWeight = 'bold';
            app.TiffLabel.Position = [27 299 25 22];
            app.TiffLabel.Text = 'Tiff';

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
            app.PostprocessingDropDown.Position = [124 205 100 22];
            app.PostprocessingDropDown.Value = 'CH1';

            % Create RemoveperiodicnoiseCheckBox
            app.RemoveperiodicnoiseCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RemoveperiodicnoiseCheckBox.Text = 'Remove periodic noise';
            app.RemoveperiodicnoiseCheckBox.Position = [35 179 144 22];

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.SplitandprocessTab, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.FontWeight = 'bold';
            app.OpenFolderButton.Tooltip = {'Open selected path'};
            app.OpenFolderButton.Position = [166 21 100 23];
            app.OpenFolderButton.Text = 'Open Folder';

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

            % Create RegisterationCheckBox
            app.RegisterationCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RegisterationCheckBox.Text = 'Registeration';
            app.RegisterationCheckBox.Position = [35 102 93 22];

            % Create RandomdenosiingCheckBox
            app.RandomdenosiingCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RandomdenosiingCheckBox.Text = 'Random denosiing';
            app.RandomdenosiingCheckBox.Position = [35 77 122 22];

            % Create ScanphasecorrectCheckBox
            app.ScanphasecorrectCheckBox = uicheckbox(app.SplitandprocessTab);
            app.ScanphasecorrectCheckBox.Text = 'Scanphase correct';
            app.ScanphasecorrectCheckBox.Position = [35 127 122 22];

            % Create CopyCH1CheckBox
            app.CopyCH1CheckBox = uicheckbox(app.SplitandprocessTab);
            app.CopyCH1CheckBox.Tooltip = {'Copy CH1 reg result  to other CH'};
            app.CopyCH1CheckBox.Text = 'Copy CH1';
            app.CopyCH1CheckBox.Position = [396 40 77 22];
            app.CopyCH1CheckBox.Value = true;

            % Create ScanphaseBatchSpinner
            app.ScanphaseBatchSpinner = uispinner(app.SplitandprocessTab);
            app.ScanphaseBatchSpinner.Limits = [1 Inf];
            app.ScanphaseBatchSpinner.Tooltip = {'Bidirectional Phase offset from line scanning (set by user)'};
            app.ScanphaseBatchSpinner.Position = [553 68 61 22];
            app.ScanphaseBatchSpinner.Value = 100;

            % Create ScanphaseMethodDropDown_1
            app.ScanphaseMethodDropDown_1 = uidropdown(app.SplitandprocessTab);
            app.ScanphaseMethodDropDown_1.Items = {'All', 'Batch'};
            app.ScanphaseMethodDropDown_1.ValueChangedFcn = createCallbackFcn(app, @ScanphaseMethodDropDown_1ValueChanged, true);
            app.ScanphaseMethodDropDown_1.Position = [443 68 100 22];
            app.ScanphaseMethodDropDown_1.Value = 'All';

            % Create ScanphaseMethodDropDown_2Label
            app.ScanphaseMethodDropDown_2Label = uilabel(app.SplitandprocessTab);
            app.ScanphaseMethodDropDown_2Label.FontWeight = 'bold';
            app.ScanphaseMethodDropDown_2Label.Position = [312 68 114 22];
            app.ScanphaseMethodDropDown_2Label.Text = 'Scanphase Method';

            % Create SetLabel
            app.SetLabel = uilabel(app.SplitandprocessTab);
            app.SetLabel.Position = [476 129 25 22];
            app.SetLabel.Text = 'Set';

            % Create RemoveRippleNoiseLabel
            app.RemoveRippleNoiseLabel = uilabel(app.SplitandprocessTab);
            app.RemoveRippleNoiseLabel.Position = [337 129 121 22];
            app.RemoveRippleNoiseLabel.Text = 'Remove Ripple Noise';

            % Create EnableRippleNoiseCheckBox
            app.EnableRippleNoiseCheckBox = uicheckbox(app.SplitandprocessTab);
            app.EnableRippleNoiseCheckBox.Text = '';
            app.EnableRippleNoiseCheckBox.Position = [311 129 23 22];
            app.EnableRippleNoiseCheckBox.Value = true;

            % Create RegisterCheckBox
            app.RegisterCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RegisterCheckBox.Tooltip = {'Wheter to do registration'};
            app.RegisterCheckBox.Text = '';
            app.RegisterCheckBox.Position = [312 40 26 22];

            % Create OutputFolderEditFieldLabel_2
            app.OutputFolderEditFieldLabel_2 = uilabel(app.SplitandprocessTab);
            app.OutputFolderEditFieldLabel_2.FontWeight = 'bold';
            app.OutputFolderEditFieldLabel_2.Position = [334 40 50 22];
            app.OutputFolderEditFieldLabel_2.Text = 'Register';

            % Create ScanphaseCorrectDropDown
            app.ScanphaseCorrectDropDown = uidropdown(app.SplitandprocessTab);
            app.ScanphaseCorrectDropDown.Items = {'Off', 'Auto', 'Fixed'};
            app.ScanphaseCorrectDropDown.ValueChangedFcn = createCallbackFcn(app, @ScanphaseCorrectDropDownValueChanged, true);
            app.ScanphaseCorrectDropDown.Tooltip = {'Whether to do bidirectional correction'};
            app.ScanphaseCorrectDropDown.Position = [444 102 89 22];
            app.ScanphaseCorrectDropDown.Value = 'Off';

            % Create ScanphaseCorrectDropDownLabel
            app.ScanphaseCorrectDropDownLabel = uilabel(app.SplitandprocessTab);
            app.ScanphaseCorrectDropDownLabel.FontWeight = 'bold';
            app.ScanphaseCorrectDropDownLabel.Position = [312 102 114 22];
            app.ScanphaseCorrectDropDownLabel.Text = 'Scanphase Correct';

            % Create RemoveRippleNoiseSpinner
            app.RemoveRippleNoiseSpinner = uispinner(app.SplitandprocessTab);
            app.RemoveRippleNoiseSpinner.Limits = [0 Inf];
            app.RemoveRippleNoiseSpinner.Enable = 'off';
            app.RemoveRippleNoiseSpinner.Tooltip = {'Remove noise below a specified threshold'};
            app.RemoveRippleNoiseSpinner.Position = [509 129 100 22];
            app.RemoveRippleNoiseSpinner.Value = 700;

            % Create OutputFolderEditField
            app.OutputFolderEditField = uieditfield(app.SplitandprocessTab, 'text');
            app.OutputFolderEditField.HorizontalAlignment = 'right';
            app.OutputFolderEditField.Tooltip = {'Set output folder name'};
            app.OutputFolderEditField.Position = [161 49 100 22];
            app.OutputFolderEditField.Value = 'Processed';

            % Create OutputFolderEditFieldLabel
            app.OutputFolderEditFieldLabel = uilabel(app.SplitandprocessTab);
            app.OutputFolderEditFieldLabel.FontWeight = 'bold';
            app.OutputFolderEditFieldLabel.Position = [30 49 85 22];
            app.OutputFolderEditFieldLabel.Text = 'Output Folder';

            % Create ScanphaseSpinner
            app.ScanphaseSpinner = uispinner(app.SplitandprocessTab);
            app.ScanphaseSpinner.Visible = 'off';
            app.ScanphaseSpinner.Tooltip = {'Bidirectional Phase offset from line scanning (set by user)'};
            app.ScanphaseSpinner.Position = [552 102 49 22];

            % Create RippleNoiseCheckBox
            app.RippleNoiseCheckBox = uicheckbox(app.SplitandprocessTab);
            app.RippleNoiseCheckBox.ValueChangedFcn = createCallbackFcn(app, @RippleNoiseCheckBoxValueChanged, true);
            app.RippleNoiseCheckBox.Tooltip = {'Enable Ripple Noise option'};
            app.RippleNoiseCheckBox.Text = '';
            app.RippleNoiseCheckBox.Position = [457 129 26 22];

            % Create PeriodicdenoisingTab
            app.PeriodicdenoisingTab = uitab(app.TabGroup);
            app.PeriodicdenoisingTab.Title = 'Periodic denoising';

            % Create FolderDropDown_3
            app.FolderDropDown_3 = uidropdown(app.PeriodicdenoisingTab);
            app.FolderDropDown_3.Items = {'Folder', 'File'};
            app.FolderDropDown_3.Tooltip = {'File mode or folder mode'};
            app.FolderDropDown_3.Position = [14 339 69 22];
            app.FolderDropDown_3.Value = 'Folder';

            % Create FolderEditField_5
            app.FolderEditField_5 = uieditfield(app.PeriodicdenoisingTab, 'text');
            app.FolderEditField_5.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_5.Tooltip = {'Selected Path'};
            app.FolderEditField_5.Position = [95 339 464 22];

            % Create regFileSelectButton_2
            app.regFileSelectButton_2 = uibutton(app.PeriodicdenoisingTab, 'push');
            app.regFileSelectButton_2.Tooltip = {'Choose a file or folder'};
            app.regFileSelectButton_2.Position = [570 339 25 23];
            app.regFileSelectButton_2.Text = '...';

            % Create ProcessButton_3
            app.ProcessButton_3 = uibutton(app.PeriodicdenoisingTab, 'push');
            app.ProcessButton_3.FontWeight = 'bold';
            app.ProcessButton_3.Tooltip = {'Start image registration'};
            app.ProcessButton_3.Position = [11 253 100 23];
            app.ProcessButton_3.Text = 'Process';

            % Create OutputFolderEditField_3
            app.OutputFolderEditField_3 = uieditfield(app.PeriodicdenoisingTab, 'text');
            app.OutputFolderEditField_3.HorizontalAlignment = 'right';
            app.OutputFolderEditField_3.Tooltip = {'Set output folder name'};
            app.OutputFolderEditField_3.Position = [148 293 100 22];

            % Create OutputFolderEditField_2Label_2
            app.OutputFolderEditField_2Label_2 = uilabel(app.PeriodicdenoisingTab);
            app.OutputFolderEditField_2Label_2.FontWeight = 'bold';
            app.OutputFolderEditField_2Label_2.Position = [17 293 85 22];
            app.OutputFolderEditField_2Label_2.Text = 'Output Folder';

            % Create OpenFolderButton_3
            app.OpenFolderButton_3 = uibutton(app.PeriodicdenoisingTab, 'push');
            app.OpenFolderButton_3.FontWeight = 'bold';
            app.OpenFolderButton_3.Tooltip = {'Open selected path'};
            app.OpenFolderButton_3.Position = [132 254 100 23];
            app.OpenFolderButton_3.Text = 'Open Folder';

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

            % Create FolderDropDown_4
            app.FolderDropDown_4 = uidropdown(app.RandomdenoisingTab);
            app.FolderDropDown_4.Items = {'Folder', 'File'};
            app.FolderDropDown_4.Tooltip = {'File mode or folder mode'};
            app.FolderDropDown_4.Position = [14 339 69 22];
            app.FolderDropDown_4.Value = 'Folder';

            % Create FolderEditField_6
            app.FolderEditField_6 = uieditfield(app.RandomdenoisingTab, 'text');
            app.FolderEditField_6.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_6.Tooltip = {'Selected Path'};
            app.FolderEditField_6.Position = [95 339 464 22];

            % Create regFileSelectButton_3
            app.regFileSelectButton_3 = uibutton(app.RandomdenoisingTab, 'push');
            app.regFileSelectButton_3.Tooltip = {'Choose a file or folder'};
            app.regFileSelectButton_3.Position = [570 339 25 23];
            app.regFileSelectButton_3.Text = '...';

            % Create ProcessButton_4
            app.ProcessButton_4 = uibutton(app.RandomdenoisingTab, 'push');
            app.ProcessButton_4.FontWeight = 'bold';
            app.ProcessButton_4.Tooltip = {'Start image registration'};
            app.ProcessButton_4.Position = [11 253 100 23];
            app.ProcessButton_4.Text = 'Process';

            % Create OutputFolderEditField_4
            app.OutputFolderEditField_4 = uieditfield(app.RandomdenoisingTab, 'text');
            app.OutputFolderEditField_4.HorizontalAlignment = 'right';
            app.OutputFolderEditField_4.Tooltip = {'Set output folder name'};
            app.OutputFolderEditField_4.Position = [148 293 100 22];

            % Create OutputFolderEditField_2Label_3
            app.OutputFolderEditField_2Label_3 = uilabel(app.RandomdenoisingTab);
            app.OutputFolderEditField_2Label_3.FontWeight = 'bold';
            app.OutputFolderEditField_2Label_3.Position = [17 293 85 22];
            app.OutputFolderEditField_2Label_3.Text = 'Output Folder';

            % Create OpenFolderButton_4
            app.OpenFolderButton_4 = uibutton(app.RandomdenoisingTab, 'push');
            app.OpenFolderButton_4.FontWeight = 'bold';
            app.OpenFolderButton_4.Tooltip = {'Open selected path'};
            app.OpenFolderButton_4.Position = [132 254 100 23];
            app.OpenFolderButton_4.Text = 'Open Folder';

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

            % Create TiffenhancedTab
            app.TiffenhancedTab = uitab(app.TabGroup);
            app.TiffenhancedTab.Title = 'Tiff enhanced';

            % Create outputButton
            app.outputButton = uibutton(app.TiffenhancedTab, 'push');
            app.outputButton.ButtonPushedFcn = createCallbackFcn(app, @outputButtonPushed, true);
            app.outputButton.Position = [42 166 100 23];
            app.outputButton.Text = 'output';

            % Create AddLutDropDown
            app.AddLutDropDown = uidropdown(app.TiffenhancedTab);
            app.AddLutDropDown.Items = {'none', 'green', 'red', 'cyan', 'magenta'};
            app.AddLutDropDown.Position = [103 205 100 22];
            app.AddLutDropDown.Value = 'none';

            % Create AddLutDropDownLabel
            app.AddLutDropDownLabel = uilabel(app.TiffenhancedTab);
            app.AddLutDropDownLabel.Position = [42 205 46 22];
            app.AddLutDropDownLabel.Text = 'Add Lut';

            % Create BottomSpinner
            app.BottomSpinner = uispinner(app.TiffenhancedTab);
            app.BottomSpinner.Step = 0.1;
            app.BottomSpinner.Limits = [0 100];
            app.BottomSpinner.Position = [99 236 100 22];

            % Create BottomSpinnerLabel
            app.BottomSpinnerLabel = uilabel(app.TiffenhancedTab);
            app.BottomSpinnerLabel.Position = [41 236 43 22];
            app.BottomSpinnerLabel.Text = 'Bottom';

            % Create SaturateLabel
            app.SaturateLabel = uilabel(app.TiffenhancedTab);
            app.SaturateLabel.Position = [42 300 50 22];
            app.SaturateLabel.Text = 'Saturate';

            % Create TopSpinner
            app.TopSpinner = uispinner(app.TiffenhancedTab);
            app.TopSpinner.Step = 0.1;
            app.TopSpinner.Limits = [0 100];
            app.TopSpinner.HorizontalAlignment = 'left';
            app.TopSpinner.Position = [82 268 100 22];
            app.TopSpinner.Value = 0.5;

            % Create TopSpinnerLabel
            app.TopSpinnerLabel = uilabel(app.TiffenhancedTab);
            app.TopSpinnerLabel.Position = [42 268 25 22];
            app.TopSpinnerLabel.Text = 'Top';

            % Create FolderEditField_3
            app.FolderEditField_3 = uieditfield(app.TiffenhancedTab, 'text');
            app.FolderEditField_3.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_3.Tooltip = {'Selected Path'};
            app.FolderEditField_3.Position = [42 339 464 22];

            % Create FileSelectButton_2
            app.FileSelectButton_2 = uibutton(app.TiffenhancedTab, 'push');
            app.FileSelectButton_2.ButtonPushedFcn = createCallbackFcn(app, @FileSelectButton_2Pushed, true);
            app.FileSelectButton_2.Tooltip = {'Choose a file or folder'};
            app.FileSelectButton_2.Position = [534 338 25 23];
            app.FileSelectButton_2.Text = '...';

            % Create TiffextractTab
            app.TiffextractTab = uitab(app.TabGroup);
            app.TiffextractTab.Title = 'Tiff extract';

            % Create FrameEndSpinner
            app.FrameEndSpinner = uispinner(app.TiffextractTab);
            app.FrameEndSpinner.Limits = [1 Inf];
            app.FrameEndSpinner.HorizontalAlignment = 'left';
            app.FrameEndSpinner.Position = [135 265 56 22];
            app.FrameEndSpinner.Value = 1;

            % Create FrameEndSpinnerLabel
            app.FrameEndSpinnerLabel = uilabel(app.TiffextractTab);
            app.FrameEndSpinnerLabel.Position = [42 265 64 22];
            app.FrameEndSpinnerLabel.Text = 'Frame End';

            % Create FrameStartSpinner
            app.FrameStartSpinner = uispinner(app.TiffextractTab);
            app.FrameStartSpinner.Limits = [1 Inf];
            app.FrameStartSpinner.HorizontalAlignment = 'left';
            app.FrameStartSpinner.Position = [135 296 100 22];
            app.FrameStartSpinner.Value = 1;

            % Create FrameStartLabel
            app.FrameStartLabel = uilabel(app.TiffextractTab);
            app.FrameStartLabel.Position = [42 296 68 22];
            app.FrameStartLabel.Text = 'Frame Start';

            % Create outputButton_2
            app.outputButton_2 = uibutton(app.TiffextractTab, 'push');
            app.outputButton_2.Position = [41 215 100 23];
            app.outputButton_2.Text = 'output';

            % Create FolderEditField_4
            app.FolderEditField_4 = uieditfield(app.TiffextractTab, 'text');
            app.FolderEditField_4.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FolderEditField_4.Tooltip = {'Selected Path'};
            app.FolderEditField_4.Position = [42 339 464 22];

            % Create FileSelectButton_3
            app.FileSelectButton_3 = uibutton(app.TiffextractTab, 'push');
            app.FileSelectButton_3.Tooltip = {'Choose a file or folder'};
            app.FileSelectButton_3.Position = [534 338 25 23];
            app.FileSelectButton_3.Text = '...';

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