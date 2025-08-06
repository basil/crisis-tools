FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bpfcc-tools \
        bpftrace \
        cpuid \
        ethtool \
        htop \
        iproute2 \
        linux-tools-common \
        linux-tools-generic \
        msr-tools \
        nicstat \
        numactl \
        procps \
        sysstat \
        tcpdump \
        tiptop \
        trace-cmd \
        util-linux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]