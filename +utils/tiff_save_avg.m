function imgAvg = tiff_save_avg(filepath,imgStack)
    imgAvg = mean(double(imgStack),3);
    imgAvg = im2uint8(mat2gray(imgAvg));
    imwrite(imgAvg,filepath,'Compression','none');
end