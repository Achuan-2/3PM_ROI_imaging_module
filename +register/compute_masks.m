function [maskMul, maskOffset] = compute_masks(refImg, maskSlope)
    % Returns maskMul and maskOffset from an image and slope parameter
    %
    % Parameters
    % ----------
    % refImg : Ly x Lx
    %     The image
    % maskSlope
    %
    % Returns
    % -------
    % maskMul : float array
    % maskOffset : float array

    [Ly, Lx] = size(refImg);
    maskMul = register.spatial_taper(maskSlope, Ly, Lx);
    maskOffset = mean(refImg(:)) .* (1 - maskMul);
end