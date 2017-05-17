#!/bin/bash
xhost +local:root; \
docker run -it \
     --env="DISPLAY" \
     --env="QT_X11_NO_MITSHM=1" \
     --device="/dev/nvidia0:/dev/nvidia0" \
     --device="/dev/nvidiactl:/dev/nvidiactl" \
     --device="/dev/nvidia-modeset:/dev/nvidia-modeset" \
     --device="/dev/nvidia-uvm:/dev/nvidia-uvm" \
     --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
     --volume="$PWD/Documents:/home/unreal/Documents" \
     --cap-add sys_nice \
     airsim_nvidia
