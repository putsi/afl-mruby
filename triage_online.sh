#!/bin/bash

echo "Triaging all testcases of crashwalk-db at http://mruby.science!"
for testcase in $(/root/gopath/bin/cwdump /results/crashwalk.db |grep Command |cut -d" " -f3- |sed 's/^/\/results\//'); do /mruby/bin/triage_online.py $testcase; done > /results/triage_online.txt 2>&1
echo "Done, see log at /results/triage_online.txt and below:"
cat /results/triage_online.txt
