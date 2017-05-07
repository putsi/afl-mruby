#!/bin/bash
export TERM=xterm-color

echo "Starting MRuby fuzzing with $(nproc) cores/fuzzers"

SLAVE_COUNT=$(expr $(nproc) - 1)
TESTCASE_DIR=/testcases
AFL_OUT_DIR=/results

# Start master and slaves in background and hide any output.
echo "Starting master-fuzzer"
afl-fuzz -i $TESTCASE_DIR -o $AFL_OUT_DIR -m none -t 10000 -Mmaster-0 -- ./mruby @@ >/dev/null &
for i in $(seq 1 $SLAVE_COUNT); do
    echo "Starting slave $i"
    afl-fuzz -i $TESTCASE_DIR -o $AFL_OUT_DIR -m none -t 10000 -Sslave-$i -- ./mruby @@ >/dev/null &
    sleep 1
done

echo "Done, starting status screen!"

# Loop afl-whatsup so that statistics can be viewed and container does not exit.
while true; do
  clear && echo && date && echo && echo
  afl-whatsup -s /results
  sleep 5
done
