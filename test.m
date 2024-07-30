%hSI.hMotionManager.activateMotionCorrectionSimple()

% 必须要focus才能正常发送！
stripeData = hSI.hDisplay.lastStripeData;
roiData = stripeData.roiData{1};

channels = roiData.channels;
channel = channels(1);
z = roiData.zs(1); % use the first available z
roiData.onlyKeepZs(z);
roiData.onlyKeepChannels(channel);
%a = roiData.imageData{1}{1};
%a(100:500,100:500) = 2400;
img = utils.tiff_read("C:\TPM-SJX\AES\20240613_realtime_registration\Processed\file_00005_ch1_ref.tif");
% img = int16(img);
%roiData.imageData{1}{1} = int16(img);
img = img +700;
roiData.imageData{1}{1} = img';
hSI.hMotionManager.clearEstimators();
hSI.hMotionManager.addEstimator(roiData);
hSICtl = hSI.hController{1};
hGUI = hSICtl.hGuiClasses.MotionDisplay;

hSICtl.showGUI('MotionDisplay');
hSICtl.raiseGUI('MotionDisplay');
hGUI.currentZ = z;
hGUI.selectedEstimator = hSI.hMotionManager.hMotionEstimators(1);

hSI.hMotionManager.enable = true;