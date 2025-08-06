# Linux Crisis Tools

This repository provides a `Dockerfile` to create a container image with pre-installed Linux crisis tools, as recommended in Brendan Gregg's blog post "[Linux Crisis Tools](https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html)." The image is designed for debugging performance issues in Kubernetes production environments, ensuring essential diagnostic tools are readily available without installation delays during outages.

## Purpose

When a performance issue causes an outage in a Kubernetes cluster, installing diagnostic tools on the fly can waste critical time. This Docker image pre-installs a comprehensive set of Linux crisis tools to enable rapid debugging of performance bottlenecks in Kubernetes production environments.

## Tools Included

The `Dockerfile` installs the following packages, as recommended by Brendan Gregg, on an Ubuntu base image:

| Package                                         | Provides                                                                                                                                                                           | Notes                   |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `procps`                                        | `ps(1)`, `vmstat(1)`, `uptime(1)`, `top(1)`                                                                                                                                        | Basic stats             |
| `util-linux`                                    | `dmesg(1)`, `lsblk(1)`, `lscpu(1)`                                                                                                                                                 | System log, device info |
| `sysstat`                                       | `iostat(1)`, `mpstat(1)`, `pidstat(1)`, `sar(1)`                                                                                                                                   | Device stats            |
| `iproute2`                                      | `ip(1)`, `ss(8)`, `nstat(8)`, `tc(8)`                                                                                                                                              | Preferred net tools     |
| `numactl`                                       | `numastat(8)`                                                                                                                                                                      | NUMA stats              |
| `tcpdump`                                       | `tcpdump(8)`                                                                                                                                                                       | Network sniffer         |
| `linux-tools-common`, `linux-tools-$(uname -r)` | `perf(1)`, `turbostat(8)`                                                                                                                                                          | Profiler and PMU stats  |
| `bpfcc-tools`                                   | `opensnoop(1)`, `execsnoop(8)`, `runqlat(8)`, `biotop(8)`, `biosnoop(8)`, `biolatency(8)`, `tcptop(8)`, `tcplife(8)`, `trace(8)`, `argdist(8)`, `funccount(8)`, `profile(8)`, etc. | Canned eBPF tools       |
| `bpftrace`                                      | `bpftrace(8)`, basic versions of `opensnoop(8)`, `execsnoop(8)`, `runqlat(8)`, `biosnoop(8)`, etc.                                                                                 | eBPF scripting          |
| `trace-cmd`                                     | `trace-cmd(1)`                                                                                                                                                                     | Ftrace CLI              |
| `nicstat`                                       | `nicstat(1)`                                                                                                                                                                       | Net device stats        |
| `ethtool`                                       | `ethtool(8)`                                                                                                                                                                       | Net device info         |
| `tiptop`                                        | `tiptop(1)`                                                                                                                                                                        | PMU/PMC top             |
| `cpuid`                                         | `cpuid(1)`                                                                                                                                                                         | CPU details             |
| `msr-tools`                                     | `rdmsr(8)`, `wrmsr(8)`                                                                                                                                                             | CPU digging             |

> [!NOTE]
> Some tools (e.g., `bpfcc-tools`, `bpftrace`) require kernel headers and specific privileges to function fully. Ensure your Kubernetes environment grants necessary permissions (e.g., `SYS_ADMIN` capabilities or privileged mode) for eBPF and tracing tools.

## Prerequisites

- Kubernetes cluster for deploying the container.
- Familiarity with Kubernetes debugging workflows (e.g., `kubectl exec` for accessing containers).
- For eBPF tools (e.g., `bpfcc-tools`, `bpftrace`), ensure the Kubernetes node kernel supports BPF and the container has appropriate capabilities.

## Usage in Kubernetes

To use this image in a Kubernetes cluster for debugging:

1. Create a pod manifest to run the image with appropriate permissions. For example:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: crisis-tools-pod
   spec:
     containers:
       - name: crisis-tools
         image: <your-registry>/linux-crisis-tools:latest
         command: ["sleep", "infinity"]
         securityContext:
           privileged: true
   ```

2. Apply the pod manifest:

   ```bash
   $ kubectl apply -f crisis-tools-pod.yaml
   ```

3. Use `kubectl exec` to access the pod and run diagnostic commands:

   ```bash
   $ kubectl exec -it crisis-tools-pod -- bash
   ```

4. Inside the pod, you can run diagnostic commands like:
   ```bash
   $ iostat -xz 1
   $ tcpdump -i eth0
   $ perf stat -a sleep 10
   $ bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'
   ```

> [!WARNING]
> Running privileged containers or granting capabilities like `SYS_ADMIN` can pose security risks. Use this image only in controlled debugging scenarios and remove the pod after use.

## Contributing

If you believe additional crisis tools should be included or have improvements to the `Dockerfile`, please open an issue or submit a pull request. Ensure any suggested tools align with the goal of lightweight, essential diagnostics for Kubernetes production environments.

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
