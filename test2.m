
% 只能监听一次
if ~isempty(listeners)
    delete(listeners{1});
end
%frameAcquired每一帧，只能监听一次
%listeners{1} = addlistener(hSI.hUserFunctions, 'frameAcquired', @utils.test);
% acqModeStart：Grab或loop按下，可以监听多次
%listeners{1} = addlistener(hSI.hUserFunctions, 'acqModeStart', @utils.test);
%acqStart：可以监听多次，Focus、Grab、Loop都可以，Called just after the first frame gets acquired from an Acquisition Mode. 不知道是获取一帧前还是一帧后
listeners{1} = addlistener(hSI.hUserFunctions, 'acqStart', @utils.test);


delete(listeners{1});




