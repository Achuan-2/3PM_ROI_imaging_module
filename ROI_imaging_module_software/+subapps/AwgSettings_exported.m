classdef AwgSettings_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        ExportSignalDropDown          matlab.ui.control.DropDown
        ExportSignalDropDownLabel     matlab.ui.control.Label
        DelaynsEditField              matlab.ui.control.NumericEditField
        DelaynsEditFieldLabel         matlab.ui.control.Label
        ExternalTriggerDropDown       matlab.ui.control.DropDown
        ExternalTriggerDropDownLabel  matlab.ui.control.Label
        SignalTypeDropDown            matlab.ui.control.DropDown
        ExportSignalPort              matlab.ui.control.EditField
        AwgTriggerPort                matlab.ui.control.EditField
        AwgExternalClockPort          matlab.ui.control.EditField
        SampleClockDropDown           matlab.ui.control.DropDown
        SampleClockLabel              matlab.ui.control.Label
        ArbOffsetEditField            matlab.ui.control.NumericEditField
        ArbOffsetEditFieldLabel       matlab.ui.control.Label
        ArbGainEditField              matlab.ui.control.NumericEditField
        GainEditFieldLabel            matlab.ui.control.Label
        SampleRateEditField           matlab.ui.control.NumericEditField
        SampleRateEditFieldLabel      matlab.ui.control.Label
        ArbModeDropDown               matlab.ui.control.DropDown
        TriggerModeLabel              matlab.ui.control.Label
        DeviceIDEditField             matlab.ui.control.EditField
        DeviceIDEditFieldLabel        matlab.ui.control.Label
    end

    
    properties (Access = private)
        MainApp; % Main App
    end
    
    methods (Access = public)
        
        function variableInit(app)
            resourceID = app.MainApp.waveformConfig.resourceID;
            gain = app.MainApp.waveformConfig.gain;
            offset = app.MainApp.waveformConfig.offset;
            sampleRate = app.MainApp.waveformConfig.sampleRate; % 1.0007 MHz
            delayTime = app.MainApp.waveformConfig.delayTime;
            mode = app.MainApp.waveformConfig.mode; % Stepped
            clockSource = app.MainApp.waveformConfig.clockSource; % 'OnboardClock' or 'ClkIn'
            triggerOn = app.MainApp.waveformConfig.triggerOn; % true or false
            triggerPort = app.MainApp.waveformConfig.triggerPort; % PFI0 or PFI1
            exportSignalOn = app.MainApp.waveformConfig.exportSignalOn; % true or false
            exportSignalType = app.MainApp.waveformConfig.exportSignalType; % Marker DataMarker
            exportSignalPort = app.MainApp.waveformConfig.exportSignalPort; % PFI0 or PFI1


            app.DeviceIDEditField.Value = resourceID;

            switch mode
                case 'Stepped'
                    app.ArbModeDropDown.Value = 'Stepped';
                case 'Continuous'
                    app.ArbModeDropDown.Value = 'Continuous';
                case 'Burst'
                    app.ArbModeDropDown.Value = 'Burst';
                case 'Single'
                    app.ArbModeDropDown.Value = 'Single';
            end

            switch clockSource
                case 'ClkIn'
                    app.AwgExternalClockPort.Visible = "on";
                    app.AwgExternalClockPort.Value = 'ClkIn';
                    app.SampleClockDropDown.Value = 'External';
                case 'OnboardClock'
                    app.AwgExternalClockPort.Visible = "off";
                    app.SampleClockDropDown.Value = 'Internal';
            end


            if triggerOn
                app.ExternalTriggerDropDown.Value = 'On';
                app.AwgTriggerPort.Visible = 'on';
                app.AwgTriggerPort.Value = triggerPort;

            else
                app.ExternalTriggerDropDown.Value = 'Off';
                app.AwgTriggerPort.Visible = 'off';
            end


            if exportSignalOn
                app.ExportSignalDropDown.Value = 'On';
                app.ExportSignalPort.Visible = 'on';
                app.ExportSignalPort.Value = exportSignalPort;
                app.SignalTypeDropDown.Visible = 'on';
                app.SignalTypeDropDown.Value = exportSignalType;

            else
                app.ExportSignalDropDown.Value = 'Off';
                app.ExportSignalPort.Visible = 'off';
                app.SignalTypeDropDown.Visible = 'off';
            end


            app.ArbGainEditField.Value  = gain;
            app.ArbOffsetEditField.Value = offset;
            app.SampleRateEditField.Value = sampleRate;
            app.DelaynsEditField.Value = delayTime;

            
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MainApp)
            app.MainApp = MainApp;
            app.UIFigure.Position(1) = app.MainApp.UIFigure.Position(1)+app.MainApp.UIFigure.Position(3)+5;
            app.UIFigure.Position(2) = app.MainApp.UIFigure.Position(2)+app.MainApp.UIFigure.Position(4)-app.UIFigure.Position(4);

            % 获取Mainapp的AWG Settings,并修改Subapp的选项显示
            app.variableInit();
        end

        % Value changed function: SampleClockDropDown
        function SampleClockDropDownValueChanged(app, event)
            sampleClockSource = app.SampleClockDropDown.Value;
            switch sampleClockSource 
               case 'Internal'
                  app.AwgExternalClockPort.Visible = "off";
                  app.MainApp.waveformConfig.clockSource = 'OnboardClock';
               case 'External'
                  app.AwgExternalClockPort.Visible = "on";
                  app.MainApp.waveformConfig.clockSource = 'ClkIn';
               otherwise
                  app.AwgExternalClockPort.Visible = "off";
                  app.MainApp.waveformConfig.clockSource = 'OnboardClock';
            end
        end

        % Value changed function: ExternalTriggerDropDown
        function ExternalTriggerDropDownValueChanged(app, event)
            value = app.ExternalTriggerDropDown.Value;
            if value == "On"
                app.AwgTriggerPort.Visible = "on";
                app.MainApp.waveformConfig.triggerOn = true;
                app.MainApp.waveformConfig.triggerPort = app.AwgTriggerPort.Value;
            else
                app.AwgTriggerPort.Visible = "off";
                app.MainApp.waveformConfig.triggerOn = false;
            end
        end

        % Value changed function: ExportSignalDropDown
        function ExportSignalDropDownValueChanged(app, event)
            valueExportSignal = app.ExportSignalDropDown.Value;
            if valueExportSignal == "On"
                app.ExportSignalPort.Visible = "on";
                app.SignalTypeDropDown.Visible = "on";
                app.MainApp.waveformConfig.exportSignalOn = true;
                app.MainApp.waveformConfig.exportSignalType = app.SignalTypeDropDown.Value;
                app.MainApp.waveformConfig.exportSignalPort = app.ExportSignalPort.Value;
            else
                app.ExportSignalPort.Visible = "off";
                app.SignalTypeDropDown.Visible = "off";
                app.MainApp.waveformConfig.exportSignalOn = false;
            end
        end

        % Value changed function: ArbModeDropDown
        function ArbModeDropDownValueChanged(app, event)
            value = app.ArbModeDropDown.Value;
            app.MainApp.waveformConfig.mode = value;
        end

        % Value changed function: DeviceIDEditField
        function DeviceIDEditFieldValueChanged(app, event)
            value = app.DeviceIDEditField.Value;
            app.MainApp.waveformConfig.resourceID = value;
        end

        % Value changed function: AwgTriggerPort
        function AwgTriggerPortValueChanged(app, event)
            value = app.AwgTriggerPort.Value;
                            app.MainApp.waveformConfig.triggerPort = value;
        end

        % Value changed function: ExportSignalPort
        function ExportSignalPortValueChanged(app, event)
            value = app.ExportSignalPort.Value;
            app.MainApp.waveformConfig.exportSignalType = value;
        end

        % Value changed function: SignalTypeDropDown
        function SignalTypeDropDownValueChanged(app, event)
        value = app.SignalTypeDropDown.Value;
            app.MainApp.waveformConfig.exportSignalPort = value;
        end

        % Value changed function: ArbGainEditField
        function ArbGainEditFieldValueChanged(app, event)
            value = app.ArbGainEditField.Value;
            app.MainApp.waveformConfig.gain = value;
        end

        % Value changed function: ArbOffsetEditField
        function ArbOffsetEditFieldValueChanged(app, event)
            value = app.ArbOffsetEditField.Value;
            app.MainApp.waveformConfig.offset = value;
        end

        % Value changed function: SampleRateEditField
        function SampleRateEditFieldValueChanged(app, event)
            value = app.SampleRateEditField.Value;
            app.MainApp.waveformConfig.sampleRate = value;
        end

        % Value changed function: DelaynsEditField
        function DelaynsEditFieldValueChanged(app, event)
            value = app.DelaynsEditField.Value;
            app.MainApp.waveformConfig.delayTime = value;
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.MainApp.AwgSettingsApp = [];

            try
                delete(app);
            catch
                disp('error');
            end

            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 306 310];
            app.UIFigure.Name = 'AWG Settings';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create DeviceIDEditFieldLabel
            app.DeviceIDEditFieldLabel = uilabel(app.UIFigure);
            app.DeviceIDEditFieldLabel.Position = [7 281 57 22];
            app.DeviceIDEditFieldLabel.Text = 'Device ID';

            % Create DeviceIDEditField
            app.DeviceIDEditField = uieditfield(app.UIFigure, 'text');
            app.DeviceIDEditField.ValueChangedFcn = createCallbackFcn(app, @DeviceIDEditFieldValueChanged, true);
            app.DeviceIDEditField.HorizontalAlignment = 'center';
            app.DeviceIDEditField.Position = [130 281 83 21];
            app.DeviceIDEditField.Value = 'Dev1';

            % Create TriggerModeLabel
            app.TriggerModeLabel = uilabel(app.UIFigure);
            app.TriggerModeLabel.Position = [7 243 76 22];
            app.TriggerModeLabel.Text = 'Trigger Mode';

            % Create ArbModeDropDown
            app.ArbModeDropDown = uidropdown(app.UIFigure);
            app.ArbModeDropDown.Items = {'Continuous', 'Single', 'Burst', 'Stepped'};
            app.ArbModeDropDown.ValueChangedFcn = createCallbackFcn(app, @ArbModeDropDownValueChanged, true);
            app.ArbModeDropDown.Position = [125 243 100 22];
            app.ArbModeDropDown.Value = 'Stepped';

            % Create SampleRateEditFieldLabel
            app.SampleRateEditFieldLabel = uilabel(app.UIFigure);
            app.SampleRateEditFieldLabel.Position = [8 57 110 22];
            app.SampleRateEditFieldLabel.Text = 'Sampling Rate (Hz)';

            % Create SampleRateEditField
            app.SampleRateEditField = uieditfield(app.UIFigure, 'numeric');
            app.SampleRateEditField.Limits = [10 1000000000];
            app.SampleRateEditField.ValueChangedFcn = createCallbackFcn(app, @SampleRateEditFieldValueChanged, true);
            app.SampleRateEditField.Position = [128 57 100 22];
            app.SampleRateEditField.Value = 1000000;

            % Create GainEditFieldLabel
            app.GainEditFieldLabel = uilabel(app.UIFigure);
            app.GainEditFieldLabel.Position = [8 131 50 22];
            app.GainEditFieldLabel.Text = 'Gain (V)';

            % Create ArbGainEditField
            app.ArbGainEditField = uieditfield(app.UIFigure, 'numeric');
            app.ArbGainEditField.Limits = [0.0028175 6];
            app.ArbGainEditField.ValueChangedFcn = createCallbackFcn(app, @ArbGainEditFieldValueChanged, true);
            app.ArbGainEditField.Position = [128 131 100 22];
            app.ArbGainEditField.Value = 3.3;

            % Create ArbOffsetEditFieldLabel
            app.ArbOffsetEditFieldLabel = uilabel(app.UIFigure);
            app.ArbOffsetEditFieldLabel.Position = [8 94 56 22];
            app.ArbOffsetEditFieldLabel.Text = 'Offset (V)';

            % Create ArbOffsetEditField
            app.ArbOffsetEditField = uieditfield(app.UIFigure, 'numeric');
            app.ArbOffsetEditField.Limits = [-3 3];
            app.ArbOffsetEditField.ValueChangedFcn = createCallbackFcn(app, @ArbOffsetEditFieldValueChanged, true);
            app.ArbOffsetEditField.Position = [128 94 100 22];

            % Create SampleClockLabel
            app.SampleClockLabel = uilabel(app.UIFigure);
            app.SampleClockLabel.Position = [7 205 89 22];
            app.SampleClockLabel.Text = 'Sampling Clock';

            % Create SampleClockDropDown
            app.SampleClockDropDown = uidropdown(app.UIFigure);
            app.SampleClockDropDown.Items = {'Internal', 'External'};
            app.SampleClockDropDown.ValueChangedFcn = createCallbackFcn(app, @SampleClockDropDownValueChanged, true);
            app.SampleClockDropDown.Position = [125 205 100 22];
            app.SampleClockDropDown.Value = 'External';

            % Create AwgExternalClockPort
            app.AwgExternalClockPort = uieditfield(app.UIFigure, 'text');
            app.AwgExternalClockPort.HorizontalAlignment = 'center';
            app.AwgExternalClockPort.Position = [237 206 60 21];
            app.AwgExternalClockPort.Value = 'ClkIn';

            % Create AwgTriggerPort
            app.AwgTriggerPort = uieditfield(app.UIFigure, 'text');
            app.AwgTriggerPort.ValueChangedFcn = createCallbackFcn(app, @AwgTriggerPortValueChanged, true);
            app.AwgTriggerPort.HorizontalAlignment = 'center';
            app.AwgTriggerPort.Position = [237 169 60 19];
            app.AwgTriggerPort.Value = 'PFI0';

            % Create ExportSignalPort
            app.ExportSignalPort = uieditfield(app.UIFigure, 'text');
            app.ExportSignalPort.ValueChangedFcn = createCallbackFcn(app, @ExportSignalPortValueChanged, true);
            app.ExportSignalPort.HorizontalAlignment = 'center';
            app.ExportSignalPort.Position = [237 -108 60 19];
            app.ExportSignalPort.Value = 'PFI1';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.UIFigure);
            app.SignalTypeDropDown.Items = {'Marker', 'DataMarker'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.Position = [311 -109 100 22];
            app.SignalTypeDropDown.Value = 'DataMarker';

            % Create ExternalTriggerDropDownLabel
            app.ExternalTriggerDropDownLabel = uilabel(app.UIFigure);
            app.ExternalTriggerDropDownLabel.Position = [7 167 90 22];
            app.ExternalTriggerDropDownLabel.Text = 'External Trigger';

            % Create ExternalTriggerDropDown
            app.ExternalTriggerDropDown = uidropdown(app.UIFigure);
            app.ExternalTriggerDropDown.Items = {'Off', 'On'};
            app.ExternalTriggerDropDown.ValueChangedFcn = createCallbackFcn(app, @ExternalTriggerDropDownValueChanged, true);
            app.ExternalTriggerDropDown.Position = [125 167 100 22];
            app.ExternalTriggerDropDown.Value = 'On';

            % Create DelaynsEditFieldLabel
            app.DelaynsEditFieldLabel = uilabel(app.UIFigure);
            app.DelaynsEditFieldLabel.Position = [8 20 60 22];
            app.DelaynsEditFieldLabel.Text = 'Delay (ns)';

            % Create DelaynsEditField
            app.DelaynsEditField = uieditfield(app.UIFigure, 'numeric');
            app.DelaynsEditField.ValueChangedFcn = createCallbackFcn(app, @DelaynsEditFieldValueChanged, true);
            app.DelaynsEditField.Position = [128 20 100 22];

            % Create ExportSignalDropDownLabel
            app.ExportSignalDropDownLabel = uilabel(app.UIFigure);
            app.ExportSignalDropDownLabel.Position = [7 -110 80 22];
            app.ExportSignalDropDownLabel.Text = 'Export  Signal';

            % Create ExportSignalDropDown
            app.ExportSignalDropDown = uidropdown(app.UIFigure);
            app.ExportSignalDropDown.Items = {'Off', 'On'};
            app.ExportSignalDropDown.ValueChangedFcn = createCallbackFcn(app, @ExportSignalDropDownValueChanged, true);
            app.ExportSignalDropDown.Position = [125 -110 100 22];
            app.ExportSignalDropDown.Value = 'On';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AwgSettings_exported(varargin)

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