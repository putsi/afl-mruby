# MRuby fuzzer environment

* MRuby fuzzer that runs inside Docker-container (Ubuntu 17.04).
* Fuzzing is done with [AFL-Fuzzer](http://lcamtuf.coredump.cx/afl/) and uses llvm-mode with LLVM/CLANG 4.0.
* Supports AddressSanitizer (enable manually in build_config.rb).
* Fuzzer stub is afl-persistent --> Runs 1000 testcases per one process cycle.
* Fuzzing is done mostly in ramdisk, thus no hdd bottlenecks.
* Automatic triaging of new crashes with [crashwalk](https://github.com/bnagy/crashwalk).
* Built-in multi-core support. Automatically starts 1 AFL master instance and CPU_CORE_COUNT-1 slave instances. 

## How to use

1. Clone the repo.
2. Open the repo directory and run `mkdir testcases`.
3. Copy initial testcases to testcases-directory.
    * If you don't have any, run get_testcases_from_github_issues.py. It will fetch testcases (markdown code blocks) from MRuby Github issues.
4. Run `./runme.sh` to start fuzzing.
5. The script will build the container, configure required host machine values and launch fuzzer container. 
    * The fuzzer will load initial testcases from the host-machine testcases-directory and will save all output (incl. fuzzer binary) to host-machine /dev/shm directory (ramdisk).
    * When the fuzzer is running, container shows a status screen (afl-whatsup) which has basic info about the afl-fuzzers.
    * New crashes are triaged couple times per minute and saved to crashwalk database. A text-based log of unique crashes can be found in results-directory.

## TODO
* Add support for locating the commit that introduced a crash (git bisect?).
* Automatically create Markdown-reports that contain (modify crashwalk?):
    * Testcase (base64-encoded).
    * Crashwalk trace.
    * Commit that introduced the crash.
    * ???
* Add support for deduplicating crashes (search existing issue from Github).
* Add more lists to readme.
