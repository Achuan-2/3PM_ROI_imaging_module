function [filename,path]= select_file(fileExtension,defaultPath)

        f_dummy = figure('Position', [-100 -100 0 0]); %create a dummy figure so that uigetfile doesn't minimize our GUI
        
        if nargin < 2
            [filename,path] = uigetfile(fileExtension, 'Select a file');
        else
            [filename,path] = uigetfile(fileExtension, 'Select a file',defaultPath);
        end

        delete(f_dummy); %delete the dummy figure

end