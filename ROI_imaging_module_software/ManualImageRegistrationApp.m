classdef ManualImageRegistrationApp < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ImageAxes                       matlab.ui.control.UIAxes
        FixedImagePathLabel             matlab.ui.control.Label
        FixedImagePathEdit              matlab.ui.control.EditField
        FixedImageBrowseButton          matlab.ui.control.Button
        MovingImagePathLabel            matlab.ui.control.Label
        MovingImagePathEdit             matlab.ui.control.EditField
        MovingImageBrowseButton         matlab.ui.control.Button
        LoadImagesButton                matlab.ui.control.Button
        FrameLabel                      matlab.ui.control.Label
        FrameSlider                     matlab.ui.control.Slider
        FrameEdit                       matlab.ui.control.NumericEditField
        MaxFramesLabel                  matlab.ui.control.Label
        RefAlphaLabel                   matlab.ui.control.Label
        RefAlphaEdit                    matlab.ui.control.NumericEditField
        ShowReferenceCheckBox           matlab.ui.control.CheckBox
        CLimMinLabel                    matlab.ui.control.Label
        CLimMinEdit                     matlab.ui.control.NumericEditField
        CLimMaxLabel                    matlab.ui.control.Label
        CLimMaxEdit                     matlab.ui.control.NumericEditField
        AffinePanel                     matlab.ui.container.Panel
        EnableAffineModeButton          matlab.ui.control.StateButton
        ScaleXLabel                     matlab.ui.control.Label
        ScaleXSlider                    matlab.ui.control.Slider
        ScaleYLabel                     matlab.ui.control.Label
        ScaleYSlider                    matlab.ui.control.Slider
        RotationLabel                   matlab.ui.control.Label
        RotationSlider                  matlab.ui.control.Slider
        ShearXLabel                     matlab.ui.control.Label
        ShearXSlider                    matlab.ui.control.Slider
        ShearYLabel                     matlab.ui.control.Label
        ShearYSlider                    matlab.ui.control.Slider
        TransformationsLabel            matlab.ui.control.Label
        CopyTransformationsButton       matlab.ui.control.Button
        PasteTransformationsButton      matlab.ui.control.Button
        ApplyRegistrationButton         matlab.ui.control.Button
        ApplytoFramesButton             matlab.ui.control.Button
        FromframeLabel                  matlab.ui.control.Label
        FramesToApplyStartEdit          matlab.ui.control.NumericEditField
        ToframeLabel                    matlab.ui.control.Label
        FramesToApplyEndEdit            matlab.ui.control.NumericEditField
        ResetAllTransformationsButton   matlab.ui.control.Button
        AutoSaveCheckBox                matlab.ui.control.CheckBox
        SetCurrentasReferenceButton     matlab.ui.control.Button
        UseZProjectionButton            matlab.ui.control.Button
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
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app, fixedImagePath, movingImagePath)
            basepath= fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(basepath,'libs')))
            
            % 如果提供了参数，设置路径并加载
            if nargin >= 3 && ~isempty(movingImagePath)
                app.FixedImagePathEdit.Value = fixedImagePath;
                app.MovingImagePathEdit.Value = movingImagePath;
                loadImages(app);
            elseif nargin >= 2 && ~isempty(fixedImagePath)
                app.MovingImagePathEdit.Value = fixedImagePath;
            end
        end
        
        % 浏览选择固定图像
        function browseFixedImage(app, ~)
            filepath = select_file({'*.tif;*.tiff', 'TIFF Files'}, '选择参考图像');
            if ~isempty(filepath)
                app.FixedImagePathEdit.Value = filepath;
            end
        end
        
        % 浏览选择运动图像
        function browseMovingImage(app, ~)
            filepath = select_file({'*.tif;*.tiff', 'TIFF Files'}, '选择运动图像');
            if ~isempty(filepath)
                app.MovingImagePathEdit.Value = filepath;
            end
        end
        
        % 加载图像
        function loadImages(app, ~)
            fixedImagePath = app.FixedImagePathEdit.Value;
            movingImagePath = app.MovingImagePathEdit.Value;
            
            % 检查必须提供运动图像路径
            if isempty(movingImagePath)
                errordlg('请提供运动图像路径！', '错误');
                return;
            end
            
            % 检查文件是否存在
            if ~isempty(fixedImagePath) && ~exist(fixedImagePath, 'file')
                errordlg('参考图像文件不存在！', '错误');
                return;
            end
            
            if ~exist(movingImagePath, 'file')
                errordlg('运动图像文件不存在！', '错误');
                return;
            end
            
            % Load fixed image (如果fixedImagePath为空，将在加载moving image后设置)
            if ~isempty(fixedImagePath)
                app.fixedImage = tiff_read(fixedImagePath, 1);
            end
            
            % Load moving image
            app.movingImagePath = movingImagePath;
            app.tiff_memmap = memory_map_tiff(app.movingImagePath,[],1,false);
            app.currentFrame = 1; % Ensure currentFrame is initialized to 1
            app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
            
            % 如果没有提供fixedImagePath，使用movingImage的第一帧
            if isempty(fixedImagePath)
                app.fixedImage = app.movingImageOriginal;
            end
            
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
            app.CLimMinEdit.Value = app.climMin;
            app.CLimMaxEdit.Value = app.climMax;
            
            % 初始化显示
            initializeDisplay(app);
        end
        
        function initializeDisplay(app)
            % 先显示移动图像（灰度）
            app.moving_layer = imshow(app.movingImage, [], 'Parent', app.ImageAxes, ...
                'Border', 'tight');
            clim(app.ImageAxes, [app.climMin, app.climMax]);
            
            hold(app.ImageAxes, 'on');
            
            % 再显示固定图像为绿色
            fixedImageAdjusted = imadjust(app.fixedImage);
            fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
            
            app.fixed_layer = imshow(fixedImageRGB, 'Parent', app.ImageAxes, ...
                'Border', 'tight');
            app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
            
            hold(app.ImageAxes, 'off');
            
            % Store initial position
            app.initialXData = app.moving_layer.XData;
            app.initialYData = app.moving_layer.YData;
            
            % Add title to display current offset
            title(app.ImageAxes, ['Offset: x=', num2str(app.xoffset), ', y=', num2str(app.yoffset)]);
            
            % Set up mouse callbacks
            app.ImageAxes.ButtonDownFcn = @app.startDrag;
            app.UIFigure.WindowButtonUpFcn = @app.endDrag;
            app.UIFigure.WindowButtonMotionFcn = @app.dragImage;
            
            % Update UI elements
            app.FrameSlider.Limits = [1, app.maxFrames];
            app.FrameSlider.Value = app.currentFrame;
            app.FrameEdit.Value = app.currentFrame;
            app.MaxFramesLabel.Text = ['/', num2str(app.maxFrames)];
            app.RefAlphaEdit.Value = app.refAlpha;
            app.ShowReferenceCheckBox.Value = app.showReference;
            app.FramesToApplyStartEdit.Value = app.currentFrame + 1;
            app.FramesToApplyEndEdit.Value = app.maxFrames;
            app.AutoSaveCheckBox.Value = app.autoSave;
            
            % Disable affine sliders initially
            app.ScaleXSlider.Enable = 'off';
            app.ScaleYSlider.Enable = 'off';
            app.RotationSlider.Enable = 'off';
            app.ShearXSlider.Enable = 'off';
            app.ShearYSlider.Enable = 'off';
        end
        
        % Toggle affine mode
        function toggleAffineMode(app, ~)
            app.affineMode = app.EnableAffineModeButton.Value;
            if app.affineMode
                app.EnableAffineModeButton.Text = 'Disable Affine Mode';
                app.ScaleXSlider.Enable = 'on';
                app.ScaleYSlider.Enable = 'on';
                app.RotationSlider.Enable = 'on';
                app.ShearXSlider.Enable = 'on';
                app.ShearYSlider.Enable = 'on';
            else
                app.EnableAffineModeButton.Text = 'Enable Affine Mode';
                app.ScaleXSlider.Enable = 'off';
                app.ScaleYSlider.Enable = 'off';
                app.RotationSlider.Enable = 'off';
                app.ShearXSlider.Enable = 'off';
                app.ShearYSlider.Enable = 'off';
            end
        end
        
        % Update affine transform
        function updateAffineTransform(app, ~)
            app.scaleX = app.ScaleXSlider.Value;
            app.scaleY = app.ScaleYSlider.Value;
            app.rotation = app.RotationSlider.Value;
            app.shearX = app.ShearXSlider.Value;
            app.shearY = app.ShearYSlider.Value;
            
            applyTransformation(app);
        end
        
        % Key press callback
        function keyPressCallback(app, ~, event)
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
        
        % Start drag
        function startDrag(app, ~, ~)
            cursorPos = get(app.ImageAxes, 'CurrentPoint');
            app.dragStartX = cursorPos(1, 1);
            app.dragStartY = cursorPos(1, 2);
            
            app.dragStartXoffset = app.xoffset;
            app.dragStartYoffset = app.yoffset;
            
            app.mouseClickedInImage = isInImage(app, app.dragStartX, app.dragStartY);
            
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
            if app.isDragging
                cursorPos = get(app.ImageAxes, 'CurrentPoint');
                currentX = cursorPos(1, 1);
                currentY = cursorPos(1, 2);
                
                dx = currentX - app.dragStartX;
                dy = currentY - app.dragStartY;
                
                app.xoffset = app.dragStartXoffset + dx;
                app.yoffset = app.dragStartYoffset + dy;
                
                applyTransformation(app);
            end
        end
        
        function result = isInImage(app, x, y)
            imgWidth = size(app.fixedImage, 2);
            imgHeight = size(app.fixedImage, 1);
            
            result = (x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight);
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
            
            drawnow;
        end
        
        function resetTransformParams(app)
            app.xoffset = 0;
            app.yoffset = 0;
            app.scaleX = 1.0;
            app.scaleY = 1.0;
            app.rotation = 0;
            app.shearX = 0;
            app.shearY = 0;
            
            app.ScaleXSlider.Value = 1.0;
            app.ScaleYSlider.Value = 1.0;
            app.RotationSlider.Value = 0;
            app.ShearXSlider.Value = 0;
            app.ShearYSlider.Value = 0;
            
            app.dragStartX = 0;
            app.dragStartY = 0;
            app.dragStartXoffset = 0;
            app.dragStartYoffset = 0;
            app.isDragging = false;
        end
        
        function resetAll(app, ~)
            resetTransformParams(app);
            applyTransformation(app);
        end
        
        function updateFrame(app, ~)
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
            app.FrameEdit.Value = app.currentFrame;
            
            if ~isempty(app.movingImagePath)
                app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
                app.movingImage = app.movingImageOriginal;
                
                resetTransformParams(app);
                
                app.moving_layer.CData = app.movingImage;
                
                applyTransformation(app);
                
                clim(app.ImageAxes, [app.climMin, app.climMax]);
            end
        end
        
        function updateFrameFromEdit(app, ~)
            newFrame = app.FrameEdit.Value;
            if newFrame >= 1 && newFrame <= app.maxFrames
                app.FrameSlider.Value = newFrame;
                updateFrame(app);
            else
                app.FrameEdit.Value = app.currentFrame;
            end
        end
        
        function setCurrentAsReference(app, ~)
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
        
        function updateRefAlpha(app, ~)
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
        
        function toggleAutoSave(app, ~)
            app.autoSave = app.AutoSaveCheckBox.Value;
        end
        
        function result = hasTransformationApplied(app)
            result = app.xoffset ~= 0 || app.yoffset ~= 0 || ...
                app.scaleX ~= 1.0 || app.scaleY ~= 1.0 || ...
                app.rotation ~= 0 || app.shearX ~= 0 || app.shearY ~= 0;
        end
        
        function applyRegistration(app, ~)
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
        
        function copyTransform(app, ~)
            app.copiedTransform = struct('xoffset', app.xoffset, 'yoffset', app.yoffset, ...
                'scaleX', app.scaleX, 'scaleY', app.scaleY, ...
                'rotation', app.rotation, 'shearX', app.shearX, 'shearY', app.shearY);
            
            app.showCopiedTransform = true;
            
            applyTransformation(app);
        end
        
        function pasteTransform(app, ~)
            app.xoffset = app.copiedTransform.xoffset;
            app.yoffset = app.copiedTransform.yoffset;
            app.scaleX = app.copiedTransform.scaleX;
            app.scaleY = app.copiedTransform.scaleY;
            app.rotation = app.copiedTransform.rotation;
            app.shearX = app.copiedTransform.shearX;
            app.shearY = app.copiedTransform.shearY;
            
            app.ScaleXSlider.Value = app.scaleX;
            app.ScaleYSlider.Value = app.scaleY;
            app.RotationSlider.Value = app.rotation;
            app.ShearXSlider.Value = app.shearX;
            app.ShearYSlider.Value = app.shearY;
            
            applyTransformation(app);
            
            app.mouseClickedInImage = false;
        end
        
        function applyToAllFrames(app, ~)
            startFrame = app.FramesToApplyStartEdit.Value;
            endFrame = app.FramesToApplyEndEdit.Value;
            
            if startFrame < 1 || endFrame > app.maxFrames || startFrame > endFrame
                errordlg('请输入有效的帧范围！', '输入错误');
                return;
            end
            
            frameCount = endFrame - startFrame + 1;
            choice = questdlg(sprintf('确定要将当前变换应用到 %d 帧吗？（帧范围：%d-%d）', ...
                frameCount, startFrame, endFrame), ...
                '确认操作', '确定', '取消', '确定');
            
            if ~strcmp(choice, '确定')
                return;
            end
            
            currentTransform = struct('xoffset', app.xoffset, 'yoffset', app.yoffset, ...
                'scaleX', app.scaleX, 'scaleY', app.scaleY, ...
                'rotation', app.rotation, 'shearX', app.shearX, 'shearY', app.shearY);
            
            applyRegistration(app);
            
            currentFrameNum = app.currentFrame;
            
            waitMsg = waitbar(0, sprintf('正在处理帧 %d/%d...', startFrame, endFrame), 'Name', '应用变换到指定帧');
            
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
            app.FrameEdit.Value = currentFrameNum;
            
            app.movingImageOriginal = app.tiff_memmap.Data(app.currentFrame).channel1';
            app.movingImage = app.movingImageOriginal;
            app.moving_layer.CData = app.movingImage;
            
            resetTransformParams(app);
            applyTransformation(app);
            
            clim(app.ImageAxes, [app.climMin, app.climMax]);
        end
        
        function updateClim(app, ~)
            if app.CLimMinEdit.Value >= app.CLimMaxEdit.Value
                app.CLimMinEdit.Value = min(app.movingImageOriginal(:));
                app.CLimMaxEdit.Value = max(app.movingImageOriginal(:));
                warndlg('CLim Min 必须小于 CLim Max', '无效输入');
                return;
            end
            
            app.climMin = app.CLimMinEdit.Value;
            app.climMax = app.CLimMaxEdit.Value;
            
            clim(app.ImageAxes, [app.climMin, app.climMax]);
        end
        
        function toggleReferenceVisibility(app, ~)
            app.showReference = app.ShowReferenceCheckBox.Value;
            
            if app.showReference
                app.fixed_layer.Visible = 'on';
            else
                app.fixed_layer.Visible = 'off';
            end
        end
        
        function useZProjection(app, ~)
            if isempty(app.tiff_memmap)
                errordlg('请先加载图像！', '错误');
                return;
            end
            
            % 计算Z投影
            frameRange = ['1:' num2str(app.maxFrames)];
            [app.tiff_mean_img, app.tiff_max_img, app.tiff_std_img] = calculateProjections(app.tiff_memmap, frameRange, false);
            
            % 让用户选择使用哪种投影
            choice = questdlg('选择使用哪种投影作为参考图像:', ...
                '选择投影类型', ...
                'Mean (平均)', 'Max (最大)', 'STD (标准差)', 'Max (最大)');
            
            if isempty(choice)
                return;
            end
            
            switch choice
                case 'Mean (平均)'
                    app.fixedImage = app.tiff_mean_img;
                case 'Max (最大)'
                    app.fixedImage = app.tiff_max_img;
                case 'STD (标准差)'
                    app.fixedImage = app.tiff_std_img;
            end
            
            % 更新显示
            fixedImageAdjusted = imadjust(app.fixedImage);
            fixedImageRGB = cat(3, zeros(size(app.fixedImage)), fixedImageAdjusted, zeros(size(app.fixedImage)));
            
            app.fixed_layer.CData = fixedImageRGB;
            app.fixed_layer.AlphaData = fixedImageAdjusted * app.refAlpha;
            
            if ~app.showReference
                app.fixed_layer.Visible = 'off';
            end
            
            msgbox(['已使用 ' choice ' 投影作为参考图像'], '成功');
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 926 880];
            app.UIFigure.Name = 'Manual Image Registration';
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @keyPressCallback, true);
            
            % Create FixedImagePathLabel
            app.FixedImagePathLabel = uilabel(app.UIFigure);
            app.FixedImagePathLabel.Position = [20 840 120 20];
            app.FixedImagePathLabel.Text = '参考图像路径(可选):';
            
            % Create FixedImagePathEdit
            app.FixedImagePathEdit = uieditfield(app.UIFigure, 'text');
            app.FixedImagePathEdit.Position = [140 840 450 20];
            
            % Create FixedImageBrowseButton
            app.FixedImageBrowseButton = uibutton(app.UIFigure, 'push');
            app.FixedImageBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @browseFixedImage, true);
            app.FixedImageBrowseButton.Position = [600 840 80 22];
            app.FixedImageBrowseButton.Text = '浏览...';
            
            % Create MovingImagePathLabel
            app.MovingImagePathLabel = uilabel(app.UIFigure);
            app.MovingImagePathLabel.Position = [20 810 120 20];
            app.MovingImagePathLabel.Text = '运动图像路径(必选):';
            
            % Create MovingImagePathEdit
            app.MovingImagePathEdit = uieditfield(app.UIFigure, 'text');
            app.MovingImagePathEdit.Position = [140 810 450 20];
            
            % Create MovingImageBrowseButton
            app.MovingImageBrowseButton = uibutton(app.UIFigure, 'push');
            app.MovingImageBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @browseMovingImage, true);
            app.MovingImageBrowseButton.Position = [600 810 80 22];
            app.MovingImageBrowseButton.Text = '浏览...';
            
            % Create LoadImagesButton
            app.LoadImagesButton = uibutton(app.UIFigure, 'push');
            app.LoadImagesButton.ButtonPushedFcn = createCallbackFcn(app, @loadImages, true);
            app.LoadImagesButton.Position = [690 825 100 30];
            app.LoadImagesButton.Text = '加载图像';
            app.LoadImagesButton.FontWeight = 'bold';
            
            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.Position = [46 121 648 670];
            
            % Create FrameLabel
            app.FrameLabel = uilabel(app.UIFigure);
            app.FrameLabel.Position = [80 91 50 20];
            app.FrameLabel.Text = 'Frame:';
            
            % Create FrameSlider
            app.FrameSlider = uislider(app.UIFigure);
            app.FrameSlider.Limits = [1 1000];
            app.FrameSlider.ValueChangedFcn = createCallbackFcn(app, @updateFrame, true);
            app.FrameSlider.Position = [130 91 300 20];
            app.FrameSlider.Value = 1;
            
            % Create FrameEdit
            app.FrameEdit = uieditfield(app.UIFigure, 'numeric');
            app.FrameEdit.ValueChangedFcn = createCallbackFcn(app, @updateFrameFromEdit, true);
            app.FrameEdit.Position = [450 91 50 20];
            app.FrameEdit.Value = 1;
            
            % Create MaxFramesLabel
            app.MaxFramesLabel = uilabel(app.UIFigure);
            app.MaxFramesLabel.Position = [505 91 45 20];
            app.MaxFramesLabel.Text = '/1';
            
            % Create RefAlphaLabel
            app.RefAlphaLabel = uilabel(app.UIFigure);
            app.RefAlphaLabel.Position = [560 91 60 20];
            app.RefAlphaLabel.Text = 'Ref Alpha:';
            
            % Create RefAlphaEdit
            app.RefAlphaEdit = uieditfield(app.UIFigure, 'numeric');
            app.RefAlphaEdit.ValueChangedFcn = createCallbackFcn(app, @updateRefAlpha, true);
            app.RefAlphaEdit.Position = [625 91 50 20];
            app.RefAlphaEdit.Value = 0.3;
            
            % Create ShowReferenceCheckBox
            app.ShowReferenceCheckBox = uicheckbox(app.UIFigure);
            app.ShowReferenceCheckBox.ValueChangedFcn = createCallbackFcn(app, @toggleReferenceVisibility, true);
            app.ShowReferenceCheckBox.Text = 'Show Reference';
            app.ShowReferenceCheckBox.Position = [685 91 100 20];
            app.ShowReferenceCheckBox.Value = true;
            
            % Create CLimMinLabel
            app.CLimMinLabel = uilabel(app.UIFigure);
            app.CLimMinLabel.Position = [80 63 50 20];
            app.CLimMinLabel.Text = 'CLim Min:';
            
            % Create CLimMinEdit
            app.CLimMinEdit = uieditfield(app.UIFigure, 'numeric');
            app.CLimMinEdit.ValueChangedFcn = createCallbackFcn(app, @updateClim, true);
            app.CLimMinEdit.Position = [130 65 50 20];
            
            % Create CLimMaxLabel
            app.CLimMaxLabel = uilabel(app.UIFigure);
            app.CLimMaxLabel.Position = [200 63 57 20];
            app.CLimMaxLabel.Text = 'CLim Max:';
            
            % Create CLimMaxEdit
            app.CLimMaxEdit = uieditfield(app.UIFigure, 'numeric');
            app.CLimMaxEdit.ValueChangedFcn = createCallbackFcn(app, @updateClim, true);
            app.CLimMaxEdit.Position = [254 65 50 20];
            
            % Create AffinePanel
            app.AffinePanel = uipanel(app.UIFigure);
            app.AffinePanel.Title = 'Affine Transformation Controls';
            app.AffinePanel.Position = [720 121 185 670];
            
            % Create EnableAffineModeButton
            app.EnableAffineModeButton = uibutton(app.AffinePanel, 'state');
            app.EnableAffineModeButton.ValueChangedFcn = createCallbackFcn(app, @toggleAffineMode, true);
            app.EnableAffineModeButton.Text = 'Enable Affine Mode';
            app.EnableAffineModeButton.Position = [10 550 150 30];
            
            % Create ScaleXLabel
            app.ScaleXLabel = uilabel(app.AffinePanel);
            app.ScaleXLabel.Position = [10 510 150 20];
            app.ScaleXLabel.Text = 'Scale X:';
            
            % Create ScaleXSlider
            app.ScaleXSlider = uislider(app.AffinePanel);
            app.ScaleXSlider.Limits = [0.5 2];
            app.ScaleXSlider.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ScaleXSlider.Position = [10 490 150 20];
            app.ScaleXSlider.Value = 1;
            
            % Create ScaleYLabel
            app.ScaleYLabel = uilabel(app.AffinePanel);
            app.ScaleYLabel.Position = [10 460 150 20];
            app.ScaleYLabel.Text = 'Scale Y:';
            
            % Create ScaleYSlider
            app.ScaleYSlider = uislider(app.AffinePanel);
            app.ScaleYSlider.Limits = [0.5 2];
            app.ScaleYSlider.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ScaleYSlider.Position = [10 440 150 20];
            app.ScaleYSlider.Value = 1;
            
            % Create RotationLabel
            app.RotationLabel = uilabel(app.AffinePanel);
            app.RotationLabel.Position = [10 410 150 20];
            app.RotationLabel.Text = 'Rotation (degrees):';
            
            % Create RotationSlider
            app.RotationSlider = uislider(app.AffinePanel);
            app.RotationSlider.Limits = [-30 30];
            app.RotationSlider.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.RotationSlider.Position = [10 390 150 20];
            
            % Create ShearXLabel
            app.ShearXLabel = uilabel(app.AffinePanel);
            app.ShearXLabel.Position = [10 360 150 20];
            app.ShearXLabel.Text = 'Shear X:';
            
            % Create ShearXSlider
            app.ShearXSlider = uislider(app.AffinePanel);
            app.ShearXSlider.Limits = [-0.5 0.5];
            app.ShearXSlider.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ShearXSlider.Position = [10 340 150 20];
            
            % Create ShearYLabel
            app.ShearYLabel = uilabel(app.AffinePanel);
            app.ShearYLabel.Position = [10 310 150 20];
            app.ShearYLabel.Text = 'Shear Y:';
            
            % Create ShearYSlider
            app.ShearYSlider = uislider(app.AffinePanel);
            app.ShearYSlider.Limits = [-0.5 0.5];
            app.ShearYSlider.ValueChangedFcn = createCallbackFcn(app, @updateAffineTransform, true);
            app.ShearYSlider.Position = [10 290 150 20];
            
            % Create TransformationsLabel
            app.TransformationsLabel = uilabel(app.AffinePanel);
            app.TransformationsLabel.Position = [10 260 150 20];
            app.TransformationsLabel.Text = 'Transformations:';
            
            % Create CopyTransformationsButton
            app.CopyTransformationsButton = uibutton(app.AffinePanel, 'push');
            app.CopyTransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @copyTransform, true);
            app.CopyTransformationsButton.Position = [10 230 150 30];
            app.CopyTransformationsButton.Text = 'Copy Transformations';
            
            % Create PasteTransformationsButton
            app.PasteTransformationsButton = uibutton(app.AffinePanel, 'push');
            app.PasteTransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @pasteTransform, true);
            app.PasteTransformationsButton.Position = [10 190 150 30];
            app.PasteTransformationsButton.Text = 'Paste Transformations';
            
            % Create ApplyRegistrationButton
            app.ApplyRegistrationButton = uibutton(app.AffinePanel, 'push');
            app.ApplyRegistrationButton.ButtonPushedFcn = createCallbackFcn(app, @applyRegistration, true);
            app.ApplyRegistrationButton.Position = [10 150 150 30];
            app.ApplyRegistrationButton.Text = 'Apply Registration';
            
            % Create ApplytoFramesButton
            app.ApplytoFramesButton = uibutton(app.AffinePanel, 'push');
            app.ApplytoFramesButton.ButtonPushedFcn = createCallbackFcn(app, @applyToAllFrames, true);
            app.ApplytoFramesButton.Position = [10 110 150 30];
            app.ApplytoFramesButton.Text = 'Apply to Frames';
            
            % Create FromframeLabel
            app.FromframeLabel = uilabel(app.AffinePanel);
            app.FromframeLabel.Position = [10 80 75 20];
            app.FromframeLabel.Text = 'From frame:';
            
            % Create FramesToApplyStartEdit
            app.FramesToApplyStartEdit = uieditfield(app.AffinePanel, 'numeric');
            app.FramesToApplyStartEdit.Position = [85 80 75 20];
            app.FramesToApplyStartEdit.Value = 2;
            
            % Create ToframeLabel
            app.ToframeLabel = uilabel(app.AffinePanel);
            app.ToframeLabel.Position = [10 50 75 20];
            app.ToframeLabel.Text = 'To frame:';
            
            % Create FramesToApplyEndEdit
            app.FramesToApplyEndEdit = uieditfield(app.AffinePanel, 'numeric');
            app.FramesToApplyEndEdit.Position = [85 50 75 20];
            app.FramesToApplyEndEdit.Value = 1;
            
            % Create ResetAllTransformationsButton
            app.ResetAllTransformationsButton = uibutton(app.AffinePanel, 'push');
            app.ResetAllTransformationsButton.ButtonPushedFcn = createCallbackFcn(app, @resetAll, true);
            app.ResetAllTransformationsButton.Position = [10 20 150 30];
            app.ResetAllTransformationsButton.Text = 'Reset All Transformations';
            
            % Create AutoSaveCheckBox
            app.AutoSaveCheckBox = uicheckbox(app.AffinePanel);
            app.AutoSaveCheckBox.ValueChangedFcn = createCallbackFcn(app, @toggleAutoSave, true);
            app.AutoSaveCheckBox.Text = 'Auto Save';
            app.AutoSaveCheckBox.Position = [10 -10 150 30]; % Adjust if needed
            app.AutoSaveCheckBox.Value = true;
            
            % Create SetCurrentasReferenceButton
            app.SetCurrentasReferenceButton = uibutton(app.AffinePanel, 'push');
            app.SetCurrentasReferenceButton.ButtonPushedFcn = createCallbackFcn(app, @setCurrentAsReference, true);
            app.SetCurrentasReferenceButton.Position = [10 -50 150 30]; % Adjust if needed
            app.SetCurrentasReferenceButton.Text = 'Set Current as Reference';
            
            % Create UseZProjectionButton
            app.UseZProjectionButton = uibutton(app.AffinePanel, 'push');
            app.UseZProjectionButton.ButtonPushedFcn = createCallbackFcn(app, @useZProjection, true);
            app.UseZProjectionButton.Position = [10 -90 150 30];
            app.UseZProjectionButton.Text = 'Use Z Projection';
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = ManualImageRegistrationApp(varargin)
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