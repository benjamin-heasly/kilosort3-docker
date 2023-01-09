# Start with the MATLAB base image that includes Matlab toolboxes required for Kilosort3.
ARG VERSION=r2022b
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

# Get Kilosort3, pegged to a specific commit to make this reproducible (no repo tags yet for kilosort 3).
# commit 1a1fd3ae07a49c042b4128d6c2e79d6ab55872e5 is from 2022-03-09
RUN git clone https://github.com/MouseLand/Kilosort.git /home/matlab/kilosort \
    && git -C /home/matlab/kilosort checkout 1a1fd3ae07a49c042b4128d6c2e79d6ab55872e5
