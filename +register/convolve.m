function convolvedData = convolve(mov, img)
    % Returns the 3D array "mov" convolved by a 2D array "img".

    % Parameters
    % ----------
    % mov: nImg x Ly x Lx
    %     The frames to process
    % img: 2D array
    %     The convolution kernel

    % Returns
    % -------
    % convolvedData: nImg x Ly x Lx

    convolvedData = ifft2(register.apply_dotnorm(fft2(mov), img));
end