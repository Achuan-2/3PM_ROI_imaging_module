function color_mask = mask_to_rgb(mask,colormaps)
    % transform roi mask to colored roi mask
    arguments(Input)
        mask
        colormaps
    end
    arguments(Output)
        color_mask uint8
    end

    color_mask = zeros([size(mask), 3], 'single');
    
    for i = 1:max(mask(:))
        % Get the position of roi  for each roi
        roi_position = (mask == i);
        % Transform 2D logical array to 3D logical array to index 3D Array
        roi_3D = repmat(roi_position,1,1,3);
        % Assign a value to the specified position
        randowm_rgb_color = colormaps(i,:);
        color_mask(roi_3D) = repmat(randowm_rgb_color,sum(roi_position,'all'),1); 
    end
end