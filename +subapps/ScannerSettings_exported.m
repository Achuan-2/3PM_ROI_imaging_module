classdef ScannerSettings_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ClocktoTrggerDropDown       matlab.ui.control.DropDown
        ClocktoTrggerDropDownLabel  matlab.ui.control.Label
        ImageSizeDropDown           matlab.ui.control.DropDown
        ImageSizeDropDownLabel      matlab.ui.control.Label
        UpdateButton                matlab.ui.control.Button
        ScanBackRightSpinner        matlab.ui.control.Spinner
        ScanBackLeftSpinner         matlab.ui.control.Spinner
        ScanPulsePerPixelSpinner    matlab.ui.control.Spinner
        ScanWaitSpinner             matlab.ui.control.Spinner
        PulsePerPixelLabel          matlab.ui.control.Label
        WaitpulseLabel              matlab.ui.control.Label
        ScanBackEditField_2Label    matlab.ui.control.Label
        ScanSpaceLeftLabel          matlab.ui.control.Label
    end

    
    properties (Access = private)
        MainApp; % Description
    end
    
    methods (Access = public)
        
        function variableInit(app)
            imageSize = app.MainApp.scannerConfig.imageSize;
            pulsePerPixel = app.MainApp.scannerConfig.pulsePerPixel;
            scanWait = app.MainApp.scannerConfig.scanWait;
            scanBackLeftPixelTwice = app.MainApp.scannerConfig.scanBackLeftPixelTwice; % unit: pixel，scanleft和 scan right 也受到 pulsePerPixel 的影响
            scanBackRightPixelTwice = app.MainApp.scannerConfig.scanBackRightPixelTwice; % unit: pixel
            clockMode = app.MainApp.scannerConfig.clockMode;
            
            % 设置 imageSize

            app.ImageSizeDropDown.Value =imageSize;

            % 设置perlse per pixel
            app.ScanPulsePerPixelSpinner.Value = pulsePerPixel;

            % 设置 scanWait
            app.ScanWaitSpinner.Value = scanWait;

            % 设置 scanBackLeftPixelTwice
            app.ScanBackLeftSpinner.Value = scanBackLeftPixelTwice;

            % 设置 scanBackRightPixelTwice
            app.ScanBackRightSpinner.Value = scanBackRightPixelTwice;

            % 设置 clock mode
            app.ClocktoTrggerDropDown.Value =  clockMode;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MainApp)
           
            app.MainApp = MainApp;
            app.UIFigure.Position(1) = app.MainApp.UIFigure.Position(1)+app.MainApp.UIFigure.Position(3)+5;
            app.UIFigure.Position(2) = app.MainApp.UIFigure.Position(2);
            % 获取Mainapp的Scanner Settings,并修改Subapp的选项显示
            variableInit(app);

        end

        % Value changed function: ImageSizeDropDown
        function ImageSizeDropDownValueChanged(app, event)
            value = app.ImageSizeDropDown.Value;
            app.MainApp.scannerConfig.imageSize = value;
        end

        % Value changed function: ScanPulsePerPixelSpinner
        function ScanPulsePerPixelSpinnerValueChanged(app, event)
            value = app.ScanPulsePerPixelSpinner.Value;
            app.MainApp.scannerConfig.pulsePerPixel  = value;
        end

        % Value changed function: ScanWaitSpinner
        function ScanWaitSpinnerValueChanged(app, event)
            value = app.ScanWaitSpinner.Value;
            app.MainApp.scannerConfig.scanWait = value;
        end

        % Value changed function: ScanBackLeftSpinner
        function ScanBackLeftSpinnerValueChanged(app, event)
            value = app.ScanBackLeftSpinner.Value;
            app.MainApp.scannerConfig.scanBackLeftPixelTwice = value;
        end

        % Value changed function: ScanBackRightSpinner
        function ScanBackRightSpinnerValueChanged(app, event)
            value = app.ScanBackRightSpinner.Value;
            app.MainApp.scannerConfig.scanBackRightPixelTwice = value;
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.MainApp.ScannerSettingsApp = [];

            try
                delete(app);
            catch
                disp('error');
            end
            
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            % 读取hSI信号
            try
                hSI = evalin('base', 'hSI');
            catch
                uialert(app.UIFigure,"Please Start Scanimage First",'Warning','Icon','warning');
                return
            end    
            app.ImageSizeDropDown.Value = hSI.hRoiManager.pixelsPerLine; % 图像大小
            app.ScanPulsePerPixelSpinner.Value = hSI.hScan2D.pixelBinFactor; % 一个像素采样几次
            
            scanSpace = round(hSI.hRoiManager.linePeriod/hSI.hScan2D.scanPixelTimeMean-hSI.hRoiManager.pixelsPerLine); %计算Scan Left和Scan Right
            app.ScanBackLeftSpinner.Value = scanSpace;
            app.ScanBackRightSpinner.Value = scanSpace;


            % Update
            app.MainApp.scannerConfig.imageSize  = app.ImageSizeDropDown.Value;
            app.MainApp.scannerConfig.pulsePerPixel  = app.ScanPulsePerPixelSpinner.Value;
            app.MainApp.scannerConfig.scanBackLeftPixelTwice = app.ScanBackLeftSpinner.Value;
            app.MainApp.scannerConfig.scanBackRightPixelTwice = app.ScanBackRightSpinner.Value;
        end

        % Value changed function: ClocktoTrggerDropDown
        function ClocktoTrggerDropDownValueChanged(app, event)
            value = app.ClocktoTrggerDropDown.Value;
            app.MainApp.scannerConfig.clockMode= value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 232 287];
            app.UIFigure.Name = 'Scanner Settings';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ScanSpaceLeftLabel
            app.ScanSpaceLeftLabel = uilabel(app.UIFigure);
            app.ScanSpaceLeftLabel.Position = [9 96 103 22];
            app.ScanSpaceLeftLabel.Text = 'Scan Left*2 (pixel)';

            % Create ScanBackEditField_2Label
            app.ScanBackEditField_2Label = uilabel(app.UIFigure);
            app.ScanBackEditField_2Label.Position = [9 54 111 22];
            app.ScanBackEditField_2Label.Text = 'Scan Right*2 (pixel)';

            % Create WaitpulseLabel
            app.WaitpulseLabel = uilabel(app.UIFigure);
            app.WaitpulseLabel.Position = [9 138 69 22];
            app.WaitpulseLabel.Text = 'Wait (pulse)';

            % Create PulsePerPixelLabel
            app.PulsePerPixelLabel = uilabel(app.UIFigure);
            app.PulsePerPixelLabel.Position = [9 180 86 22];
            app.PulsePerPixelLabel.Text = 'Pulse Per Pixel';

            % Create ScanWaitSpinner
            app.ScanWaitSpinner = uispinner(app.UIFigure);
            app.ScanWaitSpinner.Limits = [0 Inf];
            app.ScanWaitSpinner.ValueDisplayFormat = '%.0f';
            app.ScanWaitSpinner.ValueChangedFcn = createCallbackFcn(app, @ScanWaitSpinnerValueChanged, true);
            app.ScanWaitSpinner.Position = [122 138 100 22];
            app.ScanWaitSpinner.Value = 56;

            % Create ScanPulsePerPixelSpinner
            app.ScanPulsePerPixelSpinner = uispinner(app.UIFigure);
            app.ScanPulsePerPixelSpinner.Limits = [1 Inf];
            app.ScanPulsePerPixelSpinner.ValueDisplayFormat = '%.0f';
            app.ScanPulsePerPixelSpinner.ValueChangedFcn = createCallbackFcn(app, @ScanPulsePerPixelSpinnerValueChanged, true);
            app.ScanPulsePerPixelSpinner.Position = [122 180 100 22];
            app.ScanPulsePerPixelSpinner.Value = 1;

            % Create ScanBackLeftSpinner
            app.ScanBackLeftSpinner = uispinner(app.UIFigure);
            app.ScanBackLeftSpinner.Limits = [0 Inf];
            app.ScanBackLeftSpinner.ValueDisplayFormat = '%.0f';
            app.ScanBackLeftSpinner.ValueChangedFcn = createCallbackFcn(app, @ScanBackLeftSpinnerValueChanged, true);
            app.ScanBackLeftSpinner.Position = [122 96 100 22];
            app.ScanBackLeftSpinner.Value = 55;

            % Create ScanBackRightSpinner
            app.ScanBackRightSpinner = uispinner(app.UIFigure);
            app.ScanBackRightSpinner.Limits = [0 Inf];
            app.ScanBackRightSpinner.ValueDisplayFormat = '%.0f';
            app.ScanBackRightSpinner.ValueChangedFcn = createCallbackFcn(app, @ScanBackRightSpinnerValueChanged, true);
            app.ScanBackRightSpinner.Position = [123 54 100 22];
            app.ScanBackRightSpinner.Value = 55;

            % Create UpdateButton
            app.UpdateButton = uibutton(app.UIFigure, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Position = [160 22 59 23];
            app.UpdateButton.Text = 'Update';

            % Create ImageSizeDropDownLabel
            app.ImageSizeDropDownLabel = uilabel(app.UIFigure);
            app.ImageSizeDropDownLabel.Position = [9 222 65 22];
            app.ImageSizeDropDownLabel.Text = 'Image Size';

            % Create ImageSizeDropDown
            app.ImageSizeDropDown = uidropdown(app.UIFigure);
            app.ImageSizeDropDown.Items = {'512*512', '256*256'};
            app.ImageSizeDropDown.ItemsData = [512 256];
            app.ImageSizeDropDown.ValueChangedFcn = createCallbackFcn(app, @ImageSizeDropDownValueChanged, true);
            app.ImageSizeDropDown.Position = [119 223 100 22];
            app.ImageSizeDropDown.Value = 512;

            % Create ClocktoTrggerDropDownLabel
            app.ClocktoTrggerDropDownLabel = uilabel(app.UIFigure);
            app.ClocktoTrggerDropDownLabel.HorizontalAlignment = 'right';
            app.ClocktoTrggerDropDownLabel.Position = [1 259 86 22];
            app.ClocktoTrggerDropDownLabel.Text = 'Clock to Trgger';

            % Create ClocktoTrggerDropDown
            app.ClocktoTrggerDropDown = uidropdown(app.UIFigure);
            app.ClocktoTrggerDropDown.Items = {'Line Clock', 'Frame Clock'};
            app.ClocktoTrggerDropDown.ValueChangedFcn = createCallbackFcn(app, @ClocktoTrggerDropDownValueChanged, true);
            app.ClocktoTrggerDropDown.Position = [119 259 100 22];
            app.ClocktoTrggerDropDown.Value = 'Line Clock';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ScannerSettings_exported(varargin)

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