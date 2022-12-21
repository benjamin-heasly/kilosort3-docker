# kilosort3-docker
Kilosort3 with Matlab, required toolboxes, and compiled mex gpu functions.

This is a work in progress.

# What is this?
To goal of this repo is to document and produce a working [Kilosort3](https://github.com/MouseLand/Kilosort) environment as a Docker image.

This takes advantage of Docker tooling provided by Mathworks, including a Matlab [base image](https://hub.docker.com/r/mathworks/matlab) and [Dockerfile](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/Dockerfile) and the [mpm](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md) package manager.

Kilosort3 requires NVIDIA GPU hardware in order to run, so that is still a requirement.  Hopefully other setup and testing can be captured here and become easy to reproduce and share. 

# Outline

Running `build.sh` should produce a new, local Docker image named `kilosort3`.  This should have Kilosort3, Matlab, Matlab toolboxes that are required for Kilosort3 (Parallel_Computing_Toolbox, Signal_Processing_Toolbox, and Statistics_and_Machine_Learning_Toolbox), and compiled mex gpu binaries built from Kilosort3 source.

Here's how the image is built up:

 1. Create a base image named `kilosort3-dependencies` that has Kilosort3 code, Matlab 2022b, and required Matlab toolboxes.
 2. Create a temp image named `kilosort3-mex-build` that has dependencies above, plus [CUDA Toolkit 11.2](https://developer.nvidia.com/cuda-11.2.0-download-archive?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=runfilelocal), [as required for Matlab 2022b](https://www.mathworks.com/help/parallel-computing/run-cuda-or-ptx-code-on-gpu.html#mw_20acaa78-994d-4695-ab4b-bca1cfc3dbac).
 3. Run a container from `kilosort3-mex-build` to launch Matlab and compile the Kilosort3 mex gpu binaries, and copy the binaries out of the container so we can use them in the next step.
 4. Create the final image named `kilosort3` that has Kilosort3, Matlab, required Matlab toolboxes, and the mex gpu binaries built in the previous step.

## Image sizes and licensing
Why go to the trouble of implementing this in multiple steps?  Why would we want a temp Docker image and a Docker container execution in the middle?  Why not put all of this into `RUN` steps of a single Dockerfile?  The outline here seemed like a solution to a couple of specific challenges:

 - Image sizes -- As we go, these Docker images get large (see the table below).  Creating a temp image with CUDA Toolkit, which we could use then discard, was one way to avoid carrying the whole toolkit around in the final image.
 - Matlab licensing -- In order to build the mex gpu functions for Kilosort3, we need to actually launch Matlab.  This requires some environment configuration.  This config seemed sensible as a one time, runtime step, as opposed to being part of the image creation step.

Here are sizes for the Docker images used and produced by `build.sh`:

```
$ docker images
REPOSITORY               TAG       IMAGE ID       CREATED       SIZE
kilosort3                latest    ef163bb56330   2 hours ago   10.3GB
kilosort3-mex-build      latest    de989b2cd13b   2 hours ago   18.4GB
kilosort3-dependencies   latest    565f24fc9a39   5 hours ago   10.3GB
mathworks/matlab         r2022b    d209dd14c3c4   6 weeks ago   5.85GB
```

5.85GB is already pretty large as a baseline for Matlab.  Adding required Matlab toolboxes brings us to 10.3GB, which is unwieldy, but perhaps unavoidable since dependencies are dependencies.  If we also include the CUDA Toolkit, we're up to 18.4GB!  But the toolkit itself may be avoidable, since we only need it to build the mex gpu functions, not to execute them.  The compiled mex gpu binaries themselves are only a few MB added on top of the 10.3GB from Matlab products.

# TODO

## Distribution
How will we distribute this Docker image?

If 10.3GB is allowed, we might be able to connect this repo as an automated build on [DockerHub](https://hub.docker.com/).

Probably the automated build would not be able to run `build.sh` as-is, since that would require a Matlab license and config.  But we might be able to set up an automated build that includes mex gpu binaries already saved in this repo.  Unfortunately, this would prevent the automated build from going "to ground", all the way back to the source of truth in the Kilosort repo.  But the steps to produce the binaries would still be captured here in this repo.

## Kilosort Testing
The goal of this repo is a working Kilosort environment.  How do we know if it's working?  It would be great to have automated tests we can run to check this.  The tests might have to run locally, since they would depend on the presence of real NVIDIA graphics hardware and a Matlab license.

Unfortunately, the Kilosort project seems not to be set up for easy automated self-testing, [as of 2022](https://github.com/MouseLand/Kilosort/issues/476).  The included "eMouse" code seems like a good starting point, but the [current eMouse code](https://github.com/MouseLand/Kilosort/blob/main/eMouse_drift/main_eMouse_drift.m) would need modifications to work as an automated test -- to remove hard-coded file paths and to focus on automated assertions rather than interactive visualization.

This may be a worthy contribution we can make from here!
