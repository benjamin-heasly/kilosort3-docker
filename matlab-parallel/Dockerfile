# Start with the MATLAB base image (published on Docker Hub).
FROM mathworks/matlab:local

# Become root to install more toolboxes.
USER root
WORKDIR /root

# Run mpm to install MATLAB toolboxes, then delete mpm itself to save space.
# - Parallel_Computing_Toolbox
# - Signal_Processing_Toolbox
# - Statistics_and_Machine_Learning_Toolbox
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \ 
    && chmod +x mpm \
    && ./mpm install \
    --release=r2022b \
    --destination=/opt/matlab/R2022b/ \
    --products Parallel_Computing_Toolbox Signal_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log

# Become matlab again, to match the base image.
USER matlab
WORKDIR /home/matlab
