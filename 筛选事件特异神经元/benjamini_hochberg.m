% Benjamini-Hochberg校正函数
function [corrected_p_values, significant] = benjamini_hochberg(p_values, alpha)
    % p_values: 原始p值数组
    % alpha: 显著性水平
    % 返回校正后的p值和显著性标记

    % 获取p值的数量
    m = length(p_values);
    
    % 对p值进行排序，并获取排序索引
    [sorted_p_values, sort_index] = sort(p_values);
    
    % 计算校正后的p值
    corrected_p_values = zeros(size(p_values));
    for i = 1:m
        corrected_p_values(i) = sorted_p_values(i) * m / i;
    end
    
    % 确保校正后的p值不超过1
    corrected_p_values = min(corrected_p_values, 1);
    
    % 逆排序以恢复原始顺序
    corrected_p_values(sort_index) = corrected_p_values;
    
    % 判断哪些p值是显著的
    significant = corrected_p_values < alpha;
end


