function create_arb_waveform_notrigger(dev,waveformHandle,waveformConfig)
    % 	set arbitrary waveform mode
    configureOutputMode(dev,"OUTPUT_ARB");

    % configure for arbitrary waveform or arb sequence
    awg.arb_configure_notrigger(dev, waveformConfig);

    % create arbitrary waveform
    gain = waveformConfig.gain;
    offset = waveformConfig.offset;
    configureArbWaveform(dev,'0', waveformHandle, gain, offset);

    % enable output
    awg.output_enable(dev);
end