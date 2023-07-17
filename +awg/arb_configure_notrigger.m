function arb_configure_notrigger(dev,waveformConfig)
    % read parameters
    mode = waveformConfig.mode; % Stepped
    sampleRate = waveformConfig.sampleRate; % 1.0007 MHz
    delayTime = waveformConfig.delayTime*1e-9;
    clockSource = waveformConfig.clockSource; % 'OnboardClock' or 'ClkIn'
    exportSignalOn = waveformConfig.exportSignalOn; % true or false
    exportSignalType = waveformConfig.exportSignalType; % Marker DataMarker
    exportSignalPort = waveformConfig.exportSignalPort; % PFI0 or PFI1


    configureSampleRate(dev,sampleRate);

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