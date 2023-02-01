# How this was made:
# Started from QT instructions for developing / compiling QT5 on Ubuntu:
# https://wiki.qt.io/Building_Qt_5_from_Git#Linux.2FX11
# Installed Python 3 and qtbase5-dev, plus the Ubuntu packages mentioned for Libxcb and Qt WebEngine
# Then installed phy and its dependencies.
#
# The steps above produced a working image!
# Running a container from it and passing in X resources, the interactive phy GUI came up.
#  --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"
# On an old laptop with integrated Intel graphics, it was also necessary to fall back to software rendering.
#  --env="LIBGL_ALWAYS_SOFTWARE=1"
#
# This working image was 1.27GB.
# To try getting the size down, replaced "-dev" packages with runtime equivalents, where possible.
# Also removed packages that seem unnecessary like gperf, bison, and nodejs.
# This brought the size down only slightly 1.18GB.
# The bulk of the size seems to be those system libs, plus the PyQt5 Python package.

FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    qtbase5-dev \
    python3 python3-pip \
    '^libxcb.*[^-dev]$' libx11-xcb1 libglu1-mesa libxrender1 libxi6 libxkbcommon0 libxkbcommon-x11-0 \
    libxcursor1 libxcomposite1 libxdamage1 libxrandr2 libxtst6 libxss1 libdbus-1-3 libevent-2.1-7 libfontconfig1 libcap2 libpulse0 libudev-dev libpci3 libnss3 libasound2 libegl1-mesa \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash phy
USER phy
WORKDIR /home/phy

# As of Jan 2023, phy is not compatible with numpy 1.24, so use 1.23.5
# As of Feb 2023, "--upgrade pip" installed pip 23.0, which broke the build, pinning to 22.3.1 which was working.
ENV PATH="$PATH:/home/phy/.local/bin"
RUN pip install --no-cache-dir pip==22.3.1 \
    && pip install --no-cache-dir numpy==1.23.5 \
    && pip install --no-cache-dir --pre --upgrade phy

CMD ["phy", "--version"]
