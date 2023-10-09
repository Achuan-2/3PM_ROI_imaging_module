fig1 = figure('Name','Origin Mask','Visible','On',...
                            'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Tag','image_channel1','Position',[10,10,408,408]);
imMask = imread('cellpose_test_cp_masks.png');
imMask(imMask~=0) = 1;
imMask = single(imMask);
imshow(imMask,'border','tight','initialmagnification','fit');
imwrite(imMask,'Origin Mask.png');
fig2 = figure('Name','Dilated Mask','Visible','On',...
                            'ColorMap',gray(255),'NumberTitle','off','Menubar','none','Tag','image_channel1','Position',[10,10,408,408]);

SE = strel('disk',5);
imMask2 = imdilate(imMask,SE);
imshow(imMask2,'border','tight','initialmagnification','fit');
imwrite(imMask2,'Dilated Mask.png')