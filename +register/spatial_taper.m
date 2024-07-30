function maskMul = spatial_taper(sig, Ly, Lx)
    % Returns spatial taper on edges with gaussian of std sig
    %
    % Parameters
    % ----------
    % sig
    % Ly: int
    %     frame height
    % Lx: int
    %     frame width
    %
    % Returns
    % -------
    % maskMul

    [xx, yy] = register.meshgrid_mean_centered(Lx, Ly);
    
    mY = ((Ly - 1) / 2) - 2 * sig;
    mX = ((Lx - 1) / 2) - 2 * sig;
    
    maskY = 1 ./ (1 + exp((yy - mY) / sig));
    maskX = 1 ./ (1 + exp((xx - mX) / sig));
    
    maskMul = maskY .* maskX;
end