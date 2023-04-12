function tiff_save(filepath,imgStack)
    imwrite(uint16(imgStack(:,:,1)),filepath);
    for ii = 2 : size(imgStack, 3)
        imwrite(uint16(imgStack(:,:,ii)) ,filepath,'WriteMode', 'append') ;
    end

end