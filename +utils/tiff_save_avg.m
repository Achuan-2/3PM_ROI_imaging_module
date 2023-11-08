function imgAvg = tiff_save_avg(filepath,imgStack)
    imgAvg = mean(imgStack,3);
    imgAvg = im2uint8(mat2gray(imgAvg));
    imwrite(imgAvg,filepath,'Compression','none');
end