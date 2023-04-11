% 读取彩色图像
function image_to_binary(filenameInput,filenameOutput)
    color_img = imread(filenameInput);
    % 将彩色图像转换为灰度图像
    gray_img = rgb2gray(color_img);
    % 将灰度图像转换为二值图像
    bw_img = imbinarize(gray_img);
    % 显示二值图像
    imshow(bw_img)
    writematrix(bw_img,filenameOutput)
end

