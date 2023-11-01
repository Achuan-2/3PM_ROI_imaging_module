function color_mask = mask_to_rgb(mask)

    color_mask = zeros([size(mask), 3], 'single');
    for n = 1:max(mask(:))

        mask_indices = (mask == n);
        color_mask(mask_indices) = rand; % hue
        color_mask(:,:,2) = color_mask(:,:,2) .* ~mask_indices +  rand*mask_indices;
        color_mask(:,:,3) = color_mask(:,:,3) .* ~mask_indices +  rand*mask_indices;
    end
    color_mask = uint8(color_mask*255);

end