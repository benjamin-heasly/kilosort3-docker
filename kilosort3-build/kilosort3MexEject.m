% Print nvcc version as sanity check on the CUDA toolbox installation.
cudaToolkitBin = '/usr/local/cuda/bin';
[~, nvccVersion] = system(sprintf('%s/nvcc --version', cudaToolkitBin));
fprintf('CUDA toolkit nvcc version:\n%s\n', nvccVersion);
setenv('MW_NVCC_PATH', cudaToolkitBin);

% Compile the official Matlab GPU example so we can verbose-log the shell commands to use.
mexGPUExampleSource = fullfile(matlabroot,'toolbox','parallel','gpu','extern','src','mex','mexGPUExample.cu')
mexcuda('-v', mexGPUExampleSource)

% Compile each mex gpu function from Kilosort so we can verbose-log the shell commands to use.
% These commands are adapted from the Kilosort script mexGPUAll.m
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/spikedetector3.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/spikedetector3PC.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexThSpkPC.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexGetSpikes2.cu')

mexcuda('-v', '-largeArrayDims', '-dynamic', '-DENABLE_STABLEMODE', '/home/matlab/kilosort/CUDA/mexMPnu8.cu')

mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexSVDsmall2.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexWtW2.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexFilterPCs.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexClustering2.cu')
mexcuda('-v', '-largeArrayDims', '/home/matlab/kilosort/CUDA/mexDistances2.cu')
