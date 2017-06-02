airsim_nvidia_docker
====================

This setup is in no way ideal, and requires some hacky patches, but:
1. it works on my machine, and
2. its isolated

Prerequisites:

- docker (tested with 17.03.1-ce)
- NVIDIA-Linux-x86_64-381.22.run (from NVIDIA, probably can be changed to match your nvidia driver version)
- UnrealEngine-4.15.zip (Requires signup with Epic Games, downloaded from github)

Build/Run:

    docker build -t airsim_nvidia .
    ./run.sh

This starts up the container with a tmux session with three tabs:

0. PX4 software in the loop
1. AirSim
2. DroneShell, where you can query status and enter commands

Issues:

- Takes a very long time to build
- Final container is pretty big (no excess stuff is removed)
- Patches to both Unreal and AirSim
- Could be more portable to NVIDIA drivers
- Checks out AirSim & PX4 masters, which continuously change
- PX4 and AirSim containers should be separate, but I couldn't get multi-container commmunication to work


