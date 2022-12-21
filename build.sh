#!/bin/sh

set -e

# Create a base image with kilosort code, Matlab, and required Matlab toolboxes.
sudo docker build -t kilosort3-dependencies ./kilosort3-dependencies

# Create a second, temp image that also has CUDA toolkit installed.
# This adds several GB to the image!
# Instead of carrying the toolkit around, we'll use this to build kilosort mex gpu functions,
# Then we'll create a final image that just carries the mex gpu binaries forward.
sudo docker build -t kilosort3-mex-build ./kilosort3-mex-build

# Run a container to actually build the kilosort mex gpu functions.
# We'll grab the results and add them to the final kilosort3 image, below.
# This allows us to omit the large CUDA toolkit from the final kilosort3 image.
# This uses a machine-specific local Matlab licence file.
BIN_DIR="$(pwd)/kilosort3/kilosort3-binaries"
mkdir -p "$BIN_DIR"
chmod a+w "$BIN_DIR" 
sudo docker run -ti --rm \
  --mac-address "68:f7:28:f6:68:a6" \
  -v /home/ninjaben/Desktop/codin/gold-lab/license.lic:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  -v "$BIN_DIR":/home/matlab/kilosort3-binaries/ \
  kilosort3-mex-build \
  -batch "run /home/matlab/kilosort3MexBuild.m"

# Create a final image with kilosort code, Matlab, and required Matlab toolboxes as above,
# plus the mex gui binaries we just build, but not the large CUDA toolkit.
sudo docker build -t kilosort3 ./kilosort3
