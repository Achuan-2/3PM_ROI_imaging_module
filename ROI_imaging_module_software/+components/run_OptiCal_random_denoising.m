% MATLAB script to run test.py for random noise denoising using SRDTrans using pyrunfile
% Set parameters for the Python script
GPU = '0';
denoise_model = '3PM';  % Model folder name (under pth directory)
input_file = 'E:\Desktop\test\test random denoising\file_00020_ch1_deripple.tif';
[input_path, input_name, input_ext] = fileparts(input_file);
output_file = fullfile(input_path, [input_name '_denoised' input_ext]);
pth_path = fullfile(pwd, '..', 'OptiCal_denoising_model', 'random_denoising_model','pth');

% Add Python module search path
script_folder = fullfile(pwd, '..', 'OptiCal_denoising_model', 'random_denoising_model');
if count(py.sys.path, script_folder) == 0
    insert(py.sys.path, int32(0), script_folder);
end

% Run the Python script, passing parameters
try
    fprintf('Running random noise removal...\n');
    fprintf('GPU: %s, Model: %s\n', GPU, denoise_model);
    fprintf('Input: %s\n', input_file);
    fprintf('Output: %s\n', output_file);
    
    pyrunfile('../OptiCal_denoising_model/random_denoising_model/test.py',...
        'GPU', GPU, ...
        'denoise_model', denoise_model, ...
        'input', input_file, ...
        'output', output_file, ...
        'pth_path',pth_path);
    
    fprintf('Random noise removal completed! Output file: %s\n', output_file);
catch ME
    fprintf('Error: %s\n', ME.message);
    rethrow(ME);
end
