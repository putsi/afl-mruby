# MRuby fuzzer

* MRuby fuzzer that runs inside Ubuntu 17.04 container.
* Fuzzing is done with AFL-Fuzzer that uses llvm-mode with LLVM and CLANG version 4.0.
* Fuzzer stub is afl-persistent --> 5000 testcases per one process cycle.
