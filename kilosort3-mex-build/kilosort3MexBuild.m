% Print nvcc version as sanity check on the CUDA toolbox installation.
cudaToolkitBin = '/usr/local/cuda/bin';
[~, nvccVersion] = system(sprintf('%s/nvcc --version', cudaToolkitBin));
fprintf('CUDA toolkit nvcc version:\n%s\n', nvccVersion);

% Use mexGPUall from Kilosort to compile the mex gpu functions it needs.
kilosortCudaDir = '/home/matlab/kilosort/CUDA';
fprintf('Building kilosort mex gpu functions in %s.\n', kilosortCudaDir);
setenv('MW_NVCC_PATH', cudaToolkitBin);
cd(kilosortCudaDir);
mexGPUall

% Copy the compiled binaries to a dir exposed to the Docker host, for use in a later step.
system('cp /home/matlab/kilosort/CUDA/*.mexa64 /home/matlab/kilosort3-binaries/')
