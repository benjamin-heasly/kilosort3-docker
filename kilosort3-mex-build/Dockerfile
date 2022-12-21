# Start with our image that has Matlab and Kilosort
FROM kilosort3-dependencies

# Become root to install more packages.
USER root
WORKDIR /root

# Install the CUDA toolkit v11.2 (goes with Matlab 2022b) -- a large download and install footprint!
# We'll back this out before publishing the final kilosort3 image.
RUN wget -q https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda_11.2.0_460.27.04_linux.run \
    && chmod +x cuda_11.2.0_460.27.04_linux.run \
    && ./cuda_11.2.0_460.27.04_linux.run --silent --toolkit

# Become matlab for normal usage going forward.
USER matlab
WORKDIR /home/matlab

# A custom script we'll use here to build mex gpu functions and copy out the results.
ADD ./kilosort3MexBuild.m /home/matlab/kilosort3MexBuild.m
