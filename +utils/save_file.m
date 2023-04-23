function [filename,path]= save_file(fileExtension,defaultPath)
    % fileExtension: {'*.jpg';'*.png';'tif'}
    
    f_dummy = figure('Position', [-100 -100 0 0]); %create a dummy figure so that uigetfile doesn't minimize our GUI

    if nargin < 2
        [filename, path] = uiputfile(fileExtension, 'Save as');
    else
        [filename, path] = uiputfile(fileExtension, 'Save as',defaultPath);
    end

    delete(f_dummy); %delete the dummy figure
end