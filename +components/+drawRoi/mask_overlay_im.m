function converted_im = mask_overlay_im(im,mask)
    % 把mask叠加到图像上

    im = single(im);
    HSV = zeros([size(im), 3], 'single');

    if max(im(:)) > 1
        v = im / 255;
    else
        v= im;
    end

    HSV(:,:,3) = v; % value

    n_roi = max(mask(:));
    hues = linspace(0, 1, n_roi+1);
    hues = hues(randperm(n_roi));

    for n = 1:max(mask(:))
        mask_indices = (mask == n);
        HSV(mask_indices) = hues(n); % hue
        HSV(:,:,2) = HSV(:,:,2) .* ~mask_indices +  0.4*mask_indices; % saturation
    end

    converted_im = uint8(hsv2rgb(HSV) * 255);
end