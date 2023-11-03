function outline = mask_to_outline(mask)
    % mask_to_outline : convert roi mask to outline mask
    arguments (Input)
        mask (:,:) double
    end
    arguments (Output)
        outline (:,:) logical
    end
    outline = zeros(size(mask));
    n_roi = max(max(mask));
    for i = 1:n_roi
        mask_i = mask==i;
        [boundaries,~] = bwboundaries(mask_i);
        boundary = boundaries{1};
        linearIndices = sub2ind(size(outline), boundary(:, 1), boundary(:, 2));
        outline(linearIndices) = 1;
    end
end