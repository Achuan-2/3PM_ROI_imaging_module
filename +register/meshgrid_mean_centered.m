function [xx, yy] = meshgrid_mean_centered(x, y)
    % Returns a mean-centered meshgrid
    %
    % Parameters
    % ----------
    % x: int
    %     The height of the meshgrid
    % y: int
    %     The width of the meshgrid
    %
    % Returns
    % -------
    % xx: int array
    % yy: int array

    x = 0:x-1;
    y = 0:y-1;
    
    x = abs(x - mean(x));
    y = abs(y - mean(y));
    
    [xx, yy] = meshgrid(x, y);
end