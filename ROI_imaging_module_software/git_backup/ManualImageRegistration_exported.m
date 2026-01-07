classdef ManualImageRegistration_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        SetRefLabel                    matlab.ui.control.Label
        LoadReferenceImageButton       matlab.ui.control.Button
        ZprojectionButton              matlab.ui.control.Button
        CurrentframeButton             matlab.ui.control.Button
        AffinePanel                    matlab.ui.container.Panel
        XOffsetLabel                   matlab.ui.control.Label
        XOffsetSpinner                 matlab.ui.control.Spinner
        YOffsetLabel                   matlab.ui.control.Label
        YOffsetSpinner                 matlab.ui.control.Spinner
        EnableAffineModeButton         matlab.ui.control.StateButton
        ScaleXLabel                    matlab.ui.control.Label
        ScaleYLabel                    matlab.ui.control.Label
        ScaleXSpinner                  matlab.ui.control.Spinner
        ScaleYSpinner                  matlab.ui.control.Spinner
        RotationLabel                  matlab.ui.control.Label
        RotationSpinner                matlab.ui.control.Spinner
        ShearXLabel                    matlab.ui.control.Label
        ShearXSpinner                  matlab.ui.control.Spinner
        ShearYLabel                    matlab.ui.control.Label
        ShearYSpinner                  matlab.ui.control.Spinner
        CopytransformationsButton      matlab.ui.control.Button
        PastetransformationsButton     matlab.ui.control.Button
        ApplyregistrationButton        matlab.ui.control.Button
        ApplytoframesButton            matlab.ui.control.Button
        FromframeLabel                 matlab.ui.control.Label
        FramesToApplyStartEdit         matlab.ui.control.NumericEditField
        ToframeLabel                   matlab.ui.control.Label
        FramesToApplyEndEdit           matlab.ui.control.NumericEditField
        ResetAllTransformationsButton  matlab.ui.control.Button
        AutoSaveCheckBox               matlab.ui.control.CheckBox
        ApplyLabel                     matlab.ui.control.Label
        ShowRefCheckBox                matlab.ui.control.CheckBox
        RefAlphaEdit                   matlab.ui.control.NumericEditField
        RefAlphaLabel                  matlab.ui.control.Label
        ContrastSlider                 matlab.ui.control.RangeSlider
        ContrastSliderLabel            matlab.ui.control.Label
        MaxFramesLabel                 matlab.ui.control.Label
        FrameSpinner                   matlab.ui.control.Spinner
        FrameSlider                    matlab.ui.control.Slider
        FrameLabel                     matlab.ui.control.Label
        MovingImageBrowseButton        matlab.ui.control.Button
        MovingImagePathEdit            matlab.ui.control.EditField
        MovingImagePathLabel           matlab.ui.control.Label
        ImageAxes                      matlab.ui.control.UIAxes
    end

    % Internal properties (corresponding to original class properties)
    properties (Access = private)
        fixedImage
        movingImage
        movingImageOriginal
        movingImagePath % 存储移动图像路径
        tiff_memmap = [];
        % Frame control
        currentFrame = 1 % 当前帧号，默认为第1帧
        maxFrames = 1 % 最大帧数
        
        % Display elements
        fixed_layer
        moving_layer
        
        % Alpha control
        refAlpha = 0.3 % 参考图像的Alpha值，默认为0.3
        
        % Tracking variables
        xoffset = 0
        yoffset = 0
        isDragging = false
        dragStartX = 0
        dragStartY = 0
        initialXData
        initialYData
        dragStartXoffset = 0
        dragStartYoffset = 0
        mouseClickedInImage = false % 跟踪鼠标是否点击在图像内
        
        % Affine transformation parameters
        scaleX = 1.0
        scaleY = 1.0
        rotation = 0 % in degrees
        shearX = 0
        shearY = 0
        
        % Transformation mode
        affineMode = false
        
        % 存储复制的变换参数
        copiedTransform = struct('xoffset', 0, 'yoffset', 0, ...
            'scaleX', 1.0, 'scaleY', 1.0, ...
            'rotation', 0, 'shearX', 0, 'shearY', 0)
        
        % 新增属性：自动保存
        autoSave = true
        
        % 新增属性：显示copied transform信息
        showCopiedTransform = false
        
        % 新增属性：亮度范围控制
        climMin
        climMax
        
        % 新增属性：参考帧号
        referenceFrameNum = 1
        
        % 新增属性：显示参考图层的复选框
        showReference = true % 默认显示参考图层
        
        % 新增属性：Z投影图像
        tiff_mean_img
        tiff_max_img
        tiff_std_img
    end
    methods
        
        function initializeDisplay(app)
            % 先显示移动图像（灰度）
            app.moving_layer = imshow(app.movingImage, [], 'Parent', app.ImageAxes, ...
                'Border', 'tight','initialmagnification','fit');
            clim(app.ImageAxes, [app.climMin, app.climMax]);
            
            hold(app.ImageAxes, 'on');
            
            % 再显示固定图像为绿色
            fixedImageAdjusted = imadjust(app.fixedImage);
            fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
            
            app.fixed_layer = imshow(fixedImageRGB, 'Parent', app.ImageAxes, ...
                'Border', 'tight','initialmagnification','fit');
            app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
            
            hold(app.ImageAxes, 'off');
            % 设置axes裁剪和固定显示范围，防止拖动时图片缩小
            app.ImageAxes.Clipping = 'on';
            [imgHeight, imgWidth] = size(app.fixedImage);
            app.ImageAxes.XLim = [0.5, imgWidth + 0.5];
            app.ImageAxes.YLim = [0.5, imgHeight + 0.5];
            app.ImageAxes.XLimMode = 'manual';
            app.ImageAxes.YLimMode = 'manual';
            % Store initial position
            app.initialXData = app.moving_layer.XData;
            app.initialYData = app.moving_layer.YData;
            
            % Add title to display current offset
            title(app.ImageAxes, ['Offset: x=', num2str(app.xoffset), ', y=', num2str(app.yoffset)]);
            
            % Set up mouse callbacks - bind to UIFigure instead of ImageAxes
            app.UIFigure.WindowButtonDownFcn = @app.startDrag;
            app.UIFigure.WindowButtonUpFcn = @app.endDrag;
            app.UIFigure.WindowButtonMotionFcn = @app.dragImage;
            
            % Update UI elements
            app.FrameSlider.Limits = [1, app.maxFrames];
            app.FrameSlider.Value = app.currentFrame;
            app.FrameSpinner.Value = app.currentFrame;
            app.MaxFramesLabel.Text = ['/', num2str(app.maxFrames)];
            app.RefAlphaEdit.Value = app.refAlpha;
            app.ShowRefCheckBox.Value = app.showReference;
            app.FramesToApplyStartEdit.Value = app.currentFrame + 1;
            app.FramesToApplyEndEdit.Value = app.maxFrames;
            app.AutoSaveCheckBox.Value = app.autoSave;
            
            % Disable affine spinners initially
            app.ScaleXSpinner.Enable = 'off';
            app.ScaleYSpinner.Enable = 'off';
            app.RotationSpinner.Enable = 'off';
            app.ShearXSpinner.Enable = 'off';
            app.ShearYSpinner.Enable = 'off';
        end
        % Start drag
        function startDrag(app, ~, ~)
            % Get cursor position relative to ImageAxes
            cursorPos = get(app.ImageAxes, 'CurrentPoint');
            app.dragStartX = cursorPos(1, 1);
            app.dragStartY = cursorPos(1, 2);
            
            % Store the offset at the start of dragging
            app.dragStartXoffset = app.xoffset;
            app.dragStartYoffset = app.yoffset;
            
            % Check if cursor is over the image and update mouseClickedInImage flag
            app.mouseClickedInImage = isInImage(app, app.dragStartX, app.dragStartY);
            
            % Set dragging flag only if clicked on the image
            if app.mouseClickedInImage
                app.isDragging = true;
            end
        end
        
        % End drag
        function endDrag(app, ~, ~)
            app.isDragging = false;
        end
        
        % Drag image
        function dragImage(app, ~, ~)
            % Handle drag motion
            if app.isDragging
                cursorPos = get(app.ImageAxes, 'CurrentPoint');
                currentX = cursorPos(1, 1);
                currentY = cursorPos(1, 2);
                
                % Calculate the change in position
                dx = currentX - app.dragStartX;
                dy = currentY - app.dragStartY;
                
                % Update offset based on drag distance
                app.xoffset = app.dragStartXoffset + dx;
                app.yoffset = app.dragStartYoffset + dy;
                
                % Apply the transformation
                applyTransformation(app);
            end
        end
        
        function result = isInImage(app, x, y)
            imgWidth = size(app.fixedImage, 2);
            imgHeight = size(app.fixedImage, 1);
            
            result = (x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight);
        end
        
        function result = hasTransformationApplied(app)
            result = app.xoffset ~= 0 || app.yoffset ~= 0 || ...
                app.scaleX ~= 1.0 || app.scaleY ~= 1.0 || ...
                app.rotation ~= 0 || app.shearX ~= 0 || app.shearY ~= 0;
        end
        function resetTransformParams(app)
            app.xoffset = 0;
            app.yoffset = 0;
            app.scaleX = 1.0;
            app.scaleY = 1.0;
            app.rotation = 0;
            app.shearX = 0;
            app.shearY = 0;
            
            app.XOffsetSpinner.Value = 0;
            app.YOffsetSpinner.Value = 0;
            app.ScaleXSpinner.Value = 1.0;
            app.ScaleYSpinner.Value = 1.0;
            app.RotationSpinner.Value = 0;
            app.ShearXSpinner.Value = 0;
            app.ShearYSpinner.Value = 0;
            
            app.dragStartX = 0;
            app.dragStartY = 0;
            app.dragStartXoffset = 0;
            app.dragStartYoffset = 0;
            app.isDragging = false;
        end
        function applyTransformation(app)
            [height, width] = size(app.movingImage);
            
            if app.affineMode
                tform = affine2d([app.scaleX, app.shearY, 0; ...
                    app.shearX, app.scaleY, 0; ...
                    0, 0, 1]);
                
                rotationRadians = deg2rad(app.rotation);
                rotMatrix = [cos(rotationRadians), -sin(rotationRadians), 0; ...
                    sin(rotationRadians), cos(rotationRadians), 0; ...
                    0, 0, 1];
                tform.T = tform.T * rotMatrix;
                
                transformedImage = imwarp(app.movingImage, tform, 'OutputView', imref2d([height, width]));
                
                app.moving_layer.CData = transformedImage;
                
                width = app.initialXData(2) - app.initialXData(1);
                height = app.initialYData(2) - app.initialYData(1);
                
                newXData = [app.initialXData(1) + app.xoffset, app.initialXData(1) + app.xoffset + width];
                newYData = [app.initialYData(1) + app.yoffset, app.initialYData(1) + app.yoffset + height];
                
                app.moving_layer.XData = newXData;
                app.moving_layer.YData = newYData;
                
                titleStr = sprintf('Translation: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f', ...
                    app.xoffset, app.yoffset, app.scaleX, app.scaleY, app.rotation, app.shearX, app.shearY);
                
                if app.showCopiedTransform
                    copiedStr = sprintf('Copied: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f\n', ...
                        app.copiedTransform.xoffset, app.copiedTransform.yoffset, ...
                        app.copiedTransform.scaleX, app.copiedTransform.scaleY, ...
                        app.copiedTransform.rotation, app.copiedTransform.shearX, app.copiedTransform.shearY);
                    titleStr = [copiedStr, titleStr];
                end
                
                title(app.ImageAxes, titleStr);
            else
                width = app.initialXData(2) - app.initialXData(1);
                height = app.initialYData(2) - app.initialYData(1);
                
                newXData = [app.initialXData(1) + app.xoffset, app.initialXData(1) + app.xoffset + width];
                newYData = [app.initialYData(1) + app.yoffset, app.initialYData(1) + app.yoffset + height];
                
                app.moving_layer.XData = newXData;
                app.moving_layer.YData = newYData;
                
                if app.showCopiedTransform
                    copiedStr = sprintf('Copied: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f\n', ...
                        app.copiedTransform.xoffset, app.copiedTransform.yoffset, ...
                        app.copiedTransform.scaleX, app.copiedTransform.scaleY, ...
                        app.copiedTransform.rotation, app.copiedTransform.shearX, app.copiedTransform.shearY);
                    title(app.ImageAxes, [copiedStr, 'Offset: x=', num2str(round(app.xoffset)), ', y=', num2str(round(app.yoffset))]);
                else
                    title(app.ImageAxes, ['Offset: x=', num2str(round(app.xoffset)), ', y=', num2str(round(app.yoffset))]);
                end
            end
            
            % Update Offset Spinners
            app.XOffsetSpinner.Value = app.xoffset;
            app.YOffsetSpinner.Value = app.yoffset;
            
            drawnow;
        end
        
        function loadImages(app, event)
            movingImagePath = app.MovingImagePathEdit.Value;
            
            % 检查必须提供运动图像路径
            if isempty(movingImagePath)
                errordlg('Please provide the moving image path!', 'Error');
                return;
            end
            
            % 检查文件是否存在
            if ~exist(movingImagePath, 'file')
                errordlg('Moving image file does not exist!', 'Error');
                return;
            end
            
            % Load moving image
            app.movingImagePath = movingImagePath;
            
            % 尝试读取，如果遇到 big-endian 错误则提示用户重写文件
            try
                app.tiff_memmap = memory_map_tiff(app.movingImagePath,[],1,false);
            catch ME
                if contains(ME.message, 'big-endian')
                    choice = questdlg(['The TIFF file is in big-endian format and cannot be memory mapped. ' ...
                        'Would you like to rewrite the file to little-endian format? ' ...
                        'A new file with suffix "_rewrite.tif" will be created.'], ...
                        'Big-Endian TIFF Detected', ...
                        'Yes', 'No', 'Yes');
                    
                    if strcmp(choice, 'Yes')
                        % 重写文件
                        [filepath, name, ext] = fileparts(app.movingImagePath);
                        
                        % 读取文件信息
                        fid = fopen(app.movingImagePath, 'r');
                        fseek(fid, 0, 'eof');
                        len = ftell(fid);
                        fclose(fid);
                        
                        info = readtifftags(app.movingImagePath);
                        if isfield(info, 'ImageDescription')
                            desc = info(1).ImageDescription;
                        else
                            desc = [];
                        end
                        newfile = fullfile(filepath, strcat(name, '_rewrite.tif'));
                        
                        % 创建进度条
                        waitMsg = waitbar(0, 'Rewriting TIFF file...', 'Name', 'Converting to Little-Endian');
                        
                        try
                            % 根据文件大小选择写入方式
                            if len/1e9 < 3.99
                                TiffWriter = Fast_Tiff_Write(newfile, info(1).Xresolution, 0, desc);
                            else
                                TiffWriter = Fast_BigTiff_Write(newfile, info(1).Xresolution, 0, desc);
                            end
                            
                            t = Tiff(app.movingImagePath, 'r');
                            numFrames = length(info);
                            for i = 1:numFrames
                                t.setDirectory(i);
                                img = t.read();
                                TiffWriter.WriteIMG(img');
                                waitbar(i/numFrames, waitMsg, sprintf('Rewriting frame %d/%d...', i, numFrames));
                            end
                            close(TiffWriter);
                            t.close();
                            close(waitMsg);
                            
                            % 使用重写的文件
                            app.movingImagePath = newfile;
                            app.tiff_memmap = memory_map_tiff(newfile, [], 1, true);
                            msgbox('File successfully rewritten to little-endian format.', 'Success');
                        catch rewriteErr
                            if exist('waitMsg', 'var') && isvalid(waitMsg)
                                close(waitMsg);
                            end
                            errordlg(['Failed to rewrite file: ' rewriteErr.message], 'Error');
                            return;
                        end
                    else
                        return;
                    end
                else
                    rethrow(ME);
                end
            end
            
            app.currentFrame = 1; % Ensure currentFrame is initialized to 1
            app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
            
            % 使用movingImage的第一帧作为参考图像
            app.fixedImage = app.movingImageOriginal;
            
            % 获取最大帧数
            try
                app.maxFrames = length(app.tiff_memmap.Data);
            catch
                app.maxFrames = 1;
            end
            
            % 应用初始图像
            app.movingImage = app.movingImageOriginal;
            
            % 初始化亮度范围（确保是标量）
            app.climMin = double(min(app.movingImageOriginal(:)));
            app.climMax = double(max(app.movingImageOriginal(:)));
            if isempty(app.climMin) || ~isscalar(app.climMin)
                app.climMin = 0;
            end
            if isempty(app.climMax) || ~isscalar(app.climMax)
                app.climMax = 1;
            end
            
            % Initialize contrast slider
            app.ContrastSlider.Limits = [app.climMin, app.climMax];
            app.ContrastSlider.Value = [app.climMin, app.climMax];
            
            % 初始化显示
            initializeDisplay(app);
        end

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, movingImagePath)
            basepath= fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(basepath,'libs')))
            
            % 如果提供了参数，设置路径并加载
            if nargin >= 2 && ~isempty(movingImagePath)
                app.MovingImagePathEdit.Value = movingImagePath;
                loadImages(app);
            end
        end

        % Button pushed function: MovingImageBrowseButton
        function browseMovingImage(app, event)
            [filename,path] = utils.select_file({'*.tif;*.tiff', 'TIFF Files'}, 'Select moving image');
            if filename ~= 0
                app.MovingImagePathEdit.Value = fullfile(path,filename);
                % 自动加载图像
                loadImages(app);
            end
        end

        % Button pushed function: LoadReferenceImageButton
        function loadReferenceImage(app, event)
            if isempty(app.movingImagePath)
                errordlg('Please load the movie image first!', 'Error');
                return;
            end
            
            [filename, path] = utils.select_file({'*.tif;*.tiff', 'TIFF Files'}, 'Select reference image');
            if filename ~= 0
                refImagePath = fullfile(path, filename);
                
                % 检查文件是否存在
                if ~exist(refImagePath, 'file')
                    errordlg('Reference image file does not exist!', 'Error');
                    return;
                end
                
                % 加载参考图像
                app.fixedImage = utils.tiff_read(refImagePath, 1);
                
                % 更新显示
                fixedImageAdjusted = imadjust(app.fixedImage);
                fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
                
                app.fixed_layer.CData = fixedImageRGB;
                app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
                
                if ~app.showReference
                    app.fixed_layer.Visible = 'off';
                end
            end
        end

        % Value changed function: EnableAffineModeButton
        function toggleAffineMode(app, event)
            app.affineMode = app.EnableAffineModeButton.Value;
            if app.affineMode
                app.EnableAffineModeButton.Text = 'Disable Affine Mode';
                app.ScaleXSpinner.Enable = 'on';
                app.ScaleYSpinner.Enable = 'on';
                app.RotationSpinner.Enable = 'on';
                app.ShearXSpinner.Enable = 'on';
                app.ShearYSpinner.Enable = 'on';
            else
                app.EnableAffineModeButton.Text = 'Enable Affine Mode';
                app.ScaleXSpinner.Enable = 'off';
                app.ScaleYSpinner.Enable = 'off';
                app.RotationSpinner.Enable = 'off';
                app.ShearXSpinner.Enable = 'off';
                app.ShearYSpinner.Enable = 'off';
            end
        end

        % Value changed function: RotationSpinner, ScaleXSpinner, 
        % ...and 3 other components
        function updateAffineTransform(app, event)
            app.scaleX = app.ScaleXSpinner.Value;
            app.scaleY = app.ScaleYSpinner.Value;
            app.rotation = app.RotationSpinner.Value;
            app.shearX = app.ShearXSpinner.Value;
            app.shearY = app.ShearYSpinner.Value;
            
            applyTransformation(app);
        end

        % Value changed function: XOffsetSpinner, YOffsetSpinner
        function updateOffsetFromSpinner(app, event)
            app.xoffset = app.XOffsetSpinner.Value;
            app.yoffset = app.YOffsetSpinner.Value;
            
            applyTransformation(app);
        end

        % Key press function: UIFigure
        function keyPressCallback(app, event)
            step = 1;
            
            if strcmp(event.Key, 'leftarrow')
                if app.currentFrame > 1
                    app.FrameSlider.Value = app.currentFrame - 1;
                    updateFrame(app);
                end
                return;
            elseif strcmp(event.Key, 'rightarrow')
                if app.currentFrame < app.maxFrames
                    app.FrameSlider.Value = app.currentFrame + 1;
                    updateFrame(app);
                end
                return;
            end
            
            switch event.Key
                case 'w'
                    app.yoffset = app.yoffset - step;
                case 's'
                    app.yoffset = app.yoffset + step;
                case 'a'
                    app.xoffset = app.xoffset - step;
                case 'd'
                    app.xoffset = app.xoffset + step;
            end
            applyTransformation(app);
        end

        % Button pushed function: ResetAllTransformationsButton
        function resetAll(app, event)
            resetTransformParams(app);
            applyTransformation(app);
        end

        % Value changed function: FrameSlider
        function updateFrame(app, event)
            if hasTransformationApplied(app) && app.autoSave
                [height, width] = size(app.movingImageOriginal);
                registeredImage = app.movingImageOriginal;
                
                if app.affineMode
                    tform = affine2d([app.scaleX, app.shearY, 0; ...
                        app.shearX, app.scaleY, 0; ...
                        0, 0, 1]);
                    
                    rotationRadians = deg2rad(app.rotation);
                    rotMatrix = [cos(rotationRadians), -sin(rotationRadians), 0; ...
                        sin(rotationRadians), cos(rotationRadians), 0; ...
                        0, 0, 1];
                    tform.T = tform.T * rotMatrix;
                    
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                registeredImage = circshift(registeredImage, [round(app.yoffset), round(app.xoffset)]);
                
                app.tiff_memmap.Data(app.currentFrame).channel1 = registeredImage';
            end
            
            app.currentFrame = round(app.FrameSlider.Value);
            app.FrameSpinner.Value = app.currentFrame;
            
            if ~isempty(app.movingImagePath)
                app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
                app.movingImage = app.movingImageOriginal;
                
                resetTransformParams(app);
                
                app.moving_layer.CData = app.movingImage;
                
                applyTransformation(app);
                
                clim(app.ImageAxes, [app.climMin, app.climMax]);
            end
        end

        % Value changed function: FrameSpinner
        function updateFrameFromSpinner(app, event)
            newFrame = app.FrameSpinner.Value;
            if newFrame >= 1 && newFrame <= app.maxFrames
                app.FrameSlider.Value = newFrame;
                updateFrame(app);
            else
                app.FrameSpinner.Value = app.currentFrame;
            end
        end

        % Value changing function: FrameSlider
        function updateFrameWhileDragging(app, event)
            newFrame = round(event.Value);
            if newFrame < 1 || newFrame > app.maxFrames
                return;
            end
            
            % 更新 Spinner 显示
            app.FrameSpinner.Value = newFrame;
            
            % 如果帧号没有变化，不需要更新图像
            if newFrame == app.currentFrame
                return;
            end
            
            % 如果有变换且开启自动保存，先保存当前帧
            if hasTransformationApplied(app) && app.autoSave
                [height, width] = size(app.movingImageOriginal);
                registeredImage = app.movingImageOriginal;
                
                if app.affineMode
                    tform = affine2d([app.scaleX, app.shearY, 0; ...
                        app.shearX, app.scaleY, 0; ...
                        0, 0, 1]);
                    
                    rotationRadians = deg2rad(app.rotation);
                    rotMatrix = [cos(rotationRadians), -sin(rotationRadians), 0; ...
                        sin(rotationRadians), cos(rotationRadians), 0; ...
                        0, 0, 1];
                    tform.T = tform.T * rotMatrix;
                    
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                registeredImage = circshift(registeredImage, [round(app.yoffset), round(app.xoffset)]);
                
                app.tiff_memmap.Data(app.currentFrame).channel1 = registeredImage';
            end
            
            % 更新当前帧号
            app.currentFrame = newFrame;
            
            % 加载新帧
            if ~isempty(app.movingImagePath)
                app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
                app.movingImage = app.movingImageOriginal;
                
                % 重置变换参数
                resetTransformParams(app);
                
                % 更新图像显示
                app.moving_layer.CData = app.movingImage;
                
                % 应用变换（更新标题等）
                applyTransformation(app);
                
                % 更新对比度
                clim(app.ImageAxes, [app.climMin, app.climMax]);
            end
        end

        % Button pushed function: CurrentframeButton
        function setCurrentAsReference(app, event)
            prevRefFrame = app.referenceFrameNum;
            app.referenceFrameNum = app.currentFrame;
            app.fixedImage = app.movingImageOriginal;
            
            fixedImageAdjusted = imadjust(app.fixedImage);
            fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
            
            app.fixed_layer.CData = fixedImageRGB;
            app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
            
            if ~app.showReference
                app.fixed_layer.Visible = 'off';
            end
        end

        % Value changed function: RefAlphaEdit
        function updateRefAlpha(app, event)
            newAlpha = app.RefAlphaEdit.Value;
            if newAlpha >= 0 && newAlpha <= 1
                app.refAlpha = newAlpha;
                fixedImageAdjusted = imadjust(app.fixedImage);
                app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
                
                if ~app.showReference
                    app.fixed_layer.Visible = 'off';
                end
            else
                app.RefAlphaEdit.Value = app.refAlpha;
            end
        end

        % Value changed function: AutoSaveCheckBox
        function toggleAutoSave(app, event)
            app.autoSave = app.AutoSaveCheckBox.Value;
        end

        % Button pushed function: ApplyregistrationButton
        function applyRegistration(app, event)
            if hasTransformationApplied(app)
                [height, width] = size(app.movingImageOriginal);
                registeredImage = app.movingImageOriginal;
                
                if app.affineMode
                    tform = affine2d([app.scaleX, app.shearY, 0; ...
                        app.shearX, app.scaleY, 0; ...
                        0, 0, 1]);
                    
                    rotationRadians = deg2rad(app.rotation);
                    rotMatrix = [cos(rotationRadians), -sin(rotationRadians), 0; ...
                        sin(rotationRadians), cos(rotationRadians), 0; ...
                        0, 0, 1];
                    tform.T = tform.T * rotMatrix;
                    
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                registeredImage = circshift(registeredImage, [round(app.yoffset), round(app.xoffset)]);
                
                app.tiff_memmap.Data(app.currentFrame).channel1 = registeredImage';
            end
            
            app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
            app.movingImage = app.movingImageOriginal;
            
            resetTransformParams(app);
            
            app.moving_layer.CData = app.movingImage;
            
            applyTransformation(app);
        end

        % Button pushed function: CopytransformationsButton
        function copyTransform(app, event)
            app.copiedTransform = struct('xoffset', app.xoffset, 'yoffset', app.yoffset, ...
                'scaleX', app.scaleX, 'scaleY', app.scaleY, ...
                'rotation', app.rotation, 'shearX', app.shearX, 'shearY', app.shearY);
            
            app.showCopiedTransform = true;
            
            applyTransformation(app);
        end

        % Button pushed function: PastetransformationsButton
        function pasteTransform(app, event)
            app.xoffset = app.copiedTransform.xoffset;
            app.yoffset = app.copiedTransform.yoffset;
            app.scaleX = app.copiedTransform.scaleX;
            app.scaleY = app.copiedTransform.scaleY;
            app.rotation = app.copiedTransform.rotation;
            app.shearX = app.copiedTransform.shearX;
            app.shearY = app.copiedTransform.shearY;
            
            app.XOffsetSpinner.Value = app.xoffset;
            app.YOffsetSpinner.Value = app.yoffset;
            app.ScaleXSpinner.Value = app.scaleX;
            app.ScaleYSpinner.Value = app.scaleY;
            app.RotationSpinner.Value = app.rotation;
            app.ShearXSpinner.Value = app.shearX;
            app.ShearYSpinner.Value = app.shearY;
            
            applyTransformation(app);
            
            app.mouseClickedInImage = false;
        end

        % Button pushed function: ApplytoframesButton
        function applyToAllFrames(app, event)
            startFrame = app.FramesToApplyStartEdit.Value;
            endFrame = app.FramesToApplyEndEdit.Value;
            
            if startFrame < 1 || endFrame > app.maxFrames || startFrame > endFrame
                errordlg('Please enter a valid frame range!', 'Input Error');
                return;
            end
            
            frameCount = endFrame - startFrame + 1;
            choice = questdlg(sprintf('Are you sure you want to apply the current transformation to %d frames? (Frame range: %d-%d)', ...
                frameCount, startFrame, endFrame), ...
                'Confirm Operation', 'OK', 'Cancel', 'OK');
            
            if ~strcmp(choice, 'OK')
                return;
            end
            
            currentTransform = struct('xoffset', app.xoffset, 'yoffset', app.yoffset, ...
                'scaleX', app.scaleX, 'scaleY', app.scaleY, ...
                'rotation', app.rotation, 'shearX', app.shearX, 'shearY', app.shearY);
            
            applyRegistration(app);
            
            currentFrameNum = app.currentFrame;
            
            waitMsg = waitbar(0, sprintf('Processing frame %d/%d...', startFrame, endFrame), 'Name', 'Apply transformation to specified frames');
            
            for frame = startFrame:endFrame
                if frame == currentFrameNum
                    continue;
                end
                
                waitbar((frame - startFrame) / (endFrame - startFrame + 1), waitMsg, ...
                    sprintf('正在处理帧 %d/%d...', frame, endFrame));
                
                app.currentFrame = frame;
                
                app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
                app.movingImage = app.movingImageOriginal;
                
                app.xoffset = currentTransform.xoffset;
                app.yoffset = currentTransform.yoffset;
                app.scaleX = currentTransform.scaleX;
                app.scaleY = currentTransform.scaleY;
                app.rotation = currentTransform.rotation;
                app.shearX = currentTransform.shearX;
                app.shearY = currentTransform.shearY;
                
                [height, width] = size(app.movingImageOriginal);
                registeredImage = app.movingImageOriginal;
                
                if app.affineMode
                    tform = affine2d([app.scaleX, app.shearY, 0; ...
                        app.shearX, app.scaleY, 0; ...
                        0, 0, 1]);
                    
                    rotationRadians = deg2rad(app.rotation);
                    rotMatrix = [cos(rotationRadians), -sin(rotationRadians), 0; ...
                        sin(rotationRadians), cos(rotationRadians), 0; ...
                        0, 0, 1];
                    tform.T = tform.T * rotMatrix;
                    
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                registeredImage = circshift(registeredImage, [round(app.yoffset), round(app.xoffset)]);
                
                app.tiff_memmap.Data(app.currentFrame).channel1 = registeredImage';
            end
            
            close(waitMsg);
            
            app.currentFrame = currentFrameNum;
            app.FrameSlider.Value = currentFrameNum;
            app.FrameSpinner.Value = currentFrameNum;
            
            app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
            app.movingImage = app.movingImageOriginal;
            app.moving_layer.CData = app.movingImage;
            
            resetTransformParams(app);
            applyTransformation(app);
            
            clim(app.ImageAxes, [app.climMin, app.climMax]);
        end

        % Value changed function: ContrastSlider
        function ContrastSliderValueChanged(app, event)
            app.climMin = app.ContrastSlider.Value(1);
            app.climMax = app.ContrastSlider.Value(2);
            clim(app.ImageAxes, [app.climMin, app.climMax]);
        end

        % Value changing function: ContrastSlider
        function ContrastSliderValueChanging(app, event)
            app.climMin = event.Value(1);
            app.climMax = event.Value(2);
            clim(app.ImageAxes, [app.climMin, app.climMax]);
        end

        % Value changed function: ShowRefCheckBox
        function toggleReferenceVisibility(app, event)
            app.showReference = app.ShowRefCheckBox.Value;
            
            if app.showReference
                app.fixed_layer.Visible = 'on';
            else
                app.fixed_layer.Visible = 'off';
            end
        end

        % Button pushed function: ZprojectionButton
        function useZProjection(app, event)
            if isempty(app.tiff_memmap)
                errordlg('Please load the image first!', 'Error');
                return;
            end
            
            % 计算Z投影
            frameRange = ['1:' num2str(app.maxFrames)];
            [app.tiff_mean_img, app.tiff_max_img, app.tiff_std_img] = calculateProjections(app.tiff_memmap, frameRange, false);
            
            % Let the user choose which projection to use
            choice = questdlg('Select which projection to use as reference image:', ...
                'Select Projection Type', ...
                'Mean', 'Max (Maximum)', 'STD (Standard Deviation)', 'Max (Maximum)');
            
            if isempty(choice)
                return;
            end
            
            switch choice
                case 'Mean'
                    app.fixedImage = app.tiff_mean_img;
                case 'Max (Maximum)'
                    app.fixedImage = app.tiff_max_img;
                case 'STD (Standard Deviation)'
                    app.fixedImage = app.tiff_std_img;
            end
            
            % 更新显示 - 使用更合理的对比度调整策略
            % 归一化到 [0, 1] 范围
            fixedImageNorm = double(app.fixedImage);
            fixedImageNorm = (fixedImageNorm - min(fixedImageNorm(:))) / (max(fixedImageNorm(:)) - min(fixedImageNorm(:)));
            
            % 使用百分位数进行对比度拉伸，避免过曝
            lowPercentile = prctile(fixedImageNorm(:), 1);
            highPercentile = prctile(fixedImageNorm(:), 99);
            fixedImageAdjusted = imadjust(fixedImageNorm, [lowPercentile, highPercentile], [0, 1]);
            
            fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
            
            app.fixed_layer.CData = fixedImageRGB;
            app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
            
            if ~app.showReference
                app.fixed_layer.Visible = 'off';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 926 838];
            app.UIFigure.Name = 'Manual Image Registration';
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @keyPressCallback, true);

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.PlotBoxAspectRatio = [1 1 1];
            app.ImageAxes.XLimitMethod = 'tight';
            app.ImageAxes.YLimitMethod = 'tight';
            app.ImageAxes.ZLimitMethod = 'tight';
            app.ImageAxes.GridLineWidth = 1;
            app.ImageAxes.MinorGridLineWidth = 1;
            app.ImageAxes.XTick = [];
            app.ImageAxes.YTick = [];
            app.ImageAxes.BoxStyle = 'full';
            app.ImageAxes.LineWidth = 1;
            app.ImageAxes.Box = 'on';
            app.ImageAxes.Position = [9 140 683 651];

            % Create MovingImagePathLabel
            app.MovingImagePathLabel = uilabel(app.UIFigure);
            app.MovingImagePathLabel.Position = [21 803 120 22];
            app.MovingImagePathLabel.Text = 'Movie';

            % Create MovingImagePathEdit
            app.MovingImagePathEdit = uieditfield(app.UIFigure, 'text');
            app.MovingImagePathEdit.Position = [141 805 540 20];

            % Create MovingImageBrowseButton
            app.MovingImageBrowseButton = uibutton(app.UIFigure, 'push');
            app.MovingImageBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @browseMovingImage, true);
            app.MovingImageBrowseButton.Position = [690 803 100 22];
            app.MovingImageBrowseButton.Text = 'Browse...';

            % Create FrameLabel
            app.FrameLabel = uilabel(app.UIFigure);
            app.FrameLabel.Position = [30 111 50 20];
            app.FrameLabel.Text = 'Frame:';

            % Create FrameSlider
            app.FrameSlider = uislider(app.UIFigure);
            app.FrameSlider.Limits = [1 1000];
            app.FrameSlider.MajorTicks = [];
            app.FrameSlider.ValueChangedFcn = createCallbackFcn(app, @updateFrame, true);
            app.FrameSlider.ValueChangingFcn = createCallbackFcn(app, @updateFrameWhileDragging, true);
            app.FrameSlider.MinorTicks = [];
            app.FrameSlider.Position = [109 121 300 3];
            app.FrameSlider.Value = 1;

            % Create FrameSpinner
            app.FrameSpinner = uispinner(app.UIFigure);
            app.FrameSpinner.ValueChangedFcn = createCallbackFcn(app, @updateFrameFromSpinner, true);
            app.FrameSpinner.Position = [446 110 60 22];
            app.FrameSpinner.Value = 1;

            % Create MaxFramesLabel
            app.MaxFramesLabel = uilabel(app.UIFigure);
            app.MaxFramesLabel.Position = [509 110 80 22];
            app.MaxFramesLabel.Text = '/1000';

            % Create ContrastSliderLabel
            app.ContrastSliderLabel = uilabel(app.UIFigure);
            app.ContrastSliderLabel.Position = [30 73 60 22];
            app.ContrastSliderLabel.Text = 'Contrast:';

            % Create ContrastSlider
            app.ContrastSlider = uislider(app.UIFigure, 'range');
            app.ContrastSlider.Limits = [0 2500];
            app.ContrastSlider.ValueChangedFcn = createCallbackFcn(app, @ContrastSliderValueChanged, true);
            app.ContrastSlider.ValueChangingFcn = createCallbackFcn(app, @ContrastSliderValueChanging, true);
            app.ContrastSlider.Position = [109 91 300 3];
            app.ContrastSlider.Value = [0 400];

            % Create RefAlphaLabel
            app.RefAlphaLabel = uilabel(app.UIFigure);
            app.RefAlphaLabel.Position = [130 26 60 20];
            app.RefAlphaLabel.Text = 'Ref Alpha:';

            % Create RefAlphaEdit
            app.RefAlphaEdit = uieditfield(app.UIFigure, 'numeric');
            app.RefAlphaEdit.ValueChangedFcn = createCallbackFcn(app, @updateRefAlpha, true);
            app.RefAlphaEdit.Position = [202 26 50 20];
            app.RefAlphaEdit.Value = 0.3;

            % Create ShowRefCheckBox
            app.ShowRefCheckBox = uicheckbox(app.UIFigure);
            app.ShowRefCheckBox.ValueChangedFcn = createCallbackFcn(app, @toggleReferenceVisibility, true);
            app.ShowRefCheckBox.Text = 'Show Ref';
            app.ShowRefCheckBox.Position = [31 25 100 22];
            app.ShowRefCheckBox.Value = true;

            % Create AffinePanel
            app.AffinePanel = uipanel(app.UIFigure);
            app.AffinePanel.Title = 'Affine Transformation Controls';
            app.AffinePanel.Position = [708 30 185 761];

            % Create ApplyLabel
            app.ApplyLabel = uilabel(app.AffinePanel);
            app.ApplyLabel.Position = [10 303 150 22];
            app.ApplyLabel.Text = 'Apply:';

            % Create AutoSaveCheckBox
            app.AutoSaveCheckBox = uicheckbox(app.AffinePanel);
            app.AutoSaveCheckBox.ValueChangedFcn = createCallbackFcn(app, @toggleAutoSave, true);
            app.AutoSaveCheckBox.Text = 'Auto Save';
            app.AutoSaveCheckBox.Position = [10 16 150 30];
            app.AutoSaveCheckBox.Value = true;

            % Create ResetAllTransformationsButton
            app.ResetAllTransformationsButton = uibutton(app.AffinePanel, 'push');
            app.ResetAllTransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @resetAll, true);
            app.ResetAllTransformationsButton.Position = [10 46 150 30];
            app.ResetAllTransformationsButton.Text = 'Reset All Transformations';

            % Create FramesToApplyEndEdit
            app.FramesToApplyEndEdit = uieditfield(app.AffinePanel, 'numeric');
            app.FramesToApplyEndEdit.Position = [85 92 75 20];
            app.FramesToApplyEndEdit.Value = 1000;

            % Create ToframeLabel
            app.ToframeLabel = uilabel(app.AffinePanel);
            app.ToframeLabel.Position = [10 92 75 20];
            app.ToframeLabel.Text = 'To frame:';

            % Create FramesToApplyStartEdit
            app.FramesToApplyStartEdit = uieditfield(app.AffinePanel, 'numeric');
            app.FramesToApplyStartEdit.Position = [85 122 75 20];
            app.FramesToApplyStartEdit.Value = 2;

            % Create FromframeLabel
            app.FromframeLabel = uilabel(app.AffinePanel);
            app.FromframeLabel.Position = [10 122 75 20];
            app.FromframeLabel.Text = 'From frame:';

            % Create ApplytoframesButton
            app.ApplytoframesButton = uibutton(app.AffinePanel, 'push');
            app.ApplytoframesButton.ButtonPushedFcn = createCallbackFcn(app, @applyToAllFrames, true);
            app.ApplytoframesButton.Position = [10 151 150 30];
            app.ApplytoframesButton.Text = 'Apply to frames';

            % Create ApplyregistrationButton
            app.ApplyregistrationButton = uibutton(app.AffinePanel, 'push');
            app.ApplyregistrationButton.ButtonPushedFcn = createCallbackFcn(app, @applyRegistration, true);
            app.ApplyregistrationButton.Position = [10 274 150 30];
            app.ApplyregistrationButton.Text = 'Apply registration';

            % Create PastetransformationsButton
            app.PastetransformationsButton = uibutton(app.AffinePanel, 'push');
            app.PastetransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @pasteTransform, true);
            app.PastetransformationsButton.Position = [10 190 150 30];
            app.PastetransformationsButton.Text = 'Paste transformations';

            % Create CopytransformationsButton
            app.CopytransformationsButton = uibutton(app.AffinePanel, 'push');
            app.CopytransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @copyTransform, true);
            app.CopytransformationsButton.Position = [10 230 150 30];
            app.CopytransformationsButton.Text = 'Copy transformations';

            % Create ShearYSpinner
            app.ShearYSpinner = uispinner(app.AffinePanel);
            app.ShearYSpinner.Step = 0.01;
            app.ShearYSpinner.Limits = [-0.5 0.5];
            app.ShearYSpinner.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ShearYSpinner.Position = [8 347 150 22];

            % Create ShearYLabel
            app.ShearYLabel = uilabel(app.AffinePanel);
            app.ShearYLabel.Position = [8 373 150 20];
            app.ShearYLabel.Text = 'Shear Y:';

            % Create ShearXSpinner
            app.ShearXSpinner = uispinner(app.AffinePanel);
            app.ShearXSpinner.Step = 0.01;
            app.ShearXSpinner.Limits = [-0.5 0.5];
            app.ShearXSpinner.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ShearXSpinner.Position = [8 396 150 22];

            % Create ShearXLabel
            app.ShearXLabel = uilabel(app.AffinePanel);
            app.ShearXLabel.Position = [8 422 150 20];
            app.ShearXLabel.Text = 'Shear X:';

            % Create RotationSpinner
            app.RotationSpinner = uispinner(app.AffinePanel);
            app.RotationSpinner.Step = 0.5;
            app.RotationSpinner.Limits = [-30 30];
            app.RotationSpinner.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.RotationSpinner.Position = [8 448 150 22];

            % Create RotationLabel
            app.RotationLabel = uilabel(app.AffinePanel);
            app.RotationLabel.Position = [7 474 150 20];
            app.RotationLabel.Text = 'Rotation (degrees):';

            % Create ScaleYSpinner
            app.ScaleYSpinner = uispinner(app.AffinePanel);
            app.ScaleYSpinner.Step = 0.01;
            app.ScaleYSpinner.Limits = [0.5 2];
            app.ScaleYSpinner.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ScaleYSpinner.Position = [10 496 150 22];
            app.ScaleYSpinner.Value = 1;

            % Create ScaleXSpinner
            app.ScaleXSpinner = uispinner(app.AffinePanel);
            app.ScaleXSpinner.Step = 0.01;
            app.ScaleXSpinner.Limits = [0.5 2];
            app.ScaleXSpinner.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ScaleXSpinner.Position = [10 550 150 22];
            app.ScaleXSpinner.Value = 1;

            % Create ScaleYLabel
            app.ScaleYLabel = uilabel(app.AffinePanel);
            app.ScaleYLabel.Position = [9 522 150 20];
            app.ScaleYLabel.Text = 'Scale Y:';

            % Create ScaleXLabel
            app.ScaleXLabel = uilabel(app.AffinePanel);
            app.ScaleXLabel.Position = [9 576 150 20];
            app.ScaleXLabel.Text = 'Scale X:';

            % Create EnableAffineModeButton
            app.EnableAffineModeButton = uibutton(app.AffinePanel, 'state');
            app.EnableAffineModeButton.ValueChangedFcn = createCallbackFcn(app, @toggleAffineMode, true);
            app.EnableAffineModeButton.Text = 'Enable Affine Mode';
            app.EnableAffineModeButton.Position = [9 607 150 30];

            % Create YOffsetSpinner
            app.YOffsetSpinner = uispinner(app.AffinePanel);
            app.YOffsetSpinner.ValueChangedFcn = createCallbackFcn(app, @updateOffsetFromSpinner, true);
            app.YOffsetSpinner.Position = [10 646 150 22];

            % Create YOffsetLabel
            app.YOffsetLabel = uilabel(app.AffinePanel);
            app.YOffsetLabel.Position = [10 670 150 20];
            app.YOffsetLabel.Text = 'Y Offset:';

            % Create XOffsetSpinner
            app.XOffsetSpinner = uispinner(app.AffinePanel);
            app.XOffsetSpinner.ValueChangedFcn = createCallbackFcn(app, @updateOffsetFromSpinner, true);
            app.XOffsetSpinner.Position = [10 693 150 22];

            % Create XOffsetLabel
            app.XOffsetLabel = uilabel(app.AffinePanel);
            app.XOffsetLabel.Position = [10 715 150 20];
            app.XOffsetLabel.Text = 'X Offset:';

            % Create CurrentframeButton
            app.CurrentframeButton = uibutton(app.UIFigure, 'push');
            app.CurrentframeButton.ButtonPushedFcn = createCallbackFcn(app, @setCurrentAsReference, true);
            app.CurrentframeButton.Position = [345 21 89 30];
            app.CurrentframeButton.Text = 'Current frame';

            % Create ZprojectionButton
            app.ZprojectionButton = uibutton(app.UIFigure, 'push');
            app.ZprojectionButton.ButtonPushedFcn = createCallbackFcn(app, @useZProjection, true);
            app.ZprojectionButton.Position = [447 21 108 30];
            app.ZprojectionButton.Text = 'Z projection';

            % Create LoadReferenceImageButton
            app.LoadReferenceImageButton = uibutton(app.UIFigure, 'push');
            app.LoadReferenceImageButton.ButtonPushedFcn = createCallbackFcn(app, @loadReferenceImage, true);
            app.LoadReferenceImageButton.Position = [570 20 94 30];
            app.LoadReferenceImageButton.Text = 'Load image';

            % Create SetRefLabel
            app.SetRefLabel = uilabel(app.UIFigure);
            app.SetRefLabel.Position = [295 25 45 22];
            app.SetRefLabel.Text = 'Set Ref';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ManualImageRegistration_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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