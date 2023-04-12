function imgAvg = tiff_save_avg(filepath,imgStack)
    imgAvg = mean(imgStack,3);
    imwrite(uint16(imgAvg),filepath);
end