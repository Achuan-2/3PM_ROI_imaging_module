function maskedData = apply_masks(data, maskMul, maskOffset)
    % Returns a 3D image "data", multiplied by "maskMul" and then added "maskOffset".
    %
    % Parameters
    % ----------
    % data : nImg x Ly x Lx
    % maskMul
    % maskOffset
    %
    % Returns
    % -------
    % maskedData : nImg x Ly x Lx

    % Convert x to single precision (equivalent to np.float32 in Python)
    x_single = double(data);
    
    % Perform the multiplication and addition
    maskedData = x_single .* maskMul + maskOffset;
    
    % Convert the result to complex type (equivalent to np.complex64 in Python)
    maskedData = complex(maskedData);
end
