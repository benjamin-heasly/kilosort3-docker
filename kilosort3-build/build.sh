#!/bin/sh

set -e

# This step runs locallt and invokes Matlab with a license.
# The results are saved in ../kilosort3.
# We should only need to re-run when we change the Matlab, CUDA, or Kilosort3 version.

# Create temp image with kilosort3-code, plus the CUDA toolkit installed.
# The toolkit adds several GB to the image!
# Instead of carrying the toolkit around forever, we'll use this image once to build kilosort mex gpu functions,
# Then we'll create a final image that cherry-picks the mex gpu binaries from that and leaves out the toolkit.
sudo docker build -t kilosort3-build:temp .

# Run a container to actually build the kilosort mex gpu functions.
# We'll grab the resulting binaries and save them to the kilosort3 folder.
# We should only have to do this once.
# After that, we should just be able to run the kilosort3 image build as-is.

# Since this step actually runs Matlab, we'll need to configure a license.
# This assumes a local ./licence.lic issued for a local MAC address.
# There are other ways to set up the Matlab license with Docker, too: https://hub.docker.com/r/mathworks/matlab
LICENSE_MAC_ADDRESS=$(cat /sys/class/net/en*/address)
LICENSE_FILE="$(pwd)/license.lic"
BIN_DIR="$(pwd)/../kilosort3/kilosort3-binaries"
mkdir -p "$BIN_DIR"
chmod a+w "$BIN_DIR" 
sudo docker run --rm \
  --mac-address "$LICENSE_MAC_ADDRESS" \
  -v $LICENSE_FILE:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  -v "$BIN_DIR":/home/matlab/kilosort3-binaries/ \
  kilosort3-build:temp \
  -batch "run /home/matlab/kilosort3MexBuild.m"

# Now that we're done, clean up a bit.
# We don't need to keep the large, intermediate kilosort3-build:temp image.
sudo docker rmi kilosort3-build:temp
sudo docker system prune -f
