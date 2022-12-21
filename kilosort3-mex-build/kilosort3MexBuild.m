cudaToolkitBin = '/usr/local/cuda/bin';
[~, nvccVersion] = system(sprintf('%s/nvcc --version', cudaToolkitBin));
fprintf('CUDA toolkit nvcc version:\n%s\n', nvccVersion);

kilosortCudaDir = '/home/matlab/kilosort/CUDA';
fprintf('Building kilosort mex gpu functions in %s.\n', kilosortCudaDir);

setenv('MW_NVCC_PATH', cudaToolkitBin);
cd(kilosortCudaDir);
mexGPUall

system('cp /home/matlab/kilosort/CUDA/*.mexa64 /home/matlab/kilosort3-binaries/')
