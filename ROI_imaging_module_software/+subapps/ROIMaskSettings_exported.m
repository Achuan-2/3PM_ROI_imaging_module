classdef ROIMaskSettings_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        AdjustROIPanel                 matlab.ui.container.Panel
        DragROIsButton                 matlab.ui.control.StateButton
        ClearPatchButton               matlab.ui.control.Button
        ClearAllButton                 matlab.ui.control.Button
        ReorderROIsButton              matlab.ui.control.Button
        AddRegularROIPanel             matlab.ui.container.Panel
        CircleButton                   matlab.ui.control.Button
        RectButton                     matlab.ui.control.Button
        ROIIDStyleSettingsPanel        matlab.ui.container.Panel
        ROIIDColorPickerButton         matlab.ui.control.Button
        showROIIDCheckBox              matlab.ui.control.CheckBox
        ROIIDColorEditField            matlab.ui.control.EditField
        ROIIDColorEditFieldLabel       matlab.ui.control.Label
        ROIIDFontSizeSpinner           matlab.ui.control.Spinner
        ROIIDFontSizeSpinnerLabel      matlab.ui.control.Label
        ROIMaskStyleSettingsPanel      matlab.ui.container.Panel
        ROIMaskColorPickerButton       matlab.ui.control.Button
        showROIMaskbackgroundCheckBox  matlab.ui.control.CheckBox
        ROIMaskColorEditField          matlab.ui.control.EditField
        MaskColorDropDown              matlab.ui.control.DropDown
        MaskColorDropDownLabel         matlab.ui.control.Label
        Label                          matlab.ui.control.Label
    end

    
    properties (Access = private)
        MainApp; % 主程序
    end
    
    methods (Access = public)
        
        function variableInit(app)
             % 根据DrawROI的值进行初始化
            if ~isempty(app.MainApp.DrawROI)
                % 初始化ROI ID显示设置
                app.showROIIDCheckBox.Value = app.MainApp.DrawROI.showRoiNumber;
                app.ROIIDFontSizeSpinner.Value = app.MainApp.DrawROI.roi_number_fontSize;
                if isnumeric(app.MainApp.DrawROI.roi_number_fontColor)
                    % 如果是RGB数值，转换为hex格式
                    app.ROIIDColorEditField.BackgroundColor = app.MainApp.DrawROI.roi_number_fontColor;
                    app.ROIIDColorEditField.Value = utils.matrix2hex(app.MainApp.DrawROI.roi_number_fontColor);
                else
                    app.ROIIDColorEditField.BackgroundColor = app.MainApp.DrawROI.roi_number_fontColor;
                    app.ROIIDColorEditField.Value =  app.MainApp.DrawROI.roi_number_fontColor;
                end


                % 初始化ROI Mask背景设置
                app.showROIMaskbackgroundCheckBox.Value = app.MainApp.DrawROI.show_background;

                % 初始化ROI Mask颜色设置
                if ischar(app.MainApp.DrawROI.mask_color) && strcmp(app.MainApp.DrawROI.mask_color, 'Random')
                    app.MaskColorDropDown.Value = 'Random';
                    app.ROIMaskColorEditField.Visible = 'off';
                    app.ROIMaskColorPickerButton.Visible = 'off';
                else
                    app.MaskColorDropDown.Value = 'Fixed';
                    app.ROIMaskColorEditField.Visible = 'on';
                    app.ROIMaskColorPickerButton.Visible = 'on';
                    if isnumeric(app.MainApp.DrawROI.mask_color)
                        % 如果是RGB数值，转换为hex格式
                        app.ROIMaskColorEditField.BackgroundColor = app.MainApp.DrawROI.mask_color;
                        app.ROIMaskColorEditField.Value = utils.matrix2hex(app.MainApp.DrawROI.mask_color);
                    else
                        app.ROIMaskColorEditField.Value = app.MainApp.DrawROI.mask_color;
                        app.ROIMaskColorEditField.BackgroundColor = utils.hex2matrix(app.MainApp.DrawROI.mask_color);
                    end
                end
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            app.MainApp = mainApp;
            % 让副app的位置随着主app走
            app.UIFigure.Position(1) = app.MainApp.UIFigure.Position(1)+app.MainApp.UIFigure.Position(3)+5;
            app.UIFigure.Position(2) = app.MainApp.UIFigure.Position(2);


            % 根据DrawROI的值进行初始化
            variableInit(app)
        end

        % Value changed function: MaskColorDropDown
        function MaskColorDropDownValueChanged(app, event)
            value = app.MaskColorDropDown.Value;
            switch value
                case 'Fixed'
                    app.ROIMaskColorEditField.Visible = 'on';
                    if ~isempty(app.MainApp.DrawROI)
                        app.MainApp.DrawROI.mask_color = utils.hex2matrix(app.ROIMaskColorEditField.Value);
                        app.MainApp.roiStyleConfig.mask_color = app.MainApp.DrawROI.mask_color;
                    end
                    app.ROIMaskColorEditField.BackgroundColor = utils.hex2matrix(app.ROIMaskColorEditField.Value);
                    app.ROIMaskColorPickerButton.Visible = 'on';
                case 'Random'
                    app.ROIMaskColorEditField.Visible = 'off';
                    app.MainApp.DrawROI.mask_color = 'Random';
                    app.MainApp.roiStyleConfig.mask_color = 'Random';
                    app.ROIMaskColorPickerButton.Visible = 'off';
            end
        end

        % Value changed function: ROIMaskColorEditField
        function ROIMaskColorEditFieldValueChanged(app, event)

                % 更改mask颜色将直接更新mask颜色
            if ~isempty(app.MainApp.DrawROI)
                matrixColor = utils.hex2matrix(app.ROIMaskColorEditField.Value);
                app.MainApp.DrawROI.mask_color = matrixColor;
                app.MainApp.roiStyleConfig.mask_color = matrixColor;
                app.ROIMaskColorEditField.BackgroundColor = matrixColor;
                app.MainApp.MaskOnCheckBox.Value = true;
                app.MainApp.DrawROI.update_roi_color()
            end
        end

        % Value changed function: ROIIDFontSizeSpinner
        function ROIIDFontSizeSpinnerValueChanged(app, event)

            if ~isempty(app.MainApp.DrawROI)
                value = app.ROIIDFontSizeSpinner.Value;
                app.MainApp.DrawROI.roi_number_fontSize = value;
                app.MainApp.roiStyleConfig.roi_number_fontSize = value;
                app.MainApp.MaskOnCheckBox.Value = true;
            end
        end

        % Value changed function: ROIIDColorEditField
        function ROIIDColorEditFieldValueChanged(app, event)
            
             if ~isempty(app.MainApp.DrawROI)
                value = app.ROIIDColorEditField.Value;
                matrixColor = utils.hex2matrix(app.ROIIDColorEditField.Value);
                app.ROIIDColorEditField.BackgroundColor = matrixColor;
                app.MainApp.roiStyleConfig.roi_number_fontColor  = value;
                app.MainApp.DrawROI.roi_number_fontColor  = value;
                app.MainApp.MaskOnCheckBox.Value = true;

            end
        end

        % Value changed function: showROIMaskbackgroundCheckBox
        function showROIMaskbackgroundCheckBoxValueChanged(app, event)
         if ~isempty(app.MainApp.DrawROI)
            value = app.showROIMaskbackgroundCheckBox.Value;
            app.MainApp.DrawROI.show_background = value;
            app.MainApp.roiStyleConfig.show_background = value;
         end
        end

        % Value changed function: showROIIDCheckBox
        function showROIIDCheckBoxValueChanged(app, event)
            if ~isempty(app.MainApp.DrawROI)
                app.MainApp.DrawROI.showRoiNumber = app.showROIIDCheckBox.Value;
                app.MainApp.roiStyleConfig.showRoiNumber = app.showROIIDCheckBox.Value;
            end
        end

        % Button pushed function: ReorderROIsButton
        function ReorderROIsButtonPushed(app, event)
            if isempty(app.MainApp.DrawROI.roi_contours) || length(app.MainApp.DrawROI.roi_contours) < 2
                return;
            end
            try
                app.MainApp.DrawROI.reorder_rois();
                disp(['Reordered ' num2str(length(app.MainApp.DrawROI.roi_contours)) ' ROIs.']);
            catch ME
                errordlg(['Reorder ROIs error: ' ME.message], 'Error');
                disp(ME.getReport('extended'));
            end
        end

        % Button pushed function: ROIMaskColorPickerButton
        function ROIMaskColorPickerButtonPushed(app, event)
            currentColor = utils.hex2matrix(app.ROIMaskColorEditField.Value);
            selectedColor = uisetcolor(currentColor, 'Select ROI Mask Color');
            if ~isequal(selectedColor, 0) && ~isequal(selectedColor, currentColor) % Check if a color was selected and it's different
                app.ROIMaskColorEditField.Value = utils.matrix2hex(selectedColor);
                ROIMaskColorEditFieldValueChanged(app); % update color
            end
        end

        % Button pushed function: ROIIDColorPickerButton
        function ROIIDColorPickerButtonPushed(app, event)
            currentColor = utils.hex2matrix(app.ROIIDColorEditField.Value);
            selectedColor = uisetcolor(currentColor, 'Select ROI ID Color');
            if ~isequal(selectedColor, 0) && ~isequal(selectedColor, currentColor) % Check if a color was selected and it's different
                app.ROIIDColorEditField.Value = utils.matrix2hex(selectedColor);
                app.ROIIDColorEditFieldValueChanged(); % update color
            end
        end

        % Button pushed function: RectButton
        function RectButtonPushed(app, event)
            app.MainApp.DrawROI.add_regular_roi('rectangle');
        end

        % Button pushed function: CircleButton
        function CircleButtonPushed(app, event)
            app.MainApp.DrawROI.add_regular_roi('circle');
        end

        % Callback function
        function ClearAllButtonValueChanged(app, event)
            if ~isempty(app.MainApp.DrawROI)
                % 创建非模态的 uifigure
                fig = uifigure('Name', 'Clear ROIs', 'WindowStyle', 'normal', ...
                    'Position', [500 500 300 150]); % 非模态窗口
                figPos = app.MainApp.UIFigure.Position;
                figWidth = fig.Position(3);
                figHeight = fig.Position(4);
                figLeft = figPos(1) + (figPos(3) - figWidth)/2;
                figTop = figPos(2) + (figPos(4) - figHeight)/2;
                fig.Position(1) = figLeft;
                fig.Position(2) = figTop;

                % 添加提示文本
                uilabel(fig, 'Position', [20 80 260 30], ...
                    'Text', 'Are you sure you want to clear all ROIs?', ...
                    'HorizontalAlignment', 'center');

                % 添加 Yes 按钮
                uibutton(fig, 'push', ...
                    'Position', [60 30 80 30], ...
                    'Text', 'Yes', ...
                    'ButtonPushedFcn', @(btn, event) yesCallback(btn, event, app, fig));

                % 添加 No 按钮
                uibutton(fig, 'push', ...
                    'Position', [160 30 80 30], ...
                    'Text', 'No', ...
                    'ButtonPushedFcn', @(btn, event) noCallback(btn, event, fig));
            end

            % Yes 按钮回调函数
            function yesCallback(~, ~, app, fig)
                app.mainApp.DrawROI.clear_all_rois(); % 执行清除操作
                delete(fig); % 关闭对话框
            end

            % No 按钮回调函数
            function noCallback(~, ~, fig)
                delete(fig); % 仅关闭对话框
            end
        end

        % Button pushed function: ClearAllButton
        function ClearAllButtonPushed(app, event)
            if ~isempty(app.MainApp.DrawROI)
                % 创建非模态的 uifigure
                fig = uifigure('Name', 'Clear ROIs', 'WindowStyle', 'normal', ...
                    'Position', [500 500 300 150]); % 非模态窗口
                figPos = app.MainApp.UIFigure.Position;
                figWidth = fig.Position(3);
                figHeight = fig.Position(4);
                figLeft = figPos(1) + (figPos(3) - figWidth)/2;
                figTop = figPos(2) + (figPos(4) - figHeight)/2;
                fig.Position(1) = figLeft;
                fig.Position(2) = figTop;

                % 添加提示文本
                uilabel(fig, 'Position', [20 80 260 30], ...
                    'Text', 'Are you sure you want to clear all ROIs?', ...
                    'HorizontalAlignment', 'center');

                % 添加 Yes 按钮
                uibutton(fig, 'push', ...
                    'Position', [60 30 80 30], ...
                    'Text', 'Yes', ...
                    'ButtonPushedFcn', @(btn, event) yesCallback(btn, event, app, fig));

                % 添加 No 按钮
                uibutton(fig, 'push', ...
                    'Position', [160 30 80 30], ...
                    'Text', 'No', ...
                    'ButtonPushedFcn', @(btn, event) noCallback(btn, event, fig));
            end

            % Yes 按钮回调函数
            function yesCallback(~, ~, app, fig)
                app.MainApp.DrawROI.clear_all_rois(); % 执行清除操作
                delete(fig); % 关闭对话框
            end

            % No 按钮回调函数
            function noCallback(~, ~, fig)
                delete(fig); % 仅关闭对话框
            end
        end

        % Value changed function: DragROIsButton
        function DragROIsButtonValueChanged(app, event)
            if ~isempty(app.MainApp.DrawROI)
                if app.DragROIsButton.Value
                    app.DragROIsButton.BackgroundColor = [0.8, 0.8, 1];
                    app.MainApp.DrawROI.set_drag_mode(true);
                else
                    app.DragROIsButton.BackgroundColor = [0.94, 0.94, 0.94];
                    app.MainApp.DrawROI.set_drag_mode(false);
                end
            else
                app.DragROIsButton.Value = false;
            end
        end

        % Button pushed function: ClearPatchButton
        function ClearPatchButtonPushed(app, event)
            app.MainApp.DrawROI.clear_patch_rois();
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.MainApp.ROIMaskSettingsApp = [];

            delete(app)
            
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
            app.UIFigure.Position = [100 100 249 404];
            app.UIFigure.Name = 'ROIMaskSettings';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.Position = [34 227 25 22];
            app.Label.Text = '';

            % Create ROIMaskStyleSettingsPanel
            app.ROIMaskStyleSettingsPanel = uipanel(app.UIFigure);
            app.ROIMaskStyleSettingsPanel.Title = 'ROI Mask Style Settings';
            app.ROIMaskStyleSettingsPanel.Position = [5 295 239 106];

            % Create MaskColorDropDownLabel
            app.MaskColorDropDownLabel = uilabel(app.ROIMaskStyleSettingsPanel);
            app.MaskColorDropDownLabel.Position = [13 57 66 22];
            app.MaskColorDropDownLabel.Text = 'Mask Color';

            % Create MaskColorDropDown
            app.MaskColorDropDown = uidropdown(app.ROIMaskStyleSettingsPanel);
            app.MaskColorDropDown.Items = {'Fixed', 'Random'};
            app.MaskColorDropDown.ValueChangedFcn = createCallbackFcn(app, @MaskColorDropDownValueChanged, true);
            app.MaskColorDropDown.Position = [13 36 90 22];
            app.MaskColorDropDown.Value = 'Fixed';

            % Create ROIMaskColorEditField
            app.ROIMaskColorEditField = uieditfield(app.ROIMaskStyleSettingsPanel, 'text');
            app.ROIMaskColorEditField.ValueChangedFcn = createCallbackFcn(app, @ROIMaskColorEditFieldValueChanged, true);
            app.ROIMaskColorEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ROIMaskColorEditField.Position = [109 36 63 22];
            app.ROIMaskColorEditField.Value = '#FF0000';

            % Create showROIMaskbackgroundCheckBox
            app.showROIMaskbackgroundCheckBox = uicheckbox(app.ROIMaskStyleSettingsPanel);
            app.showROIMaskbackgroundCheckBox.ValueChangedFcn = createCallbackFcn(app, @showROIMaskbackgroundCheckBoxValueChanged, true);
            app.showROIMaskbackgroundCheckBox.Text = 'show ROI Mask background';
            app.showROIMaskbackgroundCheckBox.Position = [13 15 173 22];

            % Create ROIMaskColorPickerButton
            app.ROIMaskColorPickerButton = uibutton(app.ROIMaskStyleSettingsPanel, 'push');
            app.ROIMaskColorPickerButton.ButtonPushedFcn = createCallbackFcn(app, @ROIMaskColorPickerButtonPushed, true);
            app.ROIMaskColorPickerButton.Icon = fullfile(pathToMLAPP, '+assets', 'color-picker.svg');
            app.ROIMaskColorPickerButton.Position = [183 35 25 23];
            app.ROIMaskColorPickerButton.Text = '';

            % Create ROIIDStyleSettingsPanel
            app.ROIIDStyleSettingsPanel = uipanel(app.UIFigure);
            app.ROIIDStyleSettingsPanel.Title = 'ROI ID Style Settings';
            app.ROIIDStyleSettingsPanel.Position = [5 168 239 120];

            % Create ROIIDFontSizeSpinnerLabel
            app.ROIIDFontSizeSpinnerLabel = uilabel(app.ROIIDStyleSettingsPanel);
            app.ROIIDFontSizeSpinnerLabel.Position = [13 67 92 22];
            app.ROIIDFontSizeSpinnerLabel.Text = 'ROI ID FontSize';

            % Create ROIIDFontSizeSpinner
            app.ROIIDFontSizeSpinner = uispinner(app.ROIIDStyleSettingsPanel);
            app.ROIIDFontSizeSpinner.ValueChangedFcn = createCallbackFcn(app, @ROIIDFontSizeSpinnerValueChanged, true);
            app.ROIIDFontSizeSpinner.Position = [117 67 53 22];
            app.ROIIDFontSizeSpinner.Value = 12;

            % Create ROIIDColorEditFieldLabel
            app.ROIIDColorEditFieldLabel = uilabel(app.ROIIDStyleSettingsPanel);
            app.ROIIDColorEditFieldLabel.Position = [13 34 74 22];
            app.ROIIDColorEditFieldLabel.Text = 'ROI ID Color';

            % Create ROIIDColorEditField
            app.ROIIDColorEditField = uieditfield(app.ROIIDStyleSettingsPanel, 'text');
            app.ROIIDColorEditField.ValueChangedFcn = createCallbackFcn(app, @ROIIDColorEditFieldValueChanged, true);
            app.ROIIDColorEditField.Position = [98 34 63 22];
            app.ROIIDColorEditField.Value = '#FFFF00';

            % Create showROIIDCheckBox
            app.showROIIDCheckBox = uicheckbox(app.ROIIDStyleSettingsPanel);
            app.showROIIDCheckBox.ValueChangedFcn = createCallbackFcn(app, @showROIIDCheckBoxValueChanged, true);
            app.showROIIDCheckBox.Text = 'show ROI ID';
            app.showROIIDCheckBox.Position = [13 5 90 22];

            % Create ROIIDColorPickerButton
            app.ROIIDColorPickerButton = uibutton(app.ROIIDStyleSettingsPanel, 'push');
            app.ROIIDColorPickerButton.ButtonPushedFcn = createCallbackFcn(app, @ROIIDColorPickerButtonPushed, true);
            app.ROIIDColorPickerButton.Icon = fullfile(pathToMLAPP, '+assets', 'color-picker.svg');
            app.ROIIDColorPickerButton.Position = [169 33 25 23];
            app.ROIIDColorPickerButton.Text = '';

            % Create AddRegularROIPanel
            app.AddRegularROIPanel = uipanel(app.UIFigure);
            app.AddRegularROIPanel.Title = 'Add Regular ROI';
            app.AddRegularROIPanel.Position = [5 99 240 60];

            % Create RectButton
            app.RectButton = uibutton(app.AddRegularROIPanel, 'push');
            app.RectButton.ButtonPushedFcn = createCallbackFcn(app, @RectButtonPushed, true);
            app.RectButton.Icon = fullfile(pathToMLAPP, '+assets', '形状-矩形.svg');
            app.RectButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.RectButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RectButton.Position = [10 8 103 23];
            app.RectButton.Text = 'Rect';

            % Create CircleButton
            app.CircleButton = uibutton(app.AddRegularROIPanel, 'push');
            app.CircleButton.ButtonPushedFcn = createCallbackFcn(app, @CircleButtonPushed, true);
            app.CircleButton.Icon = fullfile(pathToMLAPP, '+assets', '形状-椭圆形.svg');
            app.CircleButton.Position = [131 8 100 23];
            app.CircleButton.Text = 'Circle';

            % Create AdjustROIPanel
            app.AdjustROIPanel = uipanel(app.UIFigure);
            app.AdjustROIPanel.Title = 'Adjust ROI';
            app.AdjustROIPanel.Position = [5 5 240 88];

            % Create ReorderROIsButton
            app.ReorderROIsButton = uibutton(app.AdjustROIPanel, 'push');
            app.ReorderROIsButton.ButtonPushedFcn = createCallbackFcn(app, @ReorderROIsButtonPushed, true);
            app.ReorderROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'reorder.svg');
            app.ReorderROIsButton.HorizontalAlignment = 'left';
            app.ReorderROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ReorderROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ReorderROIsButton.Position = [11 37 103 23];
            app.ReorderROIsButton.Text = 'Reorder ROIs';

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.AdjustROIPanel, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.Icon = fullfile(pathToMLAPP, '+assets', 'clear.svg');
            app.ClearAllButton.HorizontalAlignment = 'left';
            app.ClearAllButton.Position = [131 8 100 23];
            app.ClearAllButton.Text = 'Clear All';

            % Create ClearPatchButton
            app.ClearPatchButton = uibutton(app.AdjustROIPanel, 'push');
            app.ClearPatchButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPatchButtonPushed, true);
            app.ClearPatchButton.Icon = fullfile(pathToMLAPP, '+assets', 'clear.svg');
            app.ClearPatchButton.HorizontalAlignment = 'left';
            app.ClearPatchButton.Position = [12 8 100 23];
            app.ClearPatchButton.Text = 'Clear Patch';

            % Create DragROIsButton
            app.DragROIsButton = uibutton(app.AdjustROIPanel, 'state');
            app.DragROIsButton.ValueChangedFcn = createCallbackFcn(app, @DragROIsButtonValueChanged, true);
            app.DragROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'drag.svg');
            app.DragROIsButton.HorizontalAlignment = 'left';
            app.DragROIsButton.Text = 'Drag ROIs';
            app.DragROIsButton.Position = [131 36 100 23];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ROIMaskSettings_exported(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
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