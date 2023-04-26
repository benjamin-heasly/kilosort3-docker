# Start with the MATLAB base image that includes Matlab toolboxes required for Kilosort3.
ARG VERSION=local
FROM ninjaben/matlab-parallel:$VERSION

# Become root to install git.
USER root
WORKDIR /root

# Get git so we can fetch kilosort, then clean up the package manager stuff to save space.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    git \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Become matlab for kilosort ownership and usage going forward.
USER matlab
WORKDIR /home/matlab

# Get Kilosort3, pegged to a specific commit to make this reproducible.
# Unfortunately we need a slightly patched version of the code, as discussed here:
# https://github.com/benjamin-heasly/Kilosort/pull/1
# https://github.com/benjamin-heasly/Kilosort/pull/2
# commit 91eb18e994b801d91bf1a52e418696fb52a56ccf is from 2023-04-26
RUN git clone https://github.com/benjamin-heasly/Kilosort.git /home/matlab/kilosort \
    && git -C /home/matlab/kilosort checkout 91eb18e994b801d91bf1a52e418696fb52a56ccf

# Get npy-matlab, pegged to a specific commit to make this reproducible (no repo tags in this repo).
# commit b7b0a4ef6ba26d98a8c54e651d5444083c88311c is from 2018-11-14
RUN git clone https://github.com/kwikteam/npy-matlab.git /home/matlab/npy-matlab \
    && git -C /home/matlab/npy-matlab checkout b7b0a4ef6ba26d98a8c54e651d5444083c88311c
