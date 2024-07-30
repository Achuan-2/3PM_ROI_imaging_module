function result = complex_fft2(img, padFft)
    % Returns the complex conjugate of the fft-transformed 2D array "img",
    % optionally padded for speed.
    %
    % Parameters
    % ----------
    % img: Ly x Lx
    %     The image to process
    % padFft: bool
    %     Whether to pad the image

    if nargin < 2
        padFft = false;
    end

    [Ly, Lx] = size(img);
    
    if padFft
        Ly = 2 ^ nextpow2(Ly);
        Lx = 2 ^ nextpow2(Lx);
        result = conj(fft2(img, Ly, Lx));
    else
        result = conj(fft2(img));
    end
end