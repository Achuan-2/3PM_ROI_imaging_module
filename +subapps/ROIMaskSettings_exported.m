classdef ROIMaskSettings_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ROIIDStyleSettingsPanel        matlab.ui.container.Panel
        ColorPickerButton_2            matlab.ui.control.Button
        showROIIDCheckBox              matlab.ui.control.CheckBox
        ROIIDColorEditField            matlab.ui.control.EditField
        ROIIDColorEditFieldLabel       matlab.ui.control.Label
        ROIIDFontSizeEditField         matlab.ui.control.NumericEditField
        ROIIDFontSizeEditFieldLabel    matlab.ui.control.Label
        ROIMaskColorSettingsPanel      matlab.ui.container.Panel
        ColorPickerButton              matlab.ui.control.Button
        showROIMaskbackgroundCheckBox  matlab.ui.control.CheckBox
        ROIMaskColorEditField          matlab.ui.control.EditField
        MaskColorDropDown              matlab.ui.control.DropDown
        MaskColorDropDownLabel         matlab.ui.control.Label
        DragROIsButton                 matlab.ui.control.StateButton
        ReorderROIsButton              matlab.ui.control.Button
        Label                          matlab.ui.control.Label
    end

    
    properties (Access = private)
        mainApp; % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            app.mainApp = mainApp;
            % 让副app的位置随着主app走
            app.UIFigure.Position(1) = app.mainApp.UIFigure.Position(1)+app.mainApp.UIFigure.Position(3);
            app.UIFigure.Position(2) = app.mainApp.UIFigure.Position(2)+app.mainApp.UIFigure.Position(4)-app.UIFigure.Position(4);

            % 根据DrawROI的值进行初始化

            % 根据DrawROI的值进行初始化
            if ~isempty(app.mainApp.DrawROI)
                % 初始化ROI ID显示设置
                app.showROIIDCheckBox.Value = app.mainApp.DrawROI.showRoiNumber;
                app.ROIIDFontSizeEditField.Value = app.mainApp.DrawROI.roi_number_fontSize;
                if isnumeric(app.mainApp.DrawROI.roi_number_fontColor)
                    app.ROIIDColorEditField.Value = utils.matrix2hex(app.mainApp.DrawROI.roi_number_fontColor);
                else
                    app.ROIIDColorEditField.Value = app.mainApp.DrawROI.roi_number_fontColor;
                end
                    
                
                % 初始化ROI Mask背景设置
                app.showROIMaskbackgroundCheckBox.Value = app.mainApp.DrawROI.show_background;
                
                % 初始化ROI Mask颜色设置
                if ischar(app.mainApp.DrawROI.mask_color) && strcmp(app.mainApp.DrawROI.mask_color, 'Random')
                    app.MaskColorDropDown.Value = 'Random';
                    app.ROIMaskColorEditField.Visible = 'off';
                else
                    app.MaskColorDropDown.Value = 'Fixed';
                    app.ROIMaskColorEditField.Visible = 'on';
                    if isnumeric(app.mainApp.DrawROI.mask_color)
                        % 如果是RGB数值，转换为hex格式
                        app.ROIMaskColorEditField.Value = utils.matrix2hex(app.mainApp.DrawROI.mask_color);
                    else
                        app.ROIMaskColorEditField.Value = app.mainApp.DrawROI.mask_color;
                    end
                end
            end
        end

        % Value changed function: MaskColorDropDown
        function MaskColorDropDownValueChanged(app, event)
            value = app.MaskColorDropDown.Value;
            switch value
                case 'Fixed'
                    app.ROIMaskColorEditField.Visible = 'on';
                    if ~isempty(app.mainApp.DrawROI)
                        app.mainApp.DrawROI.mask_color = app.ROIMaskColorEditField.Value;
                    end
                case 'Random'
                    app.ROIMaskColorEditField.Visible = 'off';
                    app.mainApp.DrawROI.mask_color = 'Random';
            end
        end

        % Value changed function: ROIMaskColorEditField
        function ROIMaskColorEditFieldValueChanged(app, event)

                % 更改mask颜色将直接更新mask颜色
            if ~isempty(app.mainApp.DrawROI)
                app.mainApp.DrawROI.mask_color = utils.hex2matrix(app.ROIMaskColorEditField.Value);
                app.mainApp.MaskOnCheckBox.Value = true;
                app.mainApp.DrawROI.update_roi_color()
            end
        end

        % Value changed function: ROIIDFontSizeEditField
        function ROIIDFontSizeEditFieldValueChanged(app, event)

            if ~isempty(app.mainApp.DrawROI)
                value = app.ROIIDFontSizeEditField.Value;
                app.mainApp.DrawROI.roi_number_fontSize = value;
                app.mainApp.MaskOnCheckBox.Value = true;
            end
        end

        % Value changed function: ROIIDColorEditField
        function ROIIDColorEditFieldValueChanged(app, event)
            
             if ~isempty(app.mainApp.DrawROI)
                value = app.ROIIDColorEditField.Value;
                app.mainApp.DrawROI.roi_number_fontColor  = value;
                app.mainApp.MaskOnCheckBox.Value = true;

            end
        end

        % Value changed function: showROIMaskbackgroundCheckBox
        function showROIMaskbackgroundCheckBoxValueChanged(app, event)
         if ~isempty(app.mainApp.DrawROI)
            value = app.showROIMaskbackgroundCheckBox.Value;
            app.mainApp.DrawROI.show_background = value;
         end
        end

        % Value changed function: showROIIDCheckBox
        function showROIIDCheckBoxValueChanged(app, event)
            if ~isempty(app.mainApp.DrawROI)
                app.mainApp.DrawROI.showRoiNumber = app.showROIIDCheckBox.Value;
            end
        end

        % Value changed function: DragROIsButton
        function DragROIsButtonValueChanged(app, event)
            if ~isempty(app.mainApp.DrawROI)
                if app.DragROIsButton.Value
                    app.DragROIsButton.BackgroundColor = [0.8, 0.8, 1];
                    app.mainApp.DrawROI.set_drag_mode(true);
                else
                    app.DragROIsButton.BackgroundColor = [0.94, 0.94, 0.94];
                    app.mainApp.DrawROI.set_drag_mode(false);
                end
            else
                app.DragROIsButton.Value = false;
            end
        end

        % Button pushed function: ReorderROIsButton
        function ReorderROIsButtonPushed(app, event)
            if isempty(app.mainApp.DrawROI.roi_contours) || length(app.mainApp.DrawROI.roi_contours) < 2
                return;
            end
            try
                app.mainApp.DrawROI.reorder_rois();
                disp(['Reordered ' num2str(length(app.mainApp.DrawROI.roi_contours)) ' ROIs.']);
            catch ME
                errordlg(['Reorder ROIs error: ' ME.message], 'Error');
                disp(ME.getReport('extended'));
            end
        end

        % Button pushed function: ColorPickerButton
        function ColorPickerButtonPushed(app, event)
            currentColor = utils.hex2matrix(app.ROIMaskColorEditField.Value);
            selectedColor = uisetcolor(currentColor, 'Select ROI Mask Color');
            if ~isequal(selectedColor, 0) && ~isequal(selectedColor, currentColor) % Check if a color was selected and it's different
                app.ROIMaskColorEditField.Value = utils.matrix2hex(selectedColor);
                app.ROIMaskColorEditFieldValueChanged(); % update color
            end
        end

        % Button pushed function: ColorPickerButton_2
        function ColorPickerButton_2Pushed(app, event)
            currentColor = utils.hex2matrix(app.ROIIDColorEditField.Value);
            selectedColor = uisetcolor(currentColor, 'Select ROI ID Color');
            if ~isequal(selectedColor, 0) && ~isequal(selectedColor, currentColor) % Check if a color was selected and it's different
                app.ROIIDColorEditField.Value = utils.matrix2hex(selectedColor);
                app.ROIIDColorEditFieldValueChanged(); % update color
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
            app.UIFigure.Position = [100 100 256 315];
            app.UIFigure.Name = 'ROIMaskSettings';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.Position = [34 142 25 22];
            app.Label.Text = '';

            % Create ReorderROIsButton
            app.ReorderROIsButton = uibutton(app.UIFigure, 'push');
            app.ReorderROIsButton.ButtonPushedFcn = createCallbackFcn(app, @ReorderROIsButtonPushed, true);
            app.ReorderROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'reorder.svg');
            app.ReorderROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ReorderROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ReorderROIsButton.Position = [12 21 103 23];
            app.ReorderROIsButton.Text = 'Reorder ROIs';

            % Create DragROIsButton
            app.DragROIsButton = uibutton(app.UIFigure, 'state');
            app.DragROIsButton.ValueChangedFcn = createCallbackFcn(app, @DragROIsButtonValueChanged, true);
            app.DragROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'drag.svg');
            app.DragROIsButton.Text = 'Drag ROIs';
            app.DragROIsButton.Position = [150 21 91 23];

            % Create ROIMaskColorSettingsPanel
            app.ROIMaskColorSettingsPanel = uipanel(app.UIFigure);
            app.ROIMaskColorSettingsPanel.Title = 'ROI Mask Color Settings';
            app.ROIMaskColorSettingsPanel.Position = [6 210 239 106];

            % Create MaskColorDropDownLabel
            app.MaskColorDropDownLabel = uilabel(app.ROIMaskColorSettingsPanel);
            app.MaskColorDropDownLabel.Position = [13 57 66 22];
            app.MaskColorDropDownLabel.Text = 'Mask Color';

            % Create MaskColorDropDown
            app.MaskColorDropDown = uidropdown(app.ROIMaskColorSettingsPanel);
            app.MaskColorDropDown.Items = {'Fixed', 'Random'};
            app.MaskColorDropDown.ValueChangedFcn = createCallbackFcn(app, @MaskColorDropDownValueChanged, true);
            app.MaskColorDropDown.Position = [13 36 90 22];
            app.MaskColorDropDown.Value = 'Fixed';

            % Create ROIMaskColorEditField
            app.ROIMaskColorEditField = uieditfield(app.ROIMaskColorSettingsPanel, 'text');
            app.ROIMaskColorEditField.ValueChangedFcn = createCallbackFcn(app, @ROIMaskColorEditFieldValueChanged, true);
            app.ROIMaskColorEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ROIMaskColorEditField.Position = [109 36 63 22];
            app.ROIMaskColorEditField.Value = '#FF0000';

            % Create showROIMaskbackgroundCheckBox
            app.showROIMaskbackgroundCheckBox = uicheckbox(app.ROIMaskColorSettingsPanel);
            app.showROIMaskbackgroundCheckBox.ValueChangedFcn = createCallbackFcn(app, @showROIMaskbackgroundCheckBoxValueChanged, true);
            app.showROIMaskbackgroundCheckBox.Text = 'show ROI Mask background';
            app.showROIMaskbackgroundCheckBox.Position = [13 15 173 22];

            % Create ColorPickerButton
            app.ColorPickerButton = uibutton(app.ROIMaskColorSettingsPanel, 'push');
            app.ColorPickerButton.ButtonPushedFcn = createCallbackFcn(app, @ColorPickerButtonPushed, true);
            app.ColorPickerButton.Position = [185 35 35 23];
            app.ColorPickerButton.Text = 'Color Picker';

            % Create ROIIDStyleSettingsPanel
            app.ROIIDStyleSettingsPanel = uipanel(app.UIFigure);
            app.ROIIDStyleSettingsPanel.Title = 'ROI ID Style Settings';
            app.ROIIDStyleSettingsPanel.Position = [6 71 239 135];

            % Create ROIIDFontSizeEditFieldLabel
            app.ROIIDFontSizeEditFieldLabel = uilabel(app.ROIIDStyleSettingsPanel);
            app.ROIIDFontSizeEditFieldLabel.Position = [13 82 92 22];
            app.ROIIDFontSizeEditFieldLabel.Text = 'ROI ID FontSize';

            % Create ROIIDFontSizeEditField
            app.ROIIDFontSizeEditField = uieditfield(app.ROIIDStyleSettingsPanel, 'numeric');
            app.ROIIDFontSizeEditField.ValueChangedFcn = createCallbackFcn(app, @ROIIDFontSizeEditFieldValueChanged, true);
            app.ROIIDFontSizeEditField.Position = [117 82 28 22];
            app.ROIIDFontSizeEditField.Value = 12;

            % Create ROIIDColorEditFieldLabel
            app.ROIIDColorEditFieldLabel = uilabel(app.ROIIDStyleSettingsPanel);
            app.ROIIDColorEditFieldLabel.Position = [13 49 74 22];
            app.ROIIDColorEditFieldLabel.Text = 'ROI ID Color';

            % Create ROIIDColorEditField
            app.ROIIDColorEditField = uieditfield(app.ROIIDStyleSettingsPanel, 'text');
            app.ROIIDColorEditField.ValueChangedFcn = createCallbackFcn(app, @ROIIDColorEditFieldValueChanged, true);
            app.ROIIDColorEditField.Position = [98 49 63 22];
            app.ROIIDColorEditField.Value = '#FFFF00';

            % Create showROIIDCheckBox
            app.showROIIDCheckBox = uicheckbox(app.ROIIDStyleSettingsPanel);
            app.showROIIDCheckBox.ValueChangedFcn = createCallbackFcn(app, @showROIIDCheckBoxValueChanged, true);
            app.showROIIDCheckBox.Text = 'show ROI ID';
            app.showROIIDCheckBox.Position = [13 20 90 22];

            % Create ColorPickerButton_2
            app.ColorPickerButton_2 = uibutton(app.ROIIDStyleSettingsPanel, 'push');
            app.ColorPickerButton_2.ButtonPushedFcn = createCallbackFcn(app, @ColorPickerButton_2Pushed, true);
            app.ColorPickerButton_2.Position = [171 48 35 23];
            app.ColorPickerButton_2.Text = 'Color Picker';

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