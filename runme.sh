#!/bin/bash


read -p "DANGEROUS! Wipe Docker images and containers (y/n)? " WIPE
case "$WIPE" in
  y|Y ) docker rm $(docker ps -a -q);docker rmi $(docker images -q);;
  n|N ) ;;
  * ) echo "Not going to wipe docker.";;
esac


read -p "Enable AddressSanitizer (y/n)? " USE_ASAN
case "$USE_ASAN" in
  y|Y ) sed -i 's/#.*conf.cc.flags/conf.cc.flags/g' build_config.rb;sed -i 's/#.*conf.linker.flags/conf.linker.flags/g' build_config.rb;;
  n|N ) sed -i 's/conf.cc.flags/#conf.cc.flags/g' build_config.rb;sed -i 's/conf.linker.flags/#conf.linker.flags/g' build_config.rb;;
  * ) echo "Invalid choice."; exit;;
esac

read -p "Fuzz or triage (afl/gcc)? " USE_AFL
case "$USE_AFL" in
  afl|Afl|AFL ) sed -i 's/toolchain :gcc$/toolchain :afl/g' build_config.rb;;
  gcc|Gcc|GCC ) sed -i 's/toolchain :afl$/toolchain :gcc/g' build_config.rb;;
  * ) echo "Invalid choice, write \"afl\" if you want to fuzz or write \"gcc\" if you only want to compile mruby.";exit;;
esac

# Build Docker image.
docker build --tag=afl-mruby .

# Make sure that host machine supports AFL-based fuzzing.
echo core >/proc/sys/kernel/core_pattern
(cd /sys/devices/system/cpu && echo performance | tee cpu*/cpufreq/scaling_governor)

# Start the fuzzer and use testcases- and results-dir from local host directory.
docker run --cap-add=SYS_PTRACE --privileged -t -v $(pwd)/testcases:/testcases -v /dev/shm:/results afl-mruby
