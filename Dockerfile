FROM ubuntu:17.04
MAINTAINER putsi

ENV LANG en_US.UTF-8
ENV AFL_URL http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
ENV MRUBY_URL https://github.com/mruby/mruby.git

# Get required build dependencies.
RUN apt-get update && apt-get -y install \
        wget \
        git \
        ca-certificates \
        build-essential \
        ruby \
        libc6-dev \
        bison \
        libssl-dev \
        libhiredis-dev \
        llvm clang \
        nano gdb strace golang python-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

# Install gdb-peda and exploitable and crashwalk.
RUN git clone https://github.com/longld/peda.git /root/peda && echo "source ~/peda/peda.py" >> /root/.gdbinit
RUN echo "export GOPATH=/root/gopath" >> /root/.bashrc
RUN mkdir /root/src && cd /root/src && git clone https://github.com/jfoote/exploitable.git && cd exploitable \
    && python setup.py install && echo "source /usr/local/lib/python2.7/dist-packages/exploitable-1.32-py2.7.egg/exploitable/exploitable.py" >> /root/.gdbinit
RUN export GOPATH=/root/gopath && go get -u github.com/bnagy/crashwalk/cmd/...

# Get latest version AFL-Fuzzer and install with llvm_mode.
WORKDIR /tmp
RUN wget $AFL_URL --no-verbose \
    && mkdir afl-src \
    && tar -xzf afl-latest.tgz -C afl-src --strip-components=1 \
    && cd afl-src \
    && make \
    && cd llvm_mode && make && cd .. \
    && make install \
    && rm -rf /tmp/afl-latest.tgz /tmp/afl-src

# Get latest MRuby from Github trunk.
WORKDIR /
RUN git clone $MRUBY_URL
WORKDIR /mruby

# Add AFL-related build config and replace mruby-bin code with persistent fuzzer stub.
ADD build_config.rb build_config.rb
ADD stub.c mrbgems/mruby-bin-mruby/tools/mruby/stub.c
RUN cd mrbgems/mruby-bin-mruby/tools/mruby/ && rm -rf mruby.c && mv stub.c mruby.c
RUN AFL_HARDEN=1 ASAN_OPTIONS=detect_leaks=0 ./minirake

# Add fuzzer-script and set it as entrypoint.
WORKDIR /results
ADD fuzz.sh /mruby/bin/fuzz.sh
ENTRYPOINT ["/mruby/bin/fuzz.sh"]
