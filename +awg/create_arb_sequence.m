function create_arb_sequence(dev,sequenceHandle,waveformConfig)
    configureOutputMode(dev,"OUTPUT_SEQ"); % OUTPUT_FUNC,OUTPUT_ARB,OUTPUT_SEQ

    % configure for arbitrary waveform or arb sequence
    awg.arb_configure(dev, waveformConfig);

    % create arbitrary waveform
    gain = waveformConfig.gain;
    offset = waveformConfig.offset;
    
    % create arbitrary Sequence
    configureArbSequence(dev, '0', sequenceHandle, gain, offset);

    % enable output
    awg.output_enable(dev);
end