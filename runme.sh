#!/bin/bash


# Delete all containers
#             docker rm $(docker ps -a -q)
# Delete all images
#             docker rmi $(docker images -q)

# Build Docker image.
docker build --tag=afl-mruby .

# Make sure that host machine supports AFL-based fuzzing.
echo core >/proc/sys/kernel/core_pattern
(cd /sys/devices/system/cpu && echo performance | tee cpu*/cpufreq/scaling_governor)

# Start the fuzzer and use testcases- and results-dir from local host directory.
docker run --cap-add=SYS_PTRACE --privileged -t -v $(pwd)/testcases:/testcases -v /dev/shm:/results afl-mruby
