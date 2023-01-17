FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    qtbase5-dev \
    python3 python3-pip \
    '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev libfontconfig1-dev libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev gperf bison nodejs \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash phy
USER phy
WORKDIR /home/phy

# As of Jan 2023, phy is not compatible with numpu 1.24, so use 1.23.5
ENV PATH="$PATH:/home/phy/.local/bin"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir numpy==1.23.5 \
    && pip install --no-cache-dir --pre --upgrade phy

CMD ["phy", "--help"]
