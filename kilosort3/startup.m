% Log what we have here for official Matlab stuff.
ver

% Log what Matlab can find for GPU devices.
try
    gpuDevice
catch e
    warning(e.message)
end

% Get kilosort on the path.
kilosortPath = '/home/matlab/kilosort';
addpath(genpath(kilosortPath));

fprintf('Found kilosort at %s\n', which('kilosort'));

[~, kilosortStatus] = system(sprintf('git -C %s status', kilosortPath));
fprintf('Kilosort git status:\n%s\n', kilosortStatus);

% Get npy-matlab on the path.
npyMatlabPath = '/home/matlab/npy-matlab';
addpath(fullfile(npyMatlabPath, 'npy-matlab'));

fprintf('Found npy-matlab at %s\n', which('readNPY'));

[~, npyMatlabStatus] = system(sprintf('git -C %s status', npyMatlabPath));
fprintf('npy-matlab git status:\n%s\n', npyMatlabStatus);

% Get home folder, including tests and mex binaries, on the path.
addpath('/home/matlab');
addpath('/home/matlab/test');
addpath('/home/matlab/mex-gpu-binaries');
