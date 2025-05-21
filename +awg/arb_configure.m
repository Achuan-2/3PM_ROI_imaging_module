function arb_configure(dev,waveformConfig)
    % read parameters
    mode = waveformConfig.mode; % Stepped
    sampleRate = waveformConfig.sampleRate; % 1.0007 MHz
    delayTime = waveformConfig.delayTime*1e-9;
    clockSource = waveformConfig.clockSource; % 'OnboardClock' or 'ClkIn'
    triggerOn = waveformConfig.triggerOn; % true or false
    triggerPort = waveformConfig.triggerPort; % PFI0 or PFI1
    exportSignalOn = waveformConfig.exportSignalOn; % true or false
    exportSignalType = waveformConfig.exportSignalType; % Marker DataMarker
    exportSignalPort = waveformConfig.exportSignalPort; % PFI0 or PFI1


    configureSampleRate(dev,sampleRate);
    configureOutputImpedance(dev, '0', "VAL_50"); % 阻抗为50欧姆

    dev.Output.Advanced.IdleBehavior = "HOLD_LAST_VALUE"; % HOLD_LAST_VALUE，没发射信号，第一次等待Trigger信号的电平
    dev.Output.Advanced.IdleValue = 1;
    dev.Output.Advanced.WaitBehavior = "HOLD_LAST_VALUE"; % HOLD_LAST_VALUE or JUMP_TO_VALUE。接受过第一次Trigger信号，等待下一次Trigger信号的电平
    dev.Output.Advanced.WaitValue = 1;
    % set clock: internal or external
    % if use external sample clock ,you should notice that
    try
        configureSampleClockSource(dev, clockSource);
        %configureReferenceClock(app.awgDevice, app.AwgExternalClockPort.Value,sampleRate);
    catch ErrorInfo
        msgbox(ErrorInfo.message,'Warning','error');
        return
    end


    % set colck delay（TODO：需要测试能否真的delay）
    % adjustSampleClockRelativeDelay(app.awgDevice,adjustmentTime);
    dev.Clocks.Advanced.SampleClockAbsoluteDelay = delayTime;
    % app.awgDevice.Clocks.Advanced.ExternalClockDelayBinaryValue = adjustmentTime;


    % set AWG trigger
    if triggerOn
        try
            configureDigitalEdgeStartTrigger(dev,triggerPort,"RISING_EDGE"); % RISING_EDGE，FALLING_EDGE  
        catch ErrorInfo
            msgbox(ErrorInfo.message,'Warning','error');
            return
        end
    end



    % set export signal
    if exportSignalOn
        try
            switch exportSignalType
                case "Marker"
                    dev.ArbitraryWaveform.Mode.MarkerPosition = 0;
                    exportSignal(dev,"MARKER_EVENT","Marker0",exportSignalPort);
                case "DataMarker"
                    exportSignal(dev,"DATA_MARKER_EVENT","DataMarker0",exportSignalPort);
            end

        catch ErrorInfo
            msgbox(ErrorInfo.message,'Warning','error');
            return
        end
    end

    % set Trigger Mode
    configureTriggerMode(dev, '0', upper(mode));

end