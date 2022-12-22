#!/bin/sh

set -e

# Create a base image with kilosort code, Matlab, and required Matlab toolboxes, same as used in build.sh.
sudo docker build -t kilosort3-dependencies ./kilosort3-dependencies

# Create a final image with kilosort and Matlab as above, plus mex gpu binaries that were prebuilt in build.sh.
sudo docker build -t kilosort3 ./kilosort3
