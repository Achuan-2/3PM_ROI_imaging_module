function refImg = compute_reference(frames, ops)
    % Computes the reference image by iteratively aligning frames to create reference
    %
    % Parameters
    % ----------
    % ops : struct
    %     Registration options
    % frames : 3D array, int16
    %     size [Ly x Lx x nimg_init], frames to use to create initial reference
    %
    % Returns
    % -------
    % refImg : 2D array, int16
    %     size [Ly x Lx], initial reference image


    % Pick initial reference
    refImg = register.pick_initial_reference(frames);
    niter = 8;
    for iter = 1:niter
        % Rigid registration
        [maskMul, maskOffset] = register.compute_masks(refImg, 3 * ops.smooth_sigma);
        framesTaper = register.apply_masks(frames,maskMul, maskOffset);
        refImgSmooth = register.phasecorr_reference(refImg, ops.smooth_sigma);
        [ymax, xmax, cmax] = register.phasecorr(...
            framesTaper, ...
            refImgSmooth, ...
            ops.maxregshift, ops.smooth_sigma_time);

        % Shift frames
        for i = 1:size(frames, 3)
            frames(:, :, i) = register.shift_frame(frames(:, :, i), ymax(i), xmax(i));
        end

        nmax = max(2, floor(size(frames, 3) * (1 + iter) / (2 * niter)));
        [~, isort] = sort(cmax, 'descend');
        isort = isort(1:nmax);

        % Reset reference image
        refImg = int16(mean(frames(:, :, isort), 3));

        % Shift reference image
        refImg = register.shift_frame(refImg, -round(mean(ymax(isort))), -round(mean(xmax(isort))));
    end
end