# Start with our image that has Matlab and Kilosort
FROM kilosort3-dependencies

# Add in combiled kilosort mex gpu binaries -- and not the whole Cuda toolkit.
ADD ./kilosort3-binaries/*.mexa64 /home/matlab/kilosort/CUDA/
