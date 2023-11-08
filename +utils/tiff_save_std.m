function imgStd = tiff_save_std(filepath,imgStack)

    imgStack = double(imgStack);
    imgStd = std(imgStack,0,3);
    imgStd = im2uint8(mat2gray(imgStd));

    imwrite(imgStd,filepath,'Compression','none');
end