classdef ManualImageRegistration < handle
    % ManualImageRegistration - Class for manual image registration with interactive controls
    % Supports both translation and affine transformation for non-rigid registration
    
    properties
        % Images
        fixedImage
        movingImage
        movingImageOriginal
        movingImagePath    % 存储移动图像路径
        tiff_memmap = [];
        % Frame control
        currentFrame = 1   % 当前帧号，默认为第2帧
        frameSlider        % 帧滑块控件
        frameText          % 显示当前帧号
        frameSpinner       % 帧数的Spinner控件
        maxFrames = 1      % 最大帧数
        
        % Display elements
        fig
        ax
        fixed_layer
        moving_layer
        controlPanel
        
        % Alpha control
        refAlpha = 0.3     % 参考图像的Alpha值，默认为0.3
        alphaSpinner       % Alpha值的Spinner控件
        
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
        rotation = 0  % in degrees
        shearX = 0
        shearY = 0
        
        % UI controls
        scaleXSlider
        scaleYSlider
        rotationSlider
        shearXSlider
        shearYSlider
        
        % Initial transformation
        initialTranslation = [0, 0]
        
        % Transformation mode
        affineMode = false
        
        % 存储复制的变换参数
        copiedTransform = struct('xoffset', 0, 'yoffset', 0, ...
            'scaleX', 1.0, 'scaleY', 1.0, ...
            'rotation', 0, 'shearX', 0, 'shearY', 0)
        
        % 新增属性：自动保存
        autoSave = true
        
        % 新增属性：应用到后续帧的范围
        framesToApplyStart
        framesToApplyEnd
        
        % 新增属性：显示copied transform信息
        showCopiedTransform = false
        
        % 新增属性：亮度范围控制
        climMin
        climMax
        climMinControl
        climMaxControl
        
        % 新增属性：参考帧号
        referenceFrameNum = 1
        
        % 新增属性：显示参考图层的复选框
        showReferenceCheckbox
        showReference = true % 默认显示参考图层
    end
    
    methods
        function obj = ManualImageRegistration(fixedImagePath, movingImagePath)
            addpath(genpath('E:\SynologyDrive\Member-Jixiong-Su\Code\1_project\Tiff_split\libs'))
            
            % 如果没有提供参数，显示文件选择对话框
            if nargin == 0
                [fixedImagePath, movingImagePath] = obj.showStartupDialog();
                if isempty(movingImagePath)  % 用户取消了选择
                    delete(obj);  % 删除当前对象实例
                    return;
                end
            elseif nargin >= 2 && ~isempty(movingImagePath)
                % movingImagePath = movingImagePath;
                
            else
                movingImagePath = fixedImagePath; % Use fixed image as moving image
            end
            
            
            % Load fixed image (如果fixedImagePath为空，将在加载moving image后设置)
            if ~isempty(fixedImagePath)
                obj.fixedImage = tiff_read(fixedImagePath, 1);
            end
            
            % If movingImagePath is provided, load it
            if ~isempty(movingImagePath)
                obj.movingImagePath = movingImagePath;
                obj.tiff_memmap = memory_map_tiff(obj.movingImagePath,[],1,false);
                obj.currentFrame = 1;  % Ensure currentFrame is initialized to 1
                obj.movingImageOriginal = obj.tiff_memmap.Data(obj.currentFrame).channel1';
                
                % 如果没有提供fixedImagePath，使用movingImage的第一帧
                if isempty(fixedImagePath)
                    obj.fixedImage = obj.movingImageOriginal;
                end
                
                % 获取最大帧数
                try
                    obj.maxFrames = length(obj.tiff_memmap.Data);
                catch
                    obj.maxFrames = 1;
                end
                
                % 应用初始图像
                obj.movingImage = obj.movingImageOriginal;
                
                % 初始化亮度范围
                obj.climMin = min(obj.movingImageOriginal(:));
                obj.climMax = max(obj.movingImageOriginal(:));
                
                % 初始化GUI
                obj.initializeGUI();
            end
        end
        
        function [fixedPath, movingPath] = showStartupDialog(obj)
            % 创建对话框窗口
            dlg = dialog('Name', '图像配准参数', 'Position', [300, 300, 400, 200]);
            
            % 参考图像路径输入
            uicontrol('Parent', dlg, 'Style', 'text', 'String', '参考图像路径(可选):', ...
                'Position', [20, 150, 120, 20], 'HorizontalAlignment', 'left');
            refPathEdit = uicontrol('Parent', dlg, 'Style', 'edit', ...
                'Position', [140, 150, 180, 20]);
            refBrowseBtn = uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', '浏览...', ...
                'Position', [330, 150, 50, 20], 'Callback', @(src,event) browseFile(refPathEdit));
            
            % 运动图像路径输入(必选)
            uicontrol('Parent', dlg, 'Style', 'text', 'String', '运动图像路径(必选):', ...
                'Position', [20, 110, 120, 20], 'HorizontalAlignment', 'left');
            movPathEdit = uicontrol('Parent', dlg, 'Style', 'edit', ...
                'Position', [140, 110, 180, 20]);
            movBrowseBtn = uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', '浏览...', ...
                'Position', [330, 110, 50, 20], 'Callback', @(src,event) browseFile(movPathEdit));
            
            % 提示信息
            uicontrol('Parent', dlg, 'Style', 'text', ...
                'String', '如不提供参考图像路径，将使用运动图像的第一帧作为参考', ...
                'Position', [20, 70, 360, 20], 'HorizontalAlignment', 'center');
            
            % 确定和取消按钮
            uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', '确定', ...
                'Position', [100, 30, 80, 30], 'Callback', @confirmSelection);
            uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', '取消', ...
                'Position', [220, 30, 80, 30], 'Callback', @cancelSelection);
            
            % 初始化返回值
            fixedPath = '';
            movingPath = '';
            
            % 等待用户做出选择
            uiwait(dlg);
            
            % 嵌套函数：浏览文件
            function browseFile(editField)
                [filename, pathname] = uigetfile({'*.tif;*.tiff', 'TIFF Files (*.tif, *.tiff)'; ...
                    '*.*', 'All Files (*.*)'});
                if filename ~= 0
                    fullpath = fullfile(pathname, filename);
                    editField.String = fullpath;
                end
            end
            
            % 嵌套函数：确认选择
            function confirmSelection(~, ~)
                % 获取用户输入的路径
                fixedPath = refPathEdit.String;
                movingPath = movPathEdit.String;
                disp(movingPath);
                
                % 检查运动图像路径是否填写
                if isempty(movingPath)
                    errordlg('请提供运动图像路径！', '错误');
                    return;
                end
                
                % 检查路径是否存在
                if ~isempty(fixedPath) && ~exist(fixedPath, 'file')
                    errordlg('参考图像路径不存在！', '错误');
                    return;
                end
                
                if ~exist(movingPath, 'file')
                    errordlg('运动图像路径不存在！', '错误');
                    return;
                end
                
                % 关闭对话框
                delete(dlg);
            end
            
            % 嵌套函数：取消选择
            function cancelSelection(~, ~)
                % 清空路径
                fixedPath = '';
                movingPath = '';
                % 关闭对话框
                delete(dlg);
            end
        end
        
        function initializeGUI(obj)
            % Create main figure
            obj.fig = figure('KeyPressFcn', @obj.keyPressCallback, ...
                'Name', 'Manual Image Registration', 'MenuBar','figure', 'Toolbar','none', ...
                'Position', [0 0 926 802], ...
                'NumberTitle', 'off');
            
            % Create main axes for image display
            obj.ax = axes('Parent', obj.fig, 'Position', [0.05, 0.15, 0.7, 0.75]);
            % 先显示移动图像（灰度）
            obj.moving_layer = imshow(obj.movingImage, [], 'parent', obj.ax, ...
                'border', 'tight', 'initialmagnification', 'fit');
            clim = obj.ax.CLim;
            
            hold on;
            
            % 再显示固定图像为绿色
            fixedImageAdjusted = imadjust(obj.fixedImage);
            fixedImageRGB = cat(3, zeros(size(obj.fixedImage)), fixedImageAdjusted, zeros(size(obj.fixedImage)));
            
            obj.fixed_layer = imshow(fixedImageRGB, 'parent', obj.ax, ...
                'border', 'tight', 'initialmagnification', 'fit');
            obj.ax.CLim = clim;
            obj.fixed_layer.AlphaData = fixedImageAdjusted * obj.refAlpha;
            
            
            % Store initial position
            obj.initialXData = obj.moving_layer.XData;
            obj.initialYData = obj.moving_layer.YData;
            
            % Add title to display current offset
            title(obj.ax, ['Offset: x=', num2str(obj.xoffset), ', y=', num2str(obj.yoffset)]);
            
            % Set up mouse callbacks
            set(obj.fig, 'WindowButtonDownFcn', @obj.startDrag);
            set(obj.fig, 'WindowButtonUpFcn', @obj.endDrag);
            set(obj.fig, 'WindowButtonMotionFcn', @obj.dragImage);
            
            % 添加帧滑块
            uicontrol('Parent', obj.fig, ...
                'Style', 'text', ...
                'String', 'Frame:', ...
                'Position', [80, 91, 50, 20]);
            
            obj.frameSlider = uicontrol('Parent', obj.fig, ...
                'Style', 'slider', ...
                'Min', 1, ...
                'Max', obj.maxFrames, ...
                'Value', obj.currentFrame, ...
                'SliderStep', [1/max(1, obj.maxFrames-1), 10/max(1, obj.maxFrames-1)], ...
                'Position', [130, 91, 300, 20]);
            addlistener(obj.frameSlider, 'Value', 'PostSet',@obj.updateFrame);
            % 将原来的文本框替换为Spinner控件
            obj.frameSpinner = uicontrol('Parent', obj.fig, ...
                'Style', 'edit', ...
                'String', num2str(obj.currentFrame), ...
                'Position', [450, 91, 50, 20], ...
                'Callback', @obj.updateFrameFromSpinner);
            
            % 显示最大帧数
            uicontrol('Parent', obj.fig, ...
                'Style', 'text', ...
                'String', ['/', num2str(obj.maxFrames)], ...
                'Position', [505, 91, 45, 20]);
            
            % 添加参考图像Alpha值控制
            uicontrol('Parent', obj.fig, ...
                'Style', 'text', ...
                'String', 'Ref Alpha:', ...
                'Position', [560, 91, 60, 20]);
            
            obj.alphaSpinner = uicontrol('Parent', obj.fig, ...
                'Style', 'edit', ...
                'String', num2str(obj.refAlpha), ...
                'Position', [625, 91, 50, 20], ...
                'Callback', @obj.updateRefAlpha);
            
            % 在参考Alpha值控件旁边添加显示参考图层复选框
            obj.showReferenceCheckbox = uicontrol('Parent', obj.fig, ...
                'Style', 'checkbox', ...
                'String', 'Show Reference', ...
                'Value', obj.showReference, ...
                'Position', [685, 91, 100, 20], ...
                'Callback', @obj.toggleReferenceVisibility);
            
            % 在帧滑块下方添加亮度范围控件
            uicontrol('Parent', obj.fig, ...
                'Style', 'text', ...
                'String', 'CLim Min:', ...
                'Position', [80, 63, 50, 20]);
            
            obj.climMinControl = uicontrol('Parent', obj.fig, ...
                'Style', 'edit', ...
                'String', num2str(obj.climMin), ...
                'Position', [130, 65, 50, 20], ...
                'Callback', @obj.updateClim);
            
            uicontrol('Parent', obj.fig, ...
                'Style', 'text', ...
                'String', 'CLim Max:', ...
                'Position', [200, 59, 57, 22.6]);
            
            obj.climMaxControl = uicontrol('Parent', obj.fig, ...
                'Style', 'edit', ...
                'String', num2str(obj.climMax), ...
                'Position', [254, 65, 50, 20], ...
                'Callback', @obj.updateClim);
            
            % Create control panel for affine transformation
            obj.createControlPanel();
        end
        
        function createControlPanel(obj)
            % Create panel for affine transformation controls
            obj.controlPanel = uipanel('Title', 'Affine Transformation Controls', ...
                'Position', [0.78,0.15,0.2,0.8123], ... % Increased height and moved down to align with the image
                'Parent', obj.fig);
            
            % Define common dimensions for better layout
            panelWidth = 150;
            buttonHeight = 30;
            sliderHeight = 20;
            textHeight = 20;
            margin = 10;
            verticalSpacing = 8; % Reduced spacing to fit all elements
            
            % Calculate total available height in the panel
            panelHeight = obj.fig.Position(4) * 0.80;
            
            % Current y position for placing elements (start from top)
            yPos = panelHeight - buttonHeight - margin;
            
            % Toggle button for affine transformation mode
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'togglebutton', ...
                'String', 'Enable Affine Mode', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.toggleAffineMode);
            
            % Update y position
            yPos = yPos - buttonHeight - verticalSpacing;
            
            % Scale X slider
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Scale X:', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight;
            
            obj.scaleXSlider = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'slider', ...
                'Min', 0.5, ...
                'Max', 2.0, ...
                'Value', 1.0, ...
                'Position', [margin, yPos, panelWidth, sliderHeight], ...
                'Callback', @obj.updateAffineTransform, ...
                'Enable', 'off'); % 初始状态为禁用
            
            yPos = yPos - sliderHeight - verticalSpacing;
            
            % Scale Y slider
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Scale Y:', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight;
            
            obj.scaleYSlider = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'slider', ...
                'Min', 0.5, ...
                'Max', 2.0, ...
                'Value', 1.0, ...
                'Position', [margin, yPos, panelWidth, sliderHeight], ...
                'Callback', @obj.updateAffineTransform, ...
                'Enable', 'off'); % 初始状态为禁用
            
            yPos = yPos - sliderHeight - verticalSpacing;
            
            % Rotation slider
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Rotation (degrees):', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight;
            
            obj.rotationSlider = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'slider', ...
                'Min', -30, ...
                'Max', 30, ...
                'Value', 0, ...
                'Position', [margin, yPos, panelWidth, sliderHeight], ...
                'Callback', @obj.updateAffineTransform, ...
                'Enable', 'off'); % 初始状态为禁用
            
            yPos = yPos - sliderHeight - verticalSpacing;
            
            % Shear X slider
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Shear X:', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight;
            
            obj.shearXSlider = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'slider', ...
                'Min', -0.5, ...
                'Max', 0.5, ...
                'Value', 0, ...
                'Position', [margin, yPos, panelWidth, sliderHeight], ...
                'Callback', @obj.updateAffineTransform, ...
                'Enable', 'off'); % 初始状态为禁用
            
            yPos = yPos - sliderHeight - verticalSpacing;
            
            % Shear Y slider
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Shear Y:', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight;
            
            obj.shearYSlider = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'slider', ...
                'Min', -0.5, ...
                'Max', 0.5, ...
                'Value', 0, ...
                'Position', [margin, yPos, panelWidth, sliderHeight], ...
                'Callback', @obj.updateAffineTransform, ...
                'Enable', 'off'); % 初始状态为禁用
            
            % Current Values text (just label)
            yPos = yPos - sliderHeight - verticalSpacing;
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'Transformations:', ...
                'Position', [margin, yPos, panelWidth, textHeight]);
            
            yPos = yPos - textHeight - verticalSpacing;
            
            % Copy transform button
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Copy Transformations', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.copyTransform);
            
            yPos = yPos - buttonHeight - verticalSpacing;
            
            % Paste transform button
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Paste Transformations', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.pasteTransform);
            
            yPos = yPos - buttonHeight - verticalSpacing;
            
            % Apply registration button
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Apply Registration', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.applyRegistrationCallback);
            
            yPos = yPos - buttonHeight - verticalSpacing;
            
            % Apply to all frames button
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Apply to Frames', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.applyToAllFrames);
            
            % 添加帧范围输入控件
            yPos = yPos - buttonHeight - verticalSpacing/2;
            
            % 起始帧标签和输入框
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'From frame:', ...
                'Position', [margin, yPos, panelWidth/2-5, textHeight]);
            
            obj.framesToApplyStart = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'edit', ...
                'String', num2str(obj.currentFrame+1), ...
                'Position', [margin + panelWidth/2, yPos, panelWidth/2-5, textHeight]);
            
            % 结束帧标签和输入框
            yPos = yPos - textHeight - verticalSpacing/2;
            
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'text', ...
                'String', 'To frame:', ...
                'Position', [margin, yPos, panelWidth/2-5, textHeight]);
            
            obj.framesToApplyEnd = uicontrol('Parent', obj.controlPanel, ...
                'Style', 'edit', ...
                'String', num2str(obj.maxFrames), ...
                'Position', [margin + panelWidth/2, yPos, panelWidth/2-5, textHeight]);
            
            yPos = yPos - textHeight - verticalSpacing-5;
            
            % Reset button
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Reset All Transformations', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.resetAll);
            
            % Auto save checkbox
            yPos = yPos - buttonHeight - verticalSpacing;
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'checkbox', ...
                'String', 'Auto Save', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Value', obj.autoSave, ...
                'Callback', @obj.toggleAutoSave);
            % 添加设置参考帧按钮
            yPos = yPos - buttonHeight - verticalSpacing;
            uicontrol('Parent', obj.controlPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Set Current as Reference', ...
                'Position', [margin, yPos, panelWidth, buttonHeight], ...
                'Callback', @obj.setCurrentAsReference);
            % Make sure the last button is visible by adjusting panel height if needed
            if yPos < 0
                % Adjust UI components to fit in the panel
                % This can be done by reducing spacing or button heights
                % Or by using a scrollable panel if many controls are needed
            end
        end
        
        function toggleAffineMode(obj, src, ~)
            % Toggle between translation and affine mode
            obj.affineMode = src.Value;
            if obj.affineMode
                src.String = 'Disable Affine Mode';
                % 启用所有仿射变换滑块
                obj.scaleXSlider.Enable = 'on';
                obj.scaleYSlider.Enable = 'on';
                obj.rotationSlider.Enable = 'on';
                obj.shearXSlider.Enable = 'on';
                obj.shearYSlider.Enable = 'on';
            else
                src.String = 'Enable Affine Mode';
                % 禁用所有仿射变换滑块
                obj.scaleXSlider.Enable = 'off';
                obj.scaleYSlider.Enable = 'off';
                obj.rotationSlider.Enable = 'off';
                obj.shearXSlider.Enable = 'off';
                obj.shearYSlider.Enable = 'off';
            end
        end
        
        function updateAffineTransform(obj, ~, ~)
            % Update affine transformation parameters from sliders
            obj.scaleX = obj.scaleXSlider.Value;
            obj.scaleY = obj.scaleYSlider.Value;
            obj.rotation = obj.rotationSlider.Value;
            obj.shearX = obj.shearXSlider.Value;
            obj.shearY = obj.shearYSlider.Value;
            
            % Apply the transformation
            obj.applyTransformation();
        end
        
        function keyPressCallback(obj, ~, event)
            % Handle keyboard press events
            step = 1; % Movement step in pixels
            
            % 处理帧切换 (不再考虑鼠标是否在图像中)
            if strcmp(event.Key, 'leftarrow')
                % 切换到上一帧
                if obj.currentFrame > 1
                    obj.frameSlider.Value = obj.currentFrame - 1;
                    obj.updateFrame(obj.frameSlider, []);
                end
                return;
            elseif strcmp(event.Key, 'rightarrow')
                % 切换到下一帧
                if obj.currentFrame < obj.maxFrames
                    obj.frameSlider.Value = obj.currentFrame + 1;
                    obj.updateFrame(obj.frameSlider, []);
                end
                return;
            end
            
            % 使用WSAD键进行图像移动 (不需要考虑鼠标位置)
            switch event.Key
                case 'w'
                    obj.yoffset = obj.yoffset - step;
                    obj.applyTransformation();
                case 's'
                    obj.yoffset = obj.yoffset + step;
                    obj.applyTransformation();
                case 'a'
                    obj.xoffset = obj.xoffset - step;
                    obj.applyTransformation();
                case 'd'
                    obj.xoffset = obj.xoffset + step;
                    obj.applyTransformation();
            end
        end
        
        function startDrag(obj, ~, ~)
            % Start dragging the image
            cursorPos = get(obj.ax, 'CurrentPoint');
            obj.dragStartX = cursorPos(1, 1);
            obj.dragStartY = cursorPos(1, 2);
            
            % Store the offset at the start of dragging
            obj.dragStartXoffset = obj.xoffset;
            obj.dragStartYoffset = obj.yoffset;
            
            % Check if cursor is over the image and update mouseClickedInImage flag
            obj.mouseClickedInImage = obj.isInImage(obj.dragStartX, obj.dragStartY);
            
            % Set dragging flag only if clicked on the image
            if obj.mouseClickedInImage
                obj.isDragging = true;
            end
        end
        
        function endDrag(obj, ~, ~)
            % End dragging
            obj.isDragging = false;
            % We keep mouseClickedInImage unchanged here to remember the last click location
        end
        
        function dragImage(obj, ~, ~)
            % Handle drag motion
            if obj.isDragging
                % Get current cursor position
                cursorPos = get(obj.ax, 'CurrentPoint');
                currentX = cursorPos(1, 1);
                currentY = cursorPos(1, 2);
                
                % Calculate total displacement from drag start
                dx = currentX - obj.dragStartX;
                dy = currentY - obj.dragStartY;
                
                % Update offsets based on initial offset plus displacement
                obj.xoffset = obj.dragStartXoffset + dx;
                obj.yoffset = obj.dragStartYoffset + dy;
                
                % Update image position
                obj.applyTransformation();
            end
        end
        
        function result = isInImage(obj, x, y)
            % Check if cursor is within image bounds
            imgWidth = size(obj.fixedImage, 2);
            imgHeight = size(obj.fixedImage, 1);
            
            result = (x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight);
        end
        
        function applyTransformation(obj)
            % Apply both translation and affine transformation to the moving image
            
            % Get image dimensions
            [height, width] = size(obj.movingImage);
            
            if obj.affineMode
                % Create affine transformation matrix
                tform = affine2d([
                    obj.scaleX, obj.shearY, 0;
                    obj.shearX, obj.scaleY, 0;
                    0, 0, 1
                    ]);
                
                % Add rotation
                rotationRadians = deg2rad(obj.rotation);
                rotMatrix = [
                    cos(rotationRadians), -sin(rotationRadians), 0;
                    sin(rotationRadians), cos(rotationRadians), 0;
                    0, 0, 1
                    ];
                tform.T = tform.T * rotMatrix;
                
                
                % Transform the original moving image
                transformedImage = imwarp(obj.movingImage, tform, 'OutputView', imref2d([height, width]));
                
                % 直接更新moving_layer的CData，不需要转换为RGB
                obj.moving_layer.CData = transformedImage;
                
                % Apply translation using XData and YData
                width = obj.initialXData(2) - obj.initialXData(1);
                height = obj.initialYData(2) - obj.initialYData(1);
                
                % Calculate new position
                newXData = [obj.initialXData(1) + obj.xoffset, obj.initialXData(1) + obj.xoffset + width];
                newYData = [obj.initialYData(1) + obj.yoffset, obj.initialYData(1) + obj.yoffset + height];
                
                % Update position
                obj.moving_layer.XData = newXData;
                obj.moving_layer.YData = newYData;
                
                % Update title with all transformation parameters
                titleStr = sprintf('Translation: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f', ...
                    obj.xoffset, obj.yoffset, obj.scaleX, obj.scaleY, obj.rotation, obj.shearX, obj.shearY);
                
                % 如果需要显示复制的变换信息，则添加在标题上方
                if obj.showCopiedTransform
                    copiedStr = sprintf('Copied: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f\n', ...
                        obj.copiedTransform.xoffset, obj.copiedTransform.yoffset, ...
                        obj.copiedTransform.scaleX, obj.copiedTransform.scaleY, ...
                        obj.copiedTransform.rotation, obj.copiedTransform.shearX, obj.copiedTransform.shearY);
                    titleStr = [copiedStr, titleStr];
                end
                
                title(obj.ax, titleStr);
            else
                % Simple translation - just update the image position
                width = obj.initialXData(2) - obj.initialXData(1);
                height = obj.initialYData(2) - obj.initialYData(1);
                
                % Calculate new position
                newXData = [obj.initialXData(1) + obj.xoffset, obj.initialXData(1) + obj.xoffset + width];
                newYData = [obj.initialYData(1) + obj.yoffset, obj.initialYData(1) + obj.yoffset + height];
                
                % Update position
                obj.moving_layer.XData = newXData;
                obj.moving_layer.YData = newYData;
                
                % 如果需要显示复制的变换信息，则添加在标题上方
                if obj.showCopiedTransform
                    copiedStr = sprintf('Copied: x=%.1f, y=%.1f | Scale: x=%.2f, y=%.2f | Rot: %.1f° | Shear: x=%.2f, y=%.2f\n', ...
                        obj.copiedTransform.xoffset, obj.copiedTransform.yoffset, ...
                        obj.copiedTransform.scaleX, obj.copiedTransform.scaleY, ...
                        obj.copiedTransform.rotation, obj.copiedTransform.shearX, obj.copiedTransform.shearY);
                    title(obj.ax, [copiedStr, 'Offset: x=', num2str(round(obj.xoffset)), ', y=', num2str(round(obj.yoffset))]);
                else
                    title(obj.ax, ['Offset: x=', num2str(round(obj.xoffset)), ', y=', num2str(round(obj.yoffset))]);
                end
            end
            
            % Refresh display
            drawnow;
        end
        
        function [xOffset, yOffset] = getOffset(obj)
            % Return the current offsets
            xOffset = obj.xoffset;
            yOffset = obj.yoffset;
        end
        
        function getAffineParameters(obj)
            % Return all affine transformation parameters
            params = struct('xoffset', obj.xoffset, 'yoffset', obj.yoffset, ...
                'scaleX', obj.scaleX, 'scaleY', obj.scaleY, ...
                'rotation', obj.rotation, 'shearX', obj.shearX, 'shearY', obj.shearY);
            
            % Display parameters in command window
            disp('Current transformation parameters:');
            disp(params);
        end
        
        function resetTransformParams(obj)
            % 重置所有变换参数，但保持界面不变
            obj.xoffset = 0;
            obj.yoffset = 0;
            obj.scaleX = 1.0;
            obj.scaleY = 1.0;
            obj.rotation = 0;
            obj.shearX = 0;
            obj.shearY = 0;
            
            % 重置滑块的值
            obj.scaleXSlider.Value = 1.0;
            obj.scaleYSlider.Value = 1.0;
            obj.rotationSlider.Value = 0;
            obj.shearXSlider.Value = 0;
            obj.shearYSlider.Value = 0;
            
            % 重置拖拽相关参数
            obj.dragStartX = 0;
            obj.dragStartY = 0;
            obj.dragStartXoffset = 0;
            obj.dragStartYoffset = 0;
            obj.isDragging = false;
        end
        
        function resetAll(obj, ~, ~)
            % Reset all transformation parameters
            obj.resetTransformParams();
            
            % Apply transformation (reset)
            obj.applyTransformation();
        end
        
        function updateFrame(obj, src, ~)
            % 检查当前帧是否有配准操作，如果有，则应用配准效果并保存
            if obj.hasTransformationApplied() && obj.autoSave
                % 获取当前帧经过配准后的图像
                [height, width] = size(obj.movingImageOriginal);
                registeredImage = obj.movingImageOriginal;
                
                if obj.affineMode
                    % 创建仿射变换矩阵
                    tform = affine2d([
                        obj.scaleX, obj.shearY, 0;
                        obj.shearX, obj.scaleY, 0;
                        0, 0, 1
                        ]);
                    
                    % 添加旋转
                    rotationRadians = deg2rad(obj.rotation);
                    rotMatrix = [
                        cos(rotationRadians), -sin(rotationRadians), 0;
                        sin(rotationRadians), cos(rotationRadians), 0;
                        0, 0, 1
                        ];
                    tform.T = tform.T * rotMatrix;
                    
                    % 变换原始移动图像
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                % 应用平移
                registeredImage = circshift(registeredImage, [round(obj.yoffset), round(obj.xoffset)]);
                
                % 保存配准后的图像
                obj.tiff_memmap.Data(obj.currentFrame).channel1 = registeredImage';
            end
            
            % 更新当前帧
            obj.currentFrame = round(obj.frameSlider.Value);
            
            % 更新帧号显示 - 改为更新Spinner值
            obj.frameSpinner.String = num2str(obj.currentFrame);
            
            % 加载新帧
            if ~isempty(obj.movingImagePath)
                obj.movingImageOriginal = obj.tiff_memmap.Data(obj.currentFrame).channel1';
                obj.movingImage = obj.movingImageOriginal;
                
                % 重置所有变换参数
                obj.resetTransformParams();
                
                % 只更新移动图像层的CData，不需要转换为RGB
                obj.moving_layer.CData = obj.movingImage;
                
                % 应用重置后的变换
                obj.applyTransformation();
                
                % 保持当前的亮度范围设置
                clim([obj.climMin, obj.climMax]);
            end
        end
        
        % 新增方法：从Spinner更新帧
        function updateFrameFromSpinner(obj, src, ~)
            try
                newFrame = str2double(src.String);
                if ~isnan(newFrame) && newFrame >= 1 && newFrame <= obj.maxFrames
                    % 更新滑块位置
                    obj.frameSlider.Value = newFrame;
                    % 调用更新帧的方法
                    obj.updateFrame(obj.frameSlider, []);
                else
                    % 如果输入无效，恢复原值
                    src.String = num2str(obj.currentFrame);
                end
            catch
                % 如果发生错误，恢复原值
                src.String = num2str(obj.currentFrame);
            end
        end
        %设置当前帧为参考帧
        function setCurrentAsReference(obj, ~, ~)
            % 记住之前的参考帧号
            prevRefFrame = obj.referenceFrameNum;
            
            % 设置当前帧为新的参考帧
            obj.referenceFrameNum = obj.currentFrame;
            
            % 获取当前帧数据作为新的固定图像
            obj.fixedImage = obj.movingImageOriginal;
            
            % 更新固定图像层显示
            fixedImageAdjusted = imadjust(obj.fixedImage);
            fixedImageRGB = cat(3, zeros(size(obj.fixedImage)), fixedImageAdjusted, zeros(size(obj.fixedImage)));
            
            obj.fixed_layer.CData = fixedImageRGB;
            obj.fixed_layer.AlphaData = fixedImageAdjusted * obj.refAlpha;
            
            % 保持当前的可见性设置
            if ~obj.showReference
                obj.fixed_layer.Visible = 'off';
            end
            
            % 显示确认消息
            % msgbox(sprintf('已将帧 %d 设置为新的参考帧（之前是帧 %d）', obj.currentFrame, prevRefFrame), '参考帧已更新');
        end
        % 新增方法：更新参考图像Alpha值
        function updateRefAlpha(obj, src, ~)
            try
                newAlpha = str2double(src.String);
                if ~isnan(newAlpha) && newAlpha >= 0 && newAlpha <= 1
                    obj.refAlpha = newAlpha;
                    % 更新参考图像的Alpha值
                    fixedImageAdjusted = imadjust(obj.fixedImage);
                    obj.fixed_layer.AlphaData = fixedImageAdjusted * obj.refAlpha;
                    
                    % 确保可见性设置不变
                    if ~obj.showReference
                        obj.fixed_layer.Visible = 'off';
                    end
                else
                    % 如果输入无效，恢复原值
                    src.String = num2str(obj.refAlpha);
                end
            catch
                % 如果发生错误，恢复原值
                src.String = num2str(obj.refAlpha);
            end
        end
        
        % 新增方法：切换自动保存状态
        function toggleAutoSave(obj, src, ~)
            obj.autoSave = src.Value;
        end
        
        function result = hasTransformationApplied(obj)
            % 检查是否应用了任何变换
            result = obj.xoffset ~= 0 || obj.yoffset ~= 0 || ...
                obj.scaleX ~= 1.0 || obj.scaleY ~= 1.0 || ...
                obj.rotation ~= 0 || obj.shearX ~= 0 || obj.shearY ~= 0;
        end
        
        function applyRegistrationCallback(obj, ~, ~)
            % Callback for the Apply Registration button
            obj.applyRegistration();
        end
        
        function applyRegistration(obj)
            % Apply the current registration to create a new registered image
            
            % 检查当前帧是否有配准操作，如果有，则应用配准效果并保存
            if obj.hasTransformationApplied()
                % 获取当前帧经过配准后的图像
                [height, width] = size(obj.movingImageOriginal);
                registeredImage = obj.movingImageOriginal;
                
                if obj.affineMode
                    % 创建仿射变换矩阵
                    tform = affine2d([
                        obj.scaleX, obj.shearY, 0;
                        obj.shearX, obj.scaleY, 0;
                        0, 0, 1
                        ]);
                    
                    % 添加旋转
                    rotationRadians = deg2rad(obj.rotation);
                    rotMatrix = [
                        cos(rotationRadians), -sin(rotationRadians), 0;
                        sin(rotationRadians), cos(rotationRadians), 0;
                        0, 0, 1
                        ];
                    tform.T = tform.T * rotMatrix;
                    
                    % 变换原始移动图像
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                % 应用平移
                registeredImage = circshift(registeredImage, [round(obj.yoffset), round(obj.xoffset)]);
                
                % 保存配准后的图像
                obj.tiff_memmap.Data(obj.currentFrame).channel1 = registeredImage';
            end
            
            
            % 加载新帧
            if ~isempty(obj.movingImagePath)
                obj.movingImageOriginal = obj.tiff_memmap.Data(obj.currentFrame).channel1';
                obj.movingImage = obj.movingImageOriginal;
                
                % 重置所有变换参数
                obj.resetTransformParams();
                
                % 只更新移动图像层的CData，不需要转换为RGB
                obj.moving_layer.CData = obj.movingImage;
                
                % 应用重置后的变换
                obj.applyTransformation();
            end
            
            % Show the transformation parameters in command window
            obj.getAffineParameters();
        end
        
        function copyTransform(obj, ~, ~)
            % 复制当前变换参数
            obj.copiedTransform = struct('xoffset', obj.xoffset, 'yoffset', obj.yoffset, ...
                'scaleX', obj.scaleX, 'scaleY', obj.scaleY, ...
                'rotation', obj.rotation, 'shearX', obj.shearX, 'shearY', obj.shearY);
            
            % 设置显示复制的transform信息
            obj.showCopiedTransform = true;
            
            % 更新显示
            obj.applyTransformation();
            
            % 显示提示信息
            % msgbox('已复制当前变换参数', '复制成功');
        end
        
        function pasteTransform(obj, src, ~)
            % 粘贴之前复制的变换参数
            obj.xoffset = obj.copiedTransform.xoffset;
            obj.yoffset = obj.copiedTransform.yoffset;
            obj.scaleX = obj.copiedTransform.scaleX;
            obj.scaleY = obj.copiedTransform.scaleY;
            obj.rotation = obj.copiedTransform.rotation;
            obj.shearX = obj.copiedTransform.shearX;
            obj.shearY = obj.copiedTransform.shearY;
            
            % 更新滑块值
            obj.scaleXSlider.Value = obj.scaleX;
            obj.scaleYSlider.Value = obj.scaleY;
            obj.rotationSlider.Value = obj.rotation;
            obj.shearXSlider.Value = obj.shearX;
            obj.shearYSlider.Value = obj.shearY;
            
            % 应用变换
            obj.applyTransformation();
            
            % 保持显示复制的transform信息状态
            
            % 恢复主图形窗口焦点，确保键盘监听事件继续有效
            
            % figure(obj.fig);
            % 显示提示信息
            % msgbox('已粘贴变换参数', '粘贴成功');
            obj.mouseClickedInImage = false % 跟踪鼠标是否点击在图像内
            % 避免粘贴后无法移动帧
            src.Enable = 'off';
            drawnow update;
            src.Enable = 'on';
        end
        
        function applyToAllFrames(obj, ~, ~)
            % 将当前变换应用到指定范围的帧
            
            % 获取用户输入的帧范围
            try
                startFrame = str2double(obj.framesToApplyStart.String);
                endFrame = str2double(obj.framesToApplyEnd.String);
                
                % 验证输入范围
                if isnan(startFrame) || isnan(endFrame) || startFrame < 1 || endFrame > obj.maxFrames || startFrame > endFrame
                    errordlg('请输入有效的帧范围！', '输入错误');
                    return;
                end
                
                % 确认对话框
                frameCount = endFrame - startFrame + 1;
                choice = questdlg(sprintf('确定要将当前变换应用到 %d 帧吗？（帧范围：%d-%d）', ...
                    frameCount, startFrame, endFrame), ...
                    '确认操作', '确定', '取消', '确定');
                
                if ~strcmp(choice, '确定')
                    return;
                end
            catch
                errordlg('请输入有效的帧范围！', '输入错误');
                return;
            end
            
            % 记住当前变换参数
            currentTransform = struct('xoffset', obj.xoffset, 'yoffset', obj.yoffset, ...
                'scaleX', obj.scaleX, 'scaleY', obj.scaleY, ...
                'rotation', obj.rotation, 'shearX', obj.shearX, 'shearY', obj.shearY);
            
            % 先保存当前帧的变换结果
            obj.applyRegistration();
            
            % 记住当前帧
            currentFrameNum = obj.currentFrame;
            
            % 创建等待对话框
            waitMsg = waitbar(0, sprintf('正在处理帧 %d/%d...', startFrame, endFrame), 'Name', '应用变换到指定帧');
            
            % 遍历指定范围的所有帧
            for frame = startFrame:endFrame
                % 如果当前处理的帧就是当前显示的帧，则跳过（因为已经在前面应用了变换）
                if frame == currentFrameNum
                    continue;
                end
                
                % 更新等待对话框
                waitbar((frame - startFrame) / (endFrame - startFrame + 1), waitMsg, ...
                    sprintf('正在处理帧 %d/%d...', frame, endFrame));
                
                % 切换到目标帧
                obj.currentFrame = frame;
                
                % 加载帧数据
                obj.movingImageOriginal = obj.tiff_memmap.Data(obj.currentFrame).channel1';
                obj.movingImage = obj.movingImageOriginal;
                
                % 应用相同的变换
                obj.xoffset = currentTransform.xoffset;
                obj.yoffset = currentTransform.yoffset;
                obj.scaleX = currentTransform.scaleX;
                obj.scaleY = currentTransform.scaleY;
                obj.rotation = currentTransform.rotation;
                obj.shearX = currentTransform.shearX;
                obj.shearY = currentTransform.shearY;
                
                % 应用当前变换并保存
                [height, width] = size(obj.movingImageOriginal);
                registeredImage = obj.movingImageOriginal;
                
                if obj.affineMode
                    % 创建仿射变换矩阵
                    tform = affine2d([
                        obj.scaleX, obj.shearY, 0;
                        obj.shearX, obj.scaleY, 0;
                        0, 0, 1
                        ]);
                    
                    % 添加旋转
                    rotationRadians = deg2rad(obj.rotation);
                    rotMatrix = [
                        cos(rotationRadians), -sin(rotationRadians), 0;
                        sin(rotationRadians), cos(rotationRadians), 0;
                        0, 0, 1
                        ];
                    tform.T = tform.T * rotMatrix;
                    
                    % 变换原始移动图像
                    registeredImage = imwarp(registeredImage, tform, 'OutputView', imref2d([height, width]));
                end
                
                % 应用平移
                registeredImage = circshift(registeredImage, [round(obj.yoffset), round(obj.xoffset)]);
                
                % 保存配准后的图像
                obj.tiff_memmap.Data(obj.currentFrame).channel1 = registeredImage';
            end
            
            % 关闭等待对话框
            close(waitMsg);
            
            % 返回到原始帧
            obj.currentFrame = currentFrameNum;
            obj.frameSlider.Value = currentFrameNum;
            obj.frameSpinner.String = num2str(currentFrameNum);
            
            % 更新当前显示的图像
            obj.movingImageOriginal = obj.tiff_memmap.Data(obj.currentFrame).channel1';
            obj.movingImage = obj.movingImageOriginal;
            obj.moving_layer.CData = obj.movingImage;
            
            % 重置所有变换参数
            obj.resetTransformParams();
            obj.applyTransformation();
            
            % 保持当前的亮度范围设置
            clim([obj.climMin, obj.climMax]);
            
            % 显示完成消息
            % msgbox(sprintf('已将变换应用到帧 %d 到 %d', startFrame, endFrame), '处理完成');
        end
        
        % 新增方法：更新亮度范围
        function updateClim(obj, src, ~)
            try
                % 根据触发控件更新相应的属性
                if src == obj.climMinControl
                    obj.climMin = str2double(src.String);
                else
                    obj.climMax = str2double(src.String);
                end
                
                % 验证输入值
                if obj.climMin >= obj.climMax
                    % 如果最小值大于等于最大值，恢复原值
                    obj.climMin = min(obj.movingImageOriginal(:));
                    obj.climMax = max(obj.movingImageOriginal(:));
                    obj.climMinControl.String = num2str(obj.climMin);
                    obj.climMaxControl.String = num2str(obj.climMax);
                    warndlg('CLim Min 必须小于 CLim Max', '无效输入');
                    return;
                end
                
                % 应用新的亮度范围
                clim([obj.climMin, obj.climMax]);
                
            catch
                % 如果发生错误，恢复原值
                obj.climMin = min(obj.movingImageOriginal(:));
                obj.climMax = max(obj.movingImageOriginal(:));
                obj.climMinControl.String = num2str(obj.climMin);
                obj.climMaxControl.String = num2str(obj.climMax);
                warndlg('请输入有效的数字', '无效输入');
            end
        end
        
        % 新增方法：切换参考图像层可见性
        function toggleReferenceVisibility(obj, src, ~)
            obj.showReference = src.Value;
            
            % 根据复选框状态更新参考图层的可见性
            if obj.showReference
                obj.fixed_layer.Visible = 'on';
            else
                obj.fixed_layer.Visible = 'off';
            end
        end
    end
end
