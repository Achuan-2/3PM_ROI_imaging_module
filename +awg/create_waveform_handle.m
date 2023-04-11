function waveformHandle = create_waveform_handle(dev,waveformArray)
    waveformSize = length(waveformArray);
    waveformHandle = createWaveformF64(dev, '0', waveformSize, waveformArray);
end