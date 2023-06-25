black = 0;
white = 1;
imageSize = 512;

test = [black,black,black,white];
vectors = [repmat(test,1,32/length(test))]; % 白黑条纹是32个1和32个0，
binary_im_1d = repmat(vectors,1,imageSize*imageSize/length(vectors)); % 组成 512*512 的图像
binary_im  = reshape(binary_im_1d,imageSize,imageSize)';
binary_im(:,256) = white;
imshow(binary_im);
writematrix(binary_im,"3off1on.csv");