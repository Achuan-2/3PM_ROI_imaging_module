function outline = mask_to_outline(mask)
    % 考虑到有些roi会重叠，所以不应该直接把mask变为二值化mask
    % 最好还是一个个转化？
    outline = zeros(size(mask));
    n_roi = max(max(mask));
    for i = 1:n_roi
        mask_i = mask==i;
        [boundaries,~] = bwboundaries(mask_i);
        boundary = boundaries{1};
        linearIndices = sub2ind(size(outline), boundary(:, 1), boundary(:, 2));
        outline(linearIndices) = 1;
    end
    
    outline  =uint8(outline);
end