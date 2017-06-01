FROM ubuntu:xenial
RUN apt-get update && apt-get install -y mesa-utils binutils module-init-tools && rm -rf /var/lib/apt/lists/*
ADD NVIDIA-Linux-x86_64-381.22.run /tmp/NVIDIA-DRIVER.run
RUN sh /tmp/NVIDIA-DRIVER.run -a -N --ui=none --no-kernel-module
RUN rm /tmp/NVIDIA-DRIVER.run

RUN apt-get update && apt-get install -y git wget unzip build-essential software-properties-common cmake && rm -rf /var/lib/apt/lists/*
RUN wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.9 main"
RUN apt-get update && apt-get install -y --allow-unauthenticated clang-3.9 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.9 60 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.9
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
RUN update-alternatives --install /usr/bin/cxx cxx /usr/bin/clang++ 100

ENV TZ America/New_York

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash unreal && echo "unreal:unreal" | chpasswd && adduser unreal sudo
RUN echo "unreal ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER unreal

RUN sudo apt-get update && sudo apt-get install -y libnss3 libpangocairo-1.0-0 libgconf-2-4 libxi-dev libxcursor-dev libxss-dev libxcomposite-dev libasound-dev libatk1.0-dev libxrandr-dev libxtst-dev libopenal-dev && sudo rm -rf /var/lib/apt/lists/*
COPY UnrealEngine-4.15.zip /home/unreal/UnrealEngine-4.15.zip
RUN cd ~/ && unzip UnrealEngine-4.15.zip && rm UnrealEngine-4.15.zip
COPY ltc4.patch /home/unreal/ltc4.patch
RUN cd ~/UnrealEngine-4.15/Engine/Source/Programs/UnrealBuildTool/Linux && patch -p0 < ~/ltc4.patch
RUN sudo apt-get update && cd ~/UnrealEngine-4.15 && ./Setup.sh && ./GenerateProjectFiles.sh

RUN cd ~/ && git clone https://github.com/Microsoft/AirSim.git && cd AirSim && git checkout f78f11774055fa7381c9cdf6dc08265c93864226 && cd cmake && sudo bash ./getlibcxx.sh; exit 0

COPY 0001-Various-Fixes.patch /home/unreal/0001-Various-Fixes.patch
RUN cd ~/AirSim && git apply /home/unreal/0001-Various-Fixes.patch
RUN cd ~/AirSim && ./build.sh
RUN cd ~/AirSim && rsync -t -r Unreal/Plugins Unreal/Environments/Blocks
ENV EIGEN_ROOT /home/unreal/AirSim/eigen

RUN cd ~/UnrealEngine-4.15 && ./GenerateProjectFiles.sh -project="/home/unreal/AirSim/Unreal/Environments/Blocks/Blocks.uproject" -game -engine

RUN mkdir -p /home/unreal/out
RUN cd ~/AirSim/Unreal/Environments/Blocks && ~/UnrealEngine-4.15/Engine/Build/BatchFiles/RunUAT.sh BuildCookRun -project="$PWD/Blocks.uproject" -platform=Linux -clientconfig=Shipping -cook -allmaps -build -stage -pak -archive -archivedirectory="/home/unreal/out"

RUN sudo apt-get update && sudo apt-get -y install git build-essential cmake python unzip python-jinja2 python-empy python-pip && sudo rm -rf /var/lib/apt/lists/*
RUN sudo pip install catkin_pkg
RUN sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 90
RUN sudo update-alternatives --install /usr/bin/cxx cxx /usr/bin/g++ 90
RUN sudo update-alternatives --set cc /usr/bin/gcc
RUN sudo update-alternatives --set cxx /usr/bin/g++
RUN cd ~/ && git clone https://github.com/PX4/Firmware.git && cd Firmware && make posix_sitl_default

LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN sudo apt-get update && sudo apt-get -y install tmux && sudo rm -rf /var/lib/apt/lists/*

CMD bash /home/unreal/Documents/launch.sh
