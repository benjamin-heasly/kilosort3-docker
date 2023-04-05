# Stage 0: Build mex gpu binaries with the CUDA toolkit.
ARG VERSION=local
FROM ninjaben/kilosort3-code:$VERSION as mex-build

# Become root to install more packages.
USER root
WORKDIR /root

# Install the CUDA toolkit v11.2 (goes with Matlab 2022b) -- a large download and install footprint!
# We'll back this out before publishing the final kilosort3 image.
RUN wget -q https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda_11.2.0_460.27.04_linux.run \
    && chmod +x cuda_11.2.0_460.27.04_linux.run \
    && ./cuda_11.2.0_460.27.04_linux.run --silent --toolkit

# Get our mex gpu build script that's equivalent to running mexcuda in Matlab.
COPY ./mex-build.sh /home/matlab/mex-build.sh
RUN chown matlab:matlab /home/matlab/mex-build.sh && chmod 755 /home/matlab/mex-build.sh

# Become matlab for mex build and going forward.
USER matlab
WORKDIR /home/matlab

# Build the mex gpu functions that we'll copy into the next step.
RUN /home/matlab/mex-build.sh


# Stage 1: Copy mex gpu binaries we created in the last step, and set up Matlab for Kilosort.
FROM ninjaben/kilosort3-code:$VERSION

# Copy in compiled kilosort mex gpu binaries from the previous step.
# This way, we don't have to include the large CUDA toolkit going forward.
COPY --from=mex-build /home/matlab/*.mexa64 /home/matlab/mex-gpu-binaries/

# On Matlab start, log useful info and add kilosort to the path.
COPY ./container-startup.m /home/matlab/Documents/MATLAB/startup.m

# Add scripts to test and run Kilosort itself.
COPY ./loadStruct.m /home/matlab/loadStruct.m
COPY ./runKilosort.m /home/matlab/runKilosort.m
COPY ./summarizeRez.m /home/matlab/summarizeRez.m
COPY ./test/ /home/matlab/test/
