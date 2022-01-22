#! /bin/bash

# This script has only been tried on an Ubuntu 20.04 system.  The list
# of packages to install _might_ still be incomplete, since in my
# testing I started from a system that had a few packages installed
# already before my testing began.

set -x

sudo apt-get install \
    cmake \
    g++ \
    libboost-iostreams1.71-dev \
    libboost-log1.71-dev \
    libboost-wave1.71-dev \
    ninja-build \
    pkg-config \
    rapidjson-dev

git clone https://github.com/dmakarov/p4ls
cd p4ls

P4LS_ROOT=$PWD

mkdir -p build/ninja/release
cd build/ninja/release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DHUNTER_ENABLED=OFF -DUNITTESTS_ENABLED=OFF $P4LS_ROOT

# Note: The next command both builds and also tries to install the
# resulting binary executable program in /usr/local/bin.  The step to
# install in /usr/local/bin fails unless you have permission to write
# to that directory.  Rather than running the entire build as root
# using 'sudo', I feel more comfortable letting this command build as
# a normal user, then fail on that last step, _then_ running the
# command again with 'sudo' which skips over all the build steps,
# since it detects they have already been done, and only copies the
# executable program to /usr/local/bin

# I am sure there must be a way to run the build step without trying
# to copy the binary into /usr/local/bin, but I do not yet know what
# that command is.

cmake --build . --target server/daemon/install
sudo cmake --build . --target server/daemon/install
