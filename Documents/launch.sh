#!/bin/bash

cd /home/unreal/AirSim/build_debug/output/bin
tmux new-session -s airsim -n shell -d
tmux new-window -t airsim:1 -n sitl -c /home/unreal/Firmware
tmux new-window -t airsim:2 -n sim -c /home/unreal/out/LinuxNoEditor/Blocks/Binaries/Linux/

tmux send-keys -t airsim:1 "sudo ./build_posix_sitl_default/src/firmware/posix/px4 ~/Documents/px4_sitl_airsim" C-m
sleep 1
tmux send-keys -t airsim:2 "./Blocks-Linux-Shipping" C-m
sleep 5
tmux send-keys -t airsim:0 "LD_LIBRARY_PATH=../../../llvm-build/lib ./DroneShell" C-m

tmux select-window -t airsim:0
tmux attach-session -t airsim
