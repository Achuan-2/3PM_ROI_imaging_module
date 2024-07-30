function fhg = gaussian_fft(sig, Ly, Lx)
    % gaussian filter in the fft domain with std sig and size Ly, Lx
    %
    % Parameters
    % ----------
    % sig
    % Ly : int
    %     frame height
    % Lx : int
    %     frame width
    %
    % Returns
    % -------
    % fhg : array
    %     smoothing filter in Fourier domain
    
    [xx, yy] = register.meshgrid_mean_centered(Lx, Ly);
    hgx = exp(-((xx / sig) .^ 2) / 2);
    hgy = exp(-((yy / sig) .^ 2) / 2);
    hgg = hgy .* hgx;
    hgg = hgg / sum(hgg(:));
    fhg = real(fft2(ifftshift(hgg)));
end