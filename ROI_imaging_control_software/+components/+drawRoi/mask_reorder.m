function reordered_mask = mask_reorder(mask)
    %reorder the roi mask after delete roi
    [~, ~, ic] = unique(mask);

    % 重新塑造 masks 并转换为 int32 类型
    reordered_mask = reshape(ic-1, size(mask));
end

