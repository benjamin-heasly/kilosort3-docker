% Print nvcc version as sanity check on the CUDA toolbox installation.
cudaToolkitBin = '/usr/local/cuda/bin';
[~, nvccVersion] = system(sprintf('%s/nvcc --version', cudaToolkitBin));
fprintf('CUDA toolkit nvcc version:\n%s\n', nvccVersion);
setenv('MW_NVCC_PATH', cudaToolkitBin);

% Compile the official Matlab GPU example as a config diagnostic.
mexGPUExampleSource = fullfile(matlabroot,'toolbox','parallel','gpu','extern','src','mex','mexGPUExample.cu')
mexcuda('-v', mexGPUExampleSource)

% Copy out the mexGPUExample binary as a runtime diagnostic for later.
mexGPUExampleCopyCommand = sprintf('cp %s /home/matlab/kilosort3-binaries/', which('mexGPUExample'));
system(mexGPUExampleCopyCommand)

% Use mexGPUall from Kilosort to compile the mex gpu functions Kilosort needs.
kilosortCudaDir = '/home/matlab/kilosort/CUDA';
fprintf('Building kilosort mex gpu functions in %s.\n', kilosortCudaDir);
cd(kilosortCudaDir);
mexGPUall

% Copy out the Kilosort binaries to use in runtime later.
system('cp /home/matlab/kilosort/CUDA/*.mexa64 /home/matlab/kilosort3-binaries/')
