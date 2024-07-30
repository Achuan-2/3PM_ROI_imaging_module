function refAndMasksAll = compute_reference_masks(refImg, ops)
    if nargin < 2
        ops = reg_default_ops();
    end

    % Compute masks
    [maskMul, maskOffset] = register.compute_masks(...
        refImg, ...
        3 * ops.smooth_sigma ...
    );

    % Compute phase correlation reference image
    cfRefImg = register.phasecorr_reference(...
        refImg, ...
        ops.smooth_sigma ...
    );


    % Return results
    refAndMasksAll = {maskMul, maskOffset, cfRefImg};

end