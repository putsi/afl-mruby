# MRuby fuzzer

* MRuby fuzzer that runs inside Ubuntu 17.04 container.
* Fuzzing is done with AFL-Fuzzer that uses llvm-mode with LLVM and CLANG version 4.0.
* Fuzzer stub is afl-persistent --> 5000 testcases per one process cycle.

## How to use

1. Clone the repo.
2. Open the repo directory and run `mkdir results testcases`.
3. Copy initial testcases to testcases-directory. These are just plain compilable Ruby source code files.
4. Run `./runme.sh` to start fuzzing.
5. The fuzzer will now start as many fuzzing-instances as the Docker host has CPU-cores. The instances will load initial testcases from the host-machine testcases-directory and will save all output to host-machine results-directory. 
