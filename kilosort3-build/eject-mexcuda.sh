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

# Run a series of containers to capture the output of "mexcuda -v", for each of the mex gpu functions we want.
# This will let us build them outside of Matlab and fully automate the image build process!
# Nobody will have to supply a Matlab license until Kilosort runtime.

# This command is for the Matlab mexGPUExample, used as a diagnostic for config and runtime.
LICENSE_MAC_ADDRESS=$(cat /sys/class/net/en*/address)
LICENSE_FILE="$(pwd)/license.lic"
sudo docker run --rm \
  --mac-address "$LICENSE_MAC_ADDRESS" \
  -v $LICENSE_FILE:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  kilosort3-build:temp \
  -batch "run /home/matlab/kilosort3MexEject.m" \
  > mexEject.log
