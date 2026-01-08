classdef AWG_Control_2022b_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        AWGControlUIFigure            matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        SimulateCheckBox              matlab.ui.control.CheckBox
        ImpedanceDropDown             matlab.ui.control.DropDown
        ImpedanceDropDownLabel        matlab.ui.control.Label
        PauseButton                   matlab.ui.control.Button
        OutputButton                  matlab.ui.control.Button
        TabGroup                      matlab.ui.container.TabGroup
        StandardTab                   matlab.ui.container.Tab
        StartPhaseEditField           matlab.ui.control.NumericEditField
        StartPhaseEditFieldLabel      matlab.ui.control.Label
        OffsetEditField               matlab.ui.control.NumericEditField
        OffsetEditFieldLabel          matlab.ui.control.Label
        AmplitudeEditField            matlab.ui.control.NumericEditField
        AmplitudeEditFieldLabel       matlab.ui.control.Label
        FrequencyEditField            matlab.ui.control.NumericEditField
        FrequencyEditFieldLabel       matlab.ui.control.Label
        WaveformDropDown              matlab.ui.control.DropDown
        WaveformLabel                 matlab.ui.control.Label
        ArbitraryTab                  matlab.ui.container.Tab
        ArbFileLabel                  matlab.ui.control.Label
        ArbwaveformDropDown           matlab.ui.control.DropDown
        ArbwaveformDropDownLabel      matlab.ui.control.Label
        ExportsignalDropDown          matlab.ui.control.DropDown
        ExportsignalDropDownLabel     matlab.ui.control.Label
        DelayEditField                matlab.ui.control.NumericEditField
        DelaynsLabel                  matlab.ui.control.Label
        ExternaltriggerDropDown       matlab.ui.control.DropDown
        ExternaltriggerDropDownLabel  matlab.ui.control.Label
        SignalSourceDropDown          matlab.ui.control.DropDown
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
        TriggermodeLabel              matlab.ui.control.Label
        SelectFileButton              matlab.ui.control.Button
        AwgInitButton                 matlab.ui.control.Button
        AwgStatusLabel                matlab.ui.control.Label
        isconnectedLabel              matlab.ui.control.Label
        DeviceNameEditField           matlab.ui.control.EditField
        DeviceNameEditFieldLabel      matlab.ui.control.Label
        RightPanel                    matlab.ui.container.Panel
        UIAxes                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = public)
        awgDevice; % Description
        awgChanelName = '0';% Description
        awgConnected = 0;
        awgWaveInit = 0;
        awgArbFile;
        awgArbWave;
        Tab = 0;
        pulseOn = 0;
        pulseOff = 1;
    end
    
    
    
    methods (Access = private)
        
        function awg_enable_output(app)
            % awg 开启输出

            try
                initiateGeneration(app.awgDevice); 
                enable = true;
                configureOutputEnabled(app.awgDevice,app.awgChanelName,enable);
            catch ErrorInfo
                msgbox(ErrorInfo.message,'Warning','error');
                return
            end   
        end

        function awg_disable_output(app)
            % AWG 关闭输出
            try
                enable = false;
                configureOutputEnabled(app.awgDevice,app.awgChanelName,enable);
            catch ErrorInfo
                msgbox(ErrorInfo.message,'Warning','error');
                return
            end      
        end

        function ui_connect(app)
            % 连接设备后的UI
            app.isconnectedLabel.Text = 'Connected';
            app.awgConnected = 1;
            app.OutputButton.Enable = "on";
            %app.AwgRemoveButton.Enable = "on";
            %app.AwgInitButton.Enable = "off";


        end
        
        function ui_disconnect(app)
            % 移除设备后的UI

            app.awgConnected = 0;
            app.awgWaveInit=0;
            app.OutputButton.Enable = "off";
            app.PauseButton.Enable = "off";
            %.AwgRemoveButton.Enable = "off";
            %app.AwgInitButton.Enable = "on";

        end

        function awg_disconnect(app)
            delete(app.awgDevice);
            clear app.awgDevice;
            app.isconnectedLabel.Text = 'Disconnected';
        end

        function awg_init(app)
            % check AWG exsitence
            if app.awgConnected == 1
                reset(app.awgDevice);
                return 
            end
            % initialize the AWG
            resourceID = app.DeviceNameEditField.Value;
            try 
                if ~app.SimulateCheckBox.Value
                    app.awgDevice = ividev("NIFGEN",resourceID);
                else
                    app.awgDevice = ividev("NIFGEN","",Simulate=true);
                end
                % update ui
                ui_connect(app);
            catch
                msgbox("Can't not connect to the device",'Warning','error');
                return
            end

        end
        
        function awg_standard_waveform(app)
            frequency = app.FrequencyEditField.Value;
            dcOffset = app.OffsetEditField.Value;
            startPhase = app.StartPhaseEditField.Value;
            amplitude = app.AmplitudeEditField.Value;
            choose = app.WaveformDropDown.Value;
            
            switch choose
               case 'Sine'
                  waveMode = "WFM_SINE";
               case 'Square'
                  waveMode = "WFM_SQUARE";
                case 'Triangle'
                  waveMode = "WFM_TRIANGLE";
               case 'Ramp_up'
                  waveMode = "WFM_RAMP_UP";
               case 'Ramp_down'
                  waveMode = "WFM_RAMP_DOWN";
               case 'DC'
                  waveMode = "WFM_DC";
%                case 'Noise'
%                   waveMode = "WFM_NOISE";
               otherwise
                  waveMode = "WFM_SINE";
            end
            
            configureOutputMode(app.awgDevice,"OUTPUT_FUNC"); % set outputmode to func

            configureStandardWaveform(app.awgDevice,app.awgChanelName,waveMode,amplitude,dcOffset,frequency,startPhase);   
        end

        function awg_arb_waveform(app)
            % read parameters
            mode = upper(app.ArbModeDropDown.Value);
            sampleRate = app.SampleRateEditField.Value;
            gain = app.ArbGainEditField.Value;
            offset = app.ArbOffsetEditField.Value;
            adjustmentTime = app.DelayEditField.Value*1e-9;

            % generate waveform

            waveformHandle = create_waveform_handle(app,app.awgArbWave);

            % config
            configureOutputMode(app.awgDevice,"OUTPUT_ARB");

            configureSampleRate(app.awgDevice,sampleRate);
            

            % set clock: internal or external
            if app.SampleClockDropDown.Value == "External"
                % if use external sample clock ,you should notice that 
                try
                     configureSampleClockSource(app.awgDevice, app.AwgExternalClockPort.Value); 
                catch ErrorInfo
                    msgbox(ErrorInfo.message,'Warning','error');
                    return
                end   
            end
            
            % set colck delay
            adjustSampleClockRelativeDelay(app.awgDevice,adjustmentTime);
            %app.awgDevice.Clocks.Advanced.SampleClockAbsoluteDelay = adjustmentTime;
            %app.awgDevice.Advanced.externalClockDelayBinaryValue = adjustmentTime;
            % set AWG trigger
            if app.ExternaltriggerDropDown.Value == "On"
                try
                     configureDigitalEdgeStartTrigger(app.awgDevice,app.AwgTriggerPort.Value,"RISING_EDGE");
                catch ErrorInfo
                    msgbox(ErrorInfo.message,'Warning','error');
                    return
                end
            end
            
            % set export signal
            if app.ExportsignalDropDown.Value == "On"
                try
                     signalSource =  app.SignalSourceDropDown.Value;
                     switch signalSource
                         case "Marker"
                            app.awgDevice.ArbitraryWaveform.Mode.MarkerPosition = 0;
                            exportSignal(app.awgDevice,"MARKER_EVENT","Marker0",app.ExportSignalPort.Value);
                         case "DataMarker"
                            exportSignal(app.awgDevice,"DATA_MARKER_EVENT","DataMarker0",app.ExportSignalPort.Value);
                     end

                catch ErrorInfo
                    msgbox(ErrorInfo.message,'Warning','error');
                    return
                end
            end


%             
            % create Arb waveform
            configureArbWaveform(app.awgDevice, app.awgChanelName, waveformHandle, gain, offset);

            % set Trigger Mode
            configureTriggerMode(app.awgDevice, app.awgChanelName, mode);


        end

        function plot_figure(app)
            if app.Tab == 0 % standard waveform
                frequency = app.FrequencyEditField.Value;
                dcOffset = app.OffsetEditField.Value;
                startPhaseDeg = app.StartPhaseEditField.Value; % 因为是角度
                startPhaseRad = startPhaseDeg/180*pi; % 转化为弧度制
                amplitude = app.AmplitudeEditField.Value;
                
                duration = 1/frequency;
                x = 0:duration/100:10*duration;
                
                % 根据选择的波形模拟绘出对应的标准波形
                choose = app.WaveformDropDown.Value;
                switch choose
                   case 'Sine'
                      y = amplitude*sin(frequency*x+startPhaseRad)+dcOffset;
                   case 'Square'
                      y = amplitude*square(frequency*x+startPhaseRad)+dcOffset;
                    case 'Triangle'
                      y = amplitude*sawtooth(frequency*x+startPhaseRad,0.5)+dcOffset;
                   case 'Ramp_up'
                      y = amplitude*sawtooth(frequency*x+startPhaseRad,1)+dcOffset;
                   case 'Ramp_down'
                      y = amplitude*sawtooth(frequency*x+startPhaseRad,0)+dcOffset;
                   case 'DC'
                      y = x;
                      y(:) = dcOffset;
                end
                plot(app.UIAxes,x,y)
            else % arbitary waveform
                signal = app.awgArbWave;
                freq = app.SampleRateEditField.Value;
                gain = app.ArbGainEditField.Value;
                offset = app.ArbOffsetEditField.Value;
                y = gain*signal+offset;
                
                duration = 1/freq;
                % starir 最后一个点没有阶梯样式，所以需要额外复制最后一个元素
                y(end+1)=y(end);
                % 生成x轴时间坐标：之所以用循环生成时间是因为matlab用linspace，数值太小，只会生成0
                x = zeros(1,length(y));
                for iTime = 1:length(y)
                    x(iTime) = duration*(iTime-1);
                end
                stairs(app.UIAxes,x,y); % 绘制阶梯图
                app.UIAxes.YLim = [min(y)-0.1,max(y)+0.1];
            end
        end
        function [filename,path]= get_file(~,fileExtension)
  
                f_dummy = figure('Position', [-100 -100 0 0]); %create a dummy figure so that uigetfile doesn't minimize our GUI
                [filename,path] = uigetfile(fileExtension);
                delete(f_dummy); %delete the dummy figure

        end
        
        function waveformHandle = create_waveform_handle(app,waveformArray)
            waveformSize = length(waveformArray);
            waveformHandle = createWaveformF64(app.awgDevice, app.awgChanelName, waveformSize, waveformArray);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Button pushed function: AwgInitButton
        function AwgInitButtonPushed(app, event)
            
            if app.awgConnected == 1
                awg_disconnect(app);
                ui_disconnect(app);
                app.AwgInitButton.Text = "Connect";
            else
                awg_init(app);
                app.AwgInitButton.Text = "Disconnect";
            end
        end

        % Button pushed function: SelectFileButton
        function SelectFileButtonPushed(app, event)
            [filename,path] = get_file(app,{'*.csv';'*.txt'});

            if filename ~= 0 % 如果不选择文件返回为0
                app.ArbFileLabel.Text = filename;
                app.awgArbWave = reshape(table2array(readtable([path,filename])),[],1);
                if app.isconnectedLabel.Text == "Connected"
                    app.OutputButton.Enable = "on";
                end
            end

        end

        % Button down function: ArbitraryTab
        function ArbitraryTabButtonDown(app, event)
            app.Tab =1;
            % 当切换到ARB tab 的时候只有连接设备，且选择了文件才能点击output
            if app.isconnectedLabel.Text == "Connected" && ~isempty(app.awgArbWave)
                app.OutputButton.Enable = "on";
            else
                app.OutputButton.Enable = "off";
            end
        end

        % Button down function: StandardTab
        function StandardTabButtonDown(app, event)
            app.Tab =0;
            app.OutputButton.Enable = "on";
        end

        % Value changed function: SampleClockDropDown
        function SampleClockDropDownValueChanged(app, event)
            sampleClockSource = app.SampleClockDropDown.Value;
            switch sampleClockSource 
               case 'Internal'
                  app.AwgExternalClockPort.Visible = "off";
               case 'External'
                  app.AwgExternalClockPort.Visible = "on";
               otherwise
                  app.AwgExternalClockPort.Visible = "off";
            end
        end

        % Value changed function: ExternaltriggerDropDown
        function ExternaltriggerDropDownValueChanged(app, event)
            value = app.ExternaltriggerDropDown.Value;
            if value == "On"
                app.AwgTriggerPort.Enable = "on";
            else
                app.AwgTriggerPort.Enable = "off";
            end

        end

        % Button pushed function: OutputButton
        function OutputButtonPushed(app, event)

            reset(app.awgDevice); % 重置设备，方便重新输出
            
            % 设置波形
            if app.Tab==0
                awg_standard_waveform(app);
            else
                awg_arb_waveform(app);
            end
            
            app.PauseButton.Enable = "on";

            if app.ImpedanceDropDown.Value == "50"
               impedance = "VAL_50";
            else
               impedance = "VAL_75";
            end
            %设置阻抗
            configureOutputImpedance(app.awgDevice,app.awgChanelName,impedance);
            % 开启输出
            awg_enable_output(app);
            % 绘图模拟信号
            plot_figure(app);

        end

        % Button pushed function: PauseButton
        function PauseButtonPushed(app, event)
            % 暂停输出
            awg_disable_output(app);
            % 点击一次Pause之后按钮取消
            app.PauseButton.Enable = "off";
        end

        % Value changed function: ExportsignalDropDown
        function ExportsignalDropDownValueChanged(app, event)
            value = app.ExportsignalDropDown.Value;
            if value == "On"
                app.ExportSignalPort.Enable = "on";
                app.SignalSourceDropDown.Enable = "on";
            else
                app.ExportSignalPort.Enable = "off";
                app.SignalSourceDropDown.Enable = "off";
            end
        end

        % Value changed function: ArbwaveformDropDown
        function ArbwaveformDropDownValueChanged(app, event)
            value = app.ArbwaveformDropDown.Value;
            switch value
                case "1on9off"
                    tempWave = [repmat(app.pulseOn,1,1),repmat(app.pulseOff,1,9)];
                    app.awgArbWave = repmat(tempWave,1,2);
                    
                    hide_file_ui(app);
                case "1on1off"
                    tempWave = [app.pulseOn,app.pulseOff];
                    app.awgArbWave = repmat(tempWave,1,10);
                    hide_file_ui(app);
                case "5on5off"
                    tempWave = [repmat(app.pulseOn,1,5),repmat(app.pulseOff,1,5)];
                    app.awgArbWave = repmat(tempWave,1,2);
                    hide_file_ui(app);
                case "Keep On"
                    app.awgArbWave = repmat(app.pulseOn,1,20);
                    hide_file_ui(app);
                case "Keep Off"
                    app.awgArbWave = repmat(app.pulseOff,1,20);
                    hide_file_ui(app);
                case "Load File"
                    %  每次选择文件，wave清空
                    app.awgArbWave = [];
                    select_file_ui(app);


            end

            % update ui
            function select_file_ui(app)
                    app.SelectFileButton.Visible ="on";
                    app.ArbFileLabel.Visible = "on";
                    app.OutputButton.Enable = "off";
                    app.ArbFileLabel.Text = "";

                    
            end
            function hide_file_ui(app)
                    app.SelectFileButton.Visible ="off";
                    app.ArbFileLabel.Visible = "off";
                    app.OutputButton.Enable = "on";
            end


        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.AWGControlUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {547, 547};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {508, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create AWGControlUIFigure and hide until all components are created
            app.AWGControlUIFigure = uifigure('Visible', 'off');
            app.AWGControlUIFigure.AutoResizeChildren = 'off';
            app.AWGControlUIFigure.Position = [100 100 1030 547];
            app.AWGControlUIFigure.Name = 'AWG Control ';
            app.AWGControlUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.AWGControlUIFigure);
            app.GridLayout.ColumnWidth = {508, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create DeviceNameEditFieldLabel
            app.DeviceNameEditFieldLabel = uilabel(app.LeftPanel);
            app.DeviceNameEditFieldLabel.Position = [31 506 57 22];
            app.DeviceNameEditFieldLabel.Text = 'Device ID';

            % Create DeviceNameEditField
            app.DeviceNameEditField = uieditfield(app.LeftPanel, 'text');
            app.DeviceNameEditField.HorizontalAlignment = 'center';
            app.DeviceNameEditField.Position = [131 507 83 21];
            app.DeviceNameEditField.Value = 'Dev1';

            % Create isconnectedLabel
            app.isconnectedLabel = uilabel(app.LeftPanel);
            app.isconnectedLabel.Position = [131 471 83 22];
            app.isconnectedLabel.Text = 'Disconnected';

            % Create AwgStatusLabel
            app.AwgStatusLabel = uilabel(app.LeftPanel);
            app.AwgStatusLabel.Position = [31 471 39 22];
            app.AwgStatusLabel.Text = 'Status';

            % Create AwgInitButton
            app.AwgInitButton = uibutton(app.LeftPanel, 'push');
            app.AwgInitButton.ButtonPushedFcn = createCallbackFcn(app, @AwgInitButtonPushed, true);
            app.AwgInitButton.Position = [249 468 72 27];
            app.AwgInitButton.Text = 'Connect';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Position = [27 41 459 380];

            % Create StandardTab
            app.StandardTab = uitab(app.TabGroup);
            app.StandardTab.AutoResizeChildren = 'off';
            app.StandardTab.Title = 'Standard';
            app.StandardTab.ButtonDownFcn = createCallbackFcn(app, @StandardTabButtonDown, true);

            % Create WaveformLabel
            app.WaveformLabel = uilabel(app.StandardTab);
            app.WaveformLabel.Position = [52 306 59 22];
            app.WaveformLabel.Text = 'Waveform';

            % Create WaveformDropDown
            app.WaveformDropDown = uidropdown(app.StandardTab);
            app.WaveformDropDown.Items = {'Sine', 'Square', 'Triangle', 'Ramp_up', 'Ramp_down', 'DC'};
            app.WaveformDropDown.Position = [155 306 100 22];
            app.WaveformDropDown.Value = 'Sine';

            % Create FrequencyEditFieldLabel
            app.FrequencyEditFieldLabel = uilabel(app.StandardTab);
            app.FrequencyEditFieldLabel.Position = [52 266 88 22];
            app.FrequencyEditFieldLabel.Text = 'Frequency (Hz)';

            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.StandardTab, 'numeric');
            app.FrequencyEditField.Limits = [1 Inf];
            app.FrequencyEditField.Position = [156 266 100 22];
            app.FrequencyEditField.Value = 1000000;

            % Create AmplitudeEditFieldLabel
            app.AmplitudeEditFieldLabel = uilabel(app.StandardTab);
            app.AmplitudeEditFieldLabel.Position = [52 226 78 22];
            app.AmplitudeEditFieldLabel.Text = 'Amplitude (V)';

            % Create AmplitudeEditField
            app.AmplitudeEditField = uieditfield(app.StandardTab, 'numeric');
            app.AmplitudeEditField.Limits = [0 Inf];
            app.AmplitudeEditField.Position = [156 226 100 22];
            app.AmplitudeEditField.Value = 3.3;

            % Create OffsetEditFieldLabel
            app.OffsetEditFieldLabel = uilabel(app.StandardTab);
            app.OffsetEditFieldLabel.Position = [52 188 56 22];
            app.OffsetEditFieldLabel.Text = 'Offset (V)';

            % Create OffsetEditField
            app.OffsetEditField = uieditfield(app.StandardTab, 'numeric');
            app.OffsetEditField.Position = [157 188 100 22];

            % Create StartPhaseEditFieldLabel
            app.StartPhaseEditFieldLabel = uilabel(app.StandardTab);
            app.StartPhaseEditFieldLabel.Position = [52 151 83 22];
            app.StartPhaseEditFieldLabel.Text = 'Start phase (°)';

            % Create StartPhaseEditField
            app.StartPhaseEditField = uieditfield(app.StandardTab, 'numeric');
            app.StartPhaseEditField.Position = [157 151 100 22];

            % Create ArbitraryTab
            app.ArbitraryTab = uitab(app.TabGroup);
            app.ArbitraryTab.AutoResizeChildren = 'off';
            app.ArbitraryTab.Title = 'Arbitrary';
            app.ArbitraryTab.ButtonDownFcn = createCallbackFcn(app, @ArbitraryTabButtonDown, true);

            % Create SelectFileButton
            app.SelectFileButton = uibutton(app.ArbitraryTab, 'push');
            app.SelectFileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFileButtonPushed, true);
            app.SelectFileButton.Position = [261 318 61 23];
            app.SelectFileButton.Text = 'Select';

            % Create TriggermodeLabel
            app.TriggermodeLabel = uilabel(app.ArbitraryTab);
            app.TriggermodeLabel.Position = [30 285 76 22];
            app.TriggermodeLabel.Text = 'Trigger mode';

            % Create ArbModeDropDown
            app.ArbModeDropDown = uidropdown(app.ArbitraryTab);
            app.ArbModeDropDown.Items = {'Continuous', 'Single', 'Burst', 'Stepped'};
            app.ArbModeDropDown.Position = [150 285 100 22];
            app.ArbModeDropDown.Value = 'Continuous';

            % Create SampleRateEditFieldLabel
            app.SampleRateEditFieldLabel = uilabel(app.ArbitraryTab);
            app.SampleRateEditFieldLabel.Position = [30 57 105 22];
            app.SampleRateEditFieldLabel.Text = 'Sampling rate (Hz)';

            % Create SampleRateEditField
            app.SampleRateEditField = uieditfield(app.ArbitraryTab, 'numeric');
            app.SampleRateEditField.Limits = [10 1000000000];
            app.SampleRateEditField.Position = [150 57 100 22];
            app.SampleRateEditField.Value = 1000000;

            % Create GainEditFieldLabel
            app.GainEditFieldLabel = uilabel(app.ArbitraryTab);
            app.GainEditFieldLabel.Position = [30 133 50 22];
            app.GainEditFieldLabel.Text = 'Gain (V)';

            % Create ArbGainEditField
            app.ArbGainEditField = uieditfield(app.ArbitraryTab, 'numeric');
            app.ArbGainEditField.Limits = [0.0028175 6];
            app.ArbGainEditField.Position = [150 133 100 22];
            app.ArbGainEditField.Value = 3.3;

            % Create ArbOffsetEditFieldLabel
            app.ArbOffsetEditFieldLabel = uilabel(app.ArbitraryTab);
            app.ArbOffsetEditFieldLabel.Position = [30 95 56 22];
            app.ArbOffsetEditFieldLabel.Text = 'Offset (V)';

            % Create ArbOffsetEditField
            app.ArbOffsetEditField = uieditfield(app.ArbitraryTab, 'numeric');
            app.ArbOffsetEditField.Limits = [-0.5 0.5];
            app.ArbOffsetEditField.Position = [150 95 100 22];

            % Create SampleClockLabel
            app.SampleClockLabel = uilabel(app.ArbitraryTab);
            app.SampleClockLabel.Position = [30 247 89 22];
            app.SampleClockLabel.Text = 'Sampling clock';

            % Create SampleClockDropDown
            app.SampleClockDropDown = uidropdown(app.ArbitraryTab);
            app.SampleClockDropDown.Items = {'Internal', 'External'};
            app.SampleClockDropDown.ValueChangedFcn = createCallbackFcn(app, @SampleClockDropDownValueChanged, true);
            app.SampleClockDropDown.Position = [150 247 100 22];
            app.SampleClockDropDown.Value = 'Internal';

            % Create AwgExternalClockPort
            app.AwgExternalClockPort = uieditfield(app.ArbitraryTab, 'text');
            app.AwgExternalClockPort.HorizontalAlignment = 'center';
            app.AwgExternalClockPort.Visible = 'off';
            app.AwgExternalClockPort.Position = [268 248 60 21];
            app.AwgExternalClockPort.Value = 'ClkIn';

            % Create AwgTriggerPort
            app.AwgTriggerPort = uieditfield(app.ArbitraryTab, 'text');
            app.AwgTriggerPort.HorizontalAlignment = 'center';
            app.AwgTriggerPort.Enable = 'off';
            app.AwgTriggerPort.Position = [268 211 60 19];
            app.AwgTriggerPort.Value = 'PFI0';

            % Create ExportSignalPort
            app.ExportSignalPort = uieditfield(app.ArbitraryTab, 'text');
            app.ExportSignalPort.HorizontalAlignment = 'center';
            app.ExportSignalPort.Position = [268 173 60 19];
            app.ExportSignalPort.Value = 'PFI1';

            % Create SignalSourceDropDown
            app.SignalSourceDropDown = uidropdown(app.ArbitraryTab);
            app.SignalSourceDropDown.Items = {'Marker', 'DataMarker'};
            app.SignalSourceDropDown.Position = [343 171 100 22];
            app.SignalSourceDropDown.Value = 'DataMarker';

            % Create ExternaltriggerDropDownLabel
            app.ExternaltriggerDropDownLabel = uilabel(app.ArbitraryTab);
            app.ExternaltriggerDropDownLabel.Position = [30 208 86 22];
            app.ExternaltriggerDropDownLabel.Text = 'External trigger';

            % Create ExternaltriggerDropDown
            app.ExternaltriggerDropDown = uidropdown(app.ArbitraryTab);
            app.ExternaltriggerDropDown.Items = {'Off', 'On'};
            app.ExternaltriggerDropDown.ValueChangedFcn = createCallbackFcn(app, @ExternaltriggerDropDownValueChanged, true);
            app.ExternaltriggerDropDown.Position = [149 209 100 22];
            app.ExternaltriggerDropDown.Value = 'Off';

            % Create DelaynsLabel
            app.DelaynsLabel = uilabel(app.ArbitraryTab);
            app.DelaynsLabel.Position = [30 19 60 22];
            app.DelaynsLabel.Text = 'Delay (ns)';

            % Create DelayEditField
            app.DelayEditField = uieditfield(app.ArbitraryTab, 'numeric');
            app.DelayEditField.Position = [150 19 100 22];

            % Create ExportsignalDropDownLabel
            app.ExportsignalDropDownLabel = uilabel(app.ArbitraryTab);
            app.ExportsignalDropDownLabel.Position = [30 171 78 22];
            app.ExportsignalDropDownLabel.Text = 'Export  signal';

            % Create ExportsignalDropDown
            app.ExportsignalDropDown = uidropdown(app.ArbitraryTab);
            app.ExportsignalDropDown.Items = {'Off', 'On'};
            app.ExportsignalDropDown.ValueChangedFcn = createCallbackFcn(app, @ExportsignalDropDownValueChanged, true);
            app.ExportsignalDropDown.Position = [149 171 100 22];
            app.ExportsignalDropDown.Value = 'Off';

            % Create ArbwaveformDropDownLabel
            app.ArbwaveformDropDownLabel = uilabel(app.ArbitraryTab);
            app.ArbwaveformDropDownLabel.Position = [30 318 79 22];
            app.ArbwaveformDropDownLabel.Text = 'Arb waveform';

            % Create ArbwaveformDropDown
            app.ArbwaveformDropDown = uidropdown(app.ArbitraryTab);
            app.ArbwaveformDropDown.Items = {'Load file', '1on9off', '1on1off', '5on5off', 'Keep On', 'Keep Off'};
            app.ArbwaveformDropDown.ValueChangedFcn = createCallbackFcn(app, @ArbwaveformDropDownValueChanged, true);
            app.ArbwaveformDropDown.Position = [149 318 100 22];
            app.ArbwaveformDropDown.Value = 'Load file';

            % Create ArbFileLabel
            app.ArbFileLabel = uilabel(app.ArbitraryTab);
            app.ArbFileLabel.Position = [343 318 85 22];
            app.ArbFileLabel.Text = '';

            % Create OutputButton
            app.OutputButton = uibutton(app.LeftPanel, 'push');
            app.OutputButton.ButtonPushedFcn = createCallbackFcn(app, @OutputButtonPushed, true);
            app.OutputButton.Enable = 'off';
            app.OutputButton.Position = [33 10 61 23];
            app.OutputButton.Text = 'Output';

            % Create PauseButton
            app.PauseButton = uibutton(app.LeftPanel, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.Enable = 'off';
            app.PauseButton.Position = [166 10 61 23];
            app.PauseButton.Text = 'Pause';

            % Create ImpedanceDropDownLabel
            app.ImpedanceDropDownLabel = uilabel(app.LeftPanel);
            app.ImpedanceDropDownLabel.Tooltip = {'OutputImpedance'};
            app.ImpedanceDropDownLabel.Position = [32 438 85 22];
            app.ImpedanceDropDownLabel.Text = 'Impedance (Ω)';

            % Create ImpedanceDropDown
            app.ImpedanceDropDown = uidropdown(app.LeftPanel);
            app.ImpedanceDropDown.Items = {'50', '75'};
            app.ImpedanceDropDown.Position = [130 438 100 22];
            app.ImpedanceDropDown.Value = '50';

            % Create SimulateCheckBox
            app.SimulateCheckBox = uicheckbox(app.LeftPanel);
            app.SimulateCheckBox.Text = 'Simulate';
            app.SimulateCheckBox.Position = [250 506 69 22];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Signal (V)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [7 32 509 451];

            % Show the figure after all components are created
            app.AWGControlUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AWG_Control_2022b_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.AWGControlUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.AWGControlUIFigure)
        end
    end
end