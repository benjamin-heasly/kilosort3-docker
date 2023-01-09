# kilosort3-docker
Automated build of Docker image with Kilosort3, Matlab, required toolboxes, and precompiled mexcuda binaries.

This is a work in progress.

# What is this?
To goal of this repo is to document and produce a working [Kilosort3](https://github.com/MouseLand/Kilosort) environment as a Docker image.

This takes advantage of Docker tooling provided by Mathworks, including a Matlab [base image](https://hub.docker.com/r/mathworks/matlab) and [Dockerfile](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/Dockerfile) and the [mpm](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md) package manager.

The basic requirements of Kilosort3 are the same with or without Docker: a Matlab license and NVIDIA GPU hardware.  So these are unchanged.  Hopefully other setup and testing can be captured here in this repo, making those things easier to reproduce and share. 

# Outline
Here's a summary of the host config and Docker image stack that go into this Kilosort3 environment.

![Kilosort3 Docker environment includes Docker image layers and host config.](kilosort3-docker.png)

## Host config
To support GPU-accelerated Docker containers, we have to do some host configuration.  It should be possible to accomplish equvalent setup on Linux or Windows 11+, and from there run use the same Docker images.

### Windows 11
NVIDIA Docker setup for Windows 11 is documented well by [Canonical](https://ubuntu.com/tutorials/enabling-gpu-acceleration-on-ubuntu-on-wsl2-with-the-nvidia-cuda-platform#3-install-nvidia-cuda-on-ubuntu) and NVIDIA(https://docs.nvidia.com/cuda/wsl-user-guide/index.html#cuda-support-for-wsl-2)

This requires Windows 11 (or some later builds of Windows 10), with the **Windows** NVIDIA drivers installed via the standard process in Windows.  This uses [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) for Windows, which takes advantage of the [Windows Subsystem for Linux Version 2](https://learn.microsoft.com/en-us/windows/wsl/install) (WSL 2) to run a real Linux kernel alongside Windows itself and exposes the Windows NVIDIA drivers to a Linux distro like Ubuntu.  Finally this uses NVIDIA's "wsl-ubuntu" package for the WSL 2 Linux distro, which provides NVIDIA tools but doesn't interfere with how the NVIDIA drivers are exposed to Linux.

### Linux
Linux setup in general might be hard to document, but the key requirements are: a Linux distro with NVIDIA drivers, Docker and a the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).  If you are lucky, all of these might be available from your distribution's package manager.  Here's a Medium post that gives a possible [overview on Ubuntu](https://towardsdatascience.com/how-to-properly-use-the-gpu-within-a-docker-container-4c699c78c6d1).

## Docker images
The main artifact produced from this repo is a Docker image called [ninjaben/kilosort3](https://hub.docker.com/repository/docker/ninjaben/kilosort3/general).  Hopefully you can pull this image to a host configured as above, and start running Kilosort3 (see example commands, below).

This final image is built up from a few layers.

### ninjaben/matlab-parallel
This image starts from the offical [mathworks/matlab:r2022b](https://hub.docker.com/layers/mathworks/matlab/r2022b/images/sha256-57ca75286d78269ccbec9da5de91bf223e0e3221387ad4cff23f9c9f1e054caa?context=explore) image.  It uses [Matlab Package Manager](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md) to install Matlab toolkboxes required for Kilosort:

 - Parallel_Computing_Toolbox
 - Signal_Processing_Toolbox
 - Statistics_and_Machine_Learning_Toolbox

The [ninjaben/matlab-parallel](https://hub.docker.com/repository/docker/ninjaben/matlab-parallel/general) image is available on Docker Hub.

### ninjaben/kilosort3-code
This image builds on `ninjaben/matlab-parallel` and adds Git and [Kilosort3](https://github.com/MouseLand/Kilosort).  It keeps Git installed as a way to log the Kilosort3 Git commit hash at runtime.

The [ninjaben/kilosort3-code](https://hub.docker.com/repository/docker/ninjaben/kilosort3-code/general) image is available on Docker Hub.

### kilosort3-build
This is a temp image, meant to be created locally and used temporarily.  It builds on the `ninjaben/kilosort3-code` image and adds the [NVIDIA CUDA Toolkit version 11.2](https://developer.nvidia.com/cuda-11.2.0-download-archive?).  This is the version of the CUDA Toolkit [required for Matlab r2022b](https://www.mathworks.com/help/parallel-computing/run-cuda-or-ptx-code-on-gpu.html#mw_20acaa78-994d-4695-ab4b-bca1cfc3dbac).

This also adds a Matlab build script which runs in Matlab.  It uses [mexcuda](https://www.mathworks.com/help/parallel-computing/mexcuda.html) to compile Kilosort's GPU-accelerated mex-functions.  Along with these it compiles the Matlab [mexGPUExample](https://www.mathworks.com/help/parallel-computing/run-mex-functions-containing-cuda-code.html;jsessionid=e95d76741f7a523fe248a3c99320) function as a diagnostic for `mexcuda` configuration, and for runtime diagnostic later on (see example commands below).

Since this step runs in Matlab, it's not a good candidate for automated building with GitHub and Docker Hub.  Also, the CUDA Toolkit adds several GB to the Docker image, so it would be inconvenient to include this in Docker images that follow.

To address both these challenges, this step can be run locally (I ran it on my laptop, which has Matlab, but not NVIDIA hardware).  The `mexcuda` build results are saved here in this repo, so that the last image can be build automatically, below.

WIP...

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
