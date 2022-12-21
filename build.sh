#!/bin/sh

set -e

# Create a base image with kilosort code, Matlab, and required Matlab toolboxes.
sudo docker build -t kilosort3-dependencies ./kilosort3-dependencies

# Create a second, temp image that also has CUDA toolkit installed.
# The toolkit adds several GB to the image!
# Instead of carrying the toolkit around forever, we'll use this image just to build kilosort mex gpu functions,
# Then we'll create a final image that carries the mex gpu binaries forward.
sudo docker build -t kilosort3-mex-build ./kilosort3-mex-build

# Run a container to actually build the kilosort mex gpu functions.
# We'll grab the results and add them to the final kilosort3 image, below.
# This allows us to omit the large CUDA toolkit from the final kilosort3 image.
# Actually running matlab here, so we need to configure a license.
# This uses a local license file, and there are other ways, see: https://hub.docker.com/r/mathworks/matlab
LICENSE_MAC_ADDRESS=$(cat /sys/class/net/en*/address)
LICENSE_FILE="$(pwd)/license.lic"
BIN_DIR="$(pwd)/kilosort3/kilosort3-binaries"
mkdir -p "$BIN_DIR"
chmod a+w "$BIN_DIR" 
sudo docker run -ti --rm \
  --mac-address "$LICENSE_MAC_ADDRESS" \
  -v $LICENSE_FILE:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  -v "$BIN_DIR":/home/matlab/kilosort3-binaries/ \
  kilosort3-mex-build \
  -batch "run /home/matlab/kilosort3MexBuild.m"

# Create a final image with kilosort and Matlab as above, plus mex gpu binaries we just built.
# This image omits the large CUDA toolkit.
sudo docker build -t kilosort3 ./kilosort3

# Now that we're done, clean up a bit.
# We don't need to keep the large, intermediate kilosort3-mex-build image.
sudo docker rmi kilosort3-mex-build
sudo docker system prune -f
