function cfRefImg = phasecorr_reference(refImg, smooth_sigma)
    % Returns reference image fft'ed and complex conjugate and multiplied by gaussian filter in the fft domain,
    % with standard deviation "smooth_sigma" computes fft'ed reference image for phasecorr.
    %
    % Parameters
    % ----------
    % refImg : 2D array, int16
    %     reference image
    %
    % Returns
    % -------
    % cfRefImg : 2D array, complex64

    cfRefImg = register.complex_fft2(refImg);
    cfRefImg = cfRefImg ./ (1e-5 + abs(cfRefImg));
    cfRefImg = cfRefImg .* register.gaussian_fft(smooth_sigma, size(cfRefImg, 1), size(cfRefImg, 2));
end