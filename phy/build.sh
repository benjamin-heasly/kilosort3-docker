#!/bin/sh

set -e

sudo docker build -t ninjaben/phy:local .

sudo docker run -it --rm ninjaben/phy:local


sudo docker run -it --rm \
 --env="DISPLAY" \
 --env="QT_X11_NO_MITSHM=1" \
 --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
 -v "/home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM:/home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM" \
 ninjaben/phy:local \
 phy template-gui /home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM/Circus/MM_2022_11_28C_V-ProRec.plx.GUI/params.py

sudo docker run -it --rm \
 --env="LIBGL_ALWAYS_SOFTWARE=1" \
 --env="DISPLAY" \
 --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
 -v "/home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM:/home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM" \
 ninjaben/phy:local \
 phy template-gui /home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM/Circus/MM_2022_11_28C_V-ProRec.plx.GUI/params.py

