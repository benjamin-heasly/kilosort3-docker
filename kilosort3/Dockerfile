# Start with our image that has Matlab and kilosort3 code.
ARG VERSION=r2022b
FROM ninjaben/kilosort3-code:$VERSION

# Add in compiled kilosort mex gpu binaries from the kilosort3-build step.
# This way, we don't have to include the large CUDA toolkit going forward.
ADD ./kilosort3-binaries/*.mexa64 /home/matlab/kilosort/CUDA/

# On Matlab start, log useful info and add kilosort to the path.
ADD ./startup.m /home/matlab/Documents/MATLAB/startup.m
