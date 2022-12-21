# Start with the MATLAB base image (published on Docker Hub).
FROM mathworks/matlab:r2022b

# Become root to install more toolboxes.
USER root
WORKDIR /root

# Run mpm to install MATLAB toolboxes, then delete mpm itself to save space.
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \ 
    && chmod +x mpm \
    && ./mpm install \
    --release=r2022b \
    --destination=/opt/matlab/R2022b/ \
    --products Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log

# Get git so we can fetch kilosort, then clean up the package manager stuff to save space.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    git \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Become matlab for kilosort ownership and future Matlab usage.
USER matlab
WORKDIR /home/matlab

# Get Kilosort3, pegged to a specific commit to make this reproducible (no repo tags yet for kilosort 3).
# commit 1a1fd3ae07a49c042b4128d6c2e79d6ab55872e5 is from 2022-03-09
RUN git clone https://github.com/MouseLand/Kilosort.git /home/matlab/kilosort \
    && git -C /home/matlab/kilosort checkout 1a1fd3ae07a49c042b4128d6c2e79d6ab55872e5

# On Matlab start, log useful info and add kilosort to the path.
ADD ./startup.m /home/matlab/Documents/MATLAB/startup.m
