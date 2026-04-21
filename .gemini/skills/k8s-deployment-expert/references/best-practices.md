# Kubernetes Best Practices

## Resource Management
- **Always set requests and limits**: Prevents noisy neighbor issues and allows proper scheduling.
- **CPU**: Limit should be set to allow bursting, but requests should match baseline usage.
- **Memory**: Requests and Limits should ideally be equal to prevent OOM kills due to overcommitment.

## Health Checks
- **Liveness Probes**: Detect when a container is in a broken state and needs a restart.
- **Readiness Probes**: Detect when a container is ready to accept traffic.
- **Startup Probes**: Use for slow-starting legacy apps to prevent premature liveness kills.

## Security
- **runAsNonRoot: true**: Ensure the container does not run as root.
- **readOnlyRootFilesystem: true**: Prevent writes to the container's root filesystem.
- **automountServiceAccountToken: false**: Disable unless explicitly needed.

## Reliability
- **RollingUpdate**: Set `maxUnavailable` and `maxSurge` to ensure availability during updates.
- **PodDisruptionBudgets**: Protect critical workloads during node maintenance.
