function create_arb_sequence(dev,sequenceHandle,waveformConfig)
    configureOutputMode(dev,"OUTPUT_SEQ"); % OUTPUT_FUNC,OUTPUT_ARB,OUTPUT_SEQ

    % configure for arbitrary waveform or arb sequence
    awg.arb_configure(dev, waveformConfig);

    % create arbitrary waveform
    gain = waveformConfig.gain;
    offset = waveformConfig.offset;
    
    % create arbitrary Sequence
    configureArbSequence(dev, '0', sequenceHandle, gain, offset);
    dev.Output.Advanced.IdleBehavior = "JUMP_TO_VALUE"; % 没发射信号，第一次等待Trigger信号的电平
    dev.Output.Advanced.IdleValue = 1;
    dev.Output.Advanced.WaitBehavior = "JUMP_TO_VALUE"; % 接受过第一次Trigger信号，等待下一次Trigger信号的电平
    dev.Output.Advanced.WaitValue = 1;
    % enable output
    awg.output_enable(dev);
end