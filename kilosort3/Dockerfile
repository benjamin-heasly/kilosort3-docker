# Start with our image that has Matlab and Kilosort
FROM kilosort3-dependencies

# Add in combiled kilosort mex gpu binaries from a previous step.
# This way, we don't have to include the large CUDA toolkit in this image.
ADD ./kilosort3-binaries/*.mexa64 /home/matlab/kilosort/CUDA/
