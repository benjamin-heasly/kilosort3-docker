# Add NVIDIA CUDA toolbox 11.2 to the kilosort3-code image, to do a local build of mex functions.
ARG VERSION=r2022b
FROM ninjaben/kilosort3-code:$VERSION

# Become root to install more packages.
USER root
WORKDIR /root

# Install the CUDA toolkit v11.2 (goes with Matlab 2022b) -- a large download and install footprint!
# We'll back this out before publishing the final kilosort3 image.
RUN wget -q https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda_11.2.0_460.27.04_linux.run \
    && chmod +x cuda_11.2.0_460.27.04_linux.run \
    && ./cuda_11.2.0_460.27.04_linux.run --silent --toolkit

# Become matlab for mex build going forward.
USER matlab
WORKDIR /home/matlab

# A custom script we'll use here to build mex gpu functions and copy out the resulting binaries.
ADD ./kilosort3MexBuild.m /home/matlab/kilosort3MexBuild.m
