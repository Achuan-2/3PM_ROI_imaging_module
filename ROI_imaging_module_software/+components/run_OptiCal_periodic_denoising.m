
% MATLAB script to run Inference_periodic_denoise.py using pyrunfile
% Set parameters for the Python script
input_file = 'E:\Desktop\test\test_split\Processed\file_00001_ch1.tif';
[input_path, input_name, input_ext] = fileparts(input_file);
output_file = fullfile(input_path, [input_name '_deripple' input_ext]);
model_path_relative = '../OptiCal_denoising_model\periodic_denoising_model\train_out\3PM\net_dependent_noise_G20.pth';
model_path = fullfile(pwd, model_path_relative);
block_size = int32(128);
device = 'cuda';
% Add module search path
script_folder = fullfile(pwd, '..', 'OptiCal_denoising_model', 'periodic_denoising_model');
if count(py.sys.path,script_folder) == 0
    insert(py.sys.path,int32(0),script_folder );
end

% Run the Python script, passing parameters
try
    pyrunfile('../OptiCal_denoising_model/periodic_denoising_model/Inference_periodic_denoise.py', ...
        'input', input_file, ...
        'output', output_file, ...
        'model', model_path, ...
        'block_size', block_size, ...
        'device', device);
    fprintf('Inference completed! Output file: %s\n', output_file);
catch ME
    fprintf('Error: %s\n', ME.message);
    rethrow(ME);
end
