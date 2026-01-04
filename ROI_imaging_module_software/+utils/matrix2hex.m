function hexColor = matrix2hex(rgb)
% MATRIX2HEX 将RGB矩阵转换为十六进制颜色字符串
%
% 输入:
%   rgb - RGB颜色值，可以是0-255范围内的整数或0-1范围内的小数
%
% 输出:
%   hexColor - 十六进制颜色字符串，格式为'#RRGGBB'
%
% 示例:
%   hexColor = matrix2hex([255, 0, 0]) 返回 '#FF0000'
%   hexColor = matrix2hex([1, 0, 0])   返回 '#FF0000'

    % 检查输入维度
    if ~isnumeric(rgb) || (numel(rgb) ~= 3 && size(rgb, 2) ~= 3)
        error('输入必须是包含3个元素的数值向量或Nx3矩阵');
    end
    
    % 确保rgb是行向量
    if size(rgb, 1) > 1 && size(rgb, 2) == 3
        % 如果是矩阵，只取第一行
        rgb = rgb(1, :);
    end
    
    % 确保rgb值在0-255范围内
    if all(rgb <= 1)
        % 如果值在0-1范围内，转换为0-255
        rgb = round(rgb * 255);
    else
        % 确保是整数
        rgb = round(rgb);
    end
    
    % 限制范围在0-255
    rgb = max(0, min(255, rgb));
    
    % 转换为十六进制
    hexColor = sprintf('#%02X%02X%02X', rgb(1), rgb(2), rgb(3));
end
