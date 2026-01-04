function rgb_image = rgb_add_area(rgb_image,roi_position,color)
    % add roi to rgb mask
    arguments (Input)
        rgb_image (:,:,3) uint8
        roi_position (:,:) logical
        color
    end
    arguments (Output)
        rgb_image uint8
    end
    % rgb_image = double(rgb_image);
    % Transform 2D logical array to 3D logical array to index 3D Array
    roi_3D = repmat(roi_position,1,1,3);
    % Assign a RGB to the specified position
    rgb_image(roi_3D) = repmat(color,sum(roi_position,'all'),1);
end
