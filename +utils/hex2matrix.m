function rgb = hex2matrix(hexColor)
    % 去掉 '#' 符号
    hexColor = hexColor(2:end);
    % 分割为三个颜色通道，并转换为十进制数
    r = hex2dec(hexColor(1:2));
    g = hex2dec(hexColor(3:4));
    b = hex2dec(hexColor(5:6));
    % 组合为 RGB 数组
    rgb = [r g b]/255;
end