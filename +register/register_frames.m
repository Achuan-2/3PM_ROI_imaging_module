function [reg_frames, ymax, xmax, cmax] = register_frames(refAndMasks, frames,  ops)
    rmin= -inf;
    rmax=inf;
    reg_frames = zeros(size(frames), 'like',frames);

    if length(refAndMasks) == 3 || iscell(refAndMasks)
        maskMul = refAndMasks{1};
        maskOffset = refAndMasks{2};
        cfRefImg = refAndMasks{3};
    else
        error('refAndMasks is not a cell!');
    end


    % Copy frames if smoothing
    if ops.smooth_sigma_time > 0
        fsmooth = single(frames);
    else
        fsmooth = frames;
    end

    % Apply temporal smoothing if needed
    if ops.smooth_sigma_time > 0
        fsmooth = temporal_smooth(fsmooth, ops.smooth_sigma_time);
    end

    % Rigid registration
    [ymax, xmax, cmax] = phasecorr(...
        apply_masks(...
            min(max(fsmooth, rmin), rmax), ...
            maskMul, maskOffset), ...
        cfRefImg, ...
        ops.maxregshift, ...
        ops.smooth_sigma_time ...
    );

    % Shift frames
    for i = 1:size(frames, 3)
        reg_frames(:, :,i) = shift_frame(frames(:, :, i), ymax(i), xmax(i));
    end
end