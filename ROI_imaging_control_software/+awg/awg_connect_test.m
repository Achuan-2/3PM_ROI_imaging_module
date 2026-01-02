[dev,status] = awg.connect('Dev1',false);
% [dev,status] = awg.connect('Dev1',true); % 仿真模式
n = 2; % Number of lines
waveformHandlesArray = cell(1, n);
linePulse = ones(1,512);
sampleCountsArray = zeros(1, n); % Store actual length of each line pulse
waveformHandle = awg.create_waveform_handle(dev, linePulse);
sampleCountsArray(1) = length(linePulse);
waveformHandlesArray{1} = waveformHandle;
waveformHandle = awg.create_waveform_handle(dev, linePulse);
sampleCountsArray(2) = length(linePulse);
waveformHandlesArray{2} = waveformHandle;
waveformHandlesArray = cell2mat(waveformHandlesArray);
sequenceLength = n;
loopCountsArray = ones(1, n); % Output each line waveform once per trigger
markerLocationArray = repmat(-1, 1, n); % No specific marker locations needed here
% Configure AWG for sequence output mode
configureOutputMode(dev, "OUTPUT_SEQ");

% Create and configure the sequence
[~, sequenceHandle] = createAdvancedArbSequence(dev, sequenceLength, waveformHandlesArray, loopCountsArray, sampleCountsArray, markerLocationArray);

% Generate Arb sequence output (triggered by line clock)
awg.create_arb_sequence(dev, sequenceHandle, app.waveformConfig);
%  awg.disconnect(dev);