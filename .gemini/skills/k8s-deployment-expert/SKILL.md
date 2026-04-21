---
name: k8s-deployment-expert
description: Provides guidance and best practices for Kubernetes deployments. Use when designing, auditing, or troubleshooting K8s manifests, including Deployments, Services, Ingress, and resource optimization.
---

# Kubernetes Deployment Expert

Expert guidance for architecting, deploying, and managing applications on Kubernetes.

## Core Guidance

- **Manifest Design**: Adhere to structured patterns for Deployments, Services, and Ingress. See [manifest-patterns.md](references/manifest-patterns.md).
- **Production Best Practices**: Ensure reliability and security through proper resource limits, probes, and security contexts. See [best-practices.md](references/best-practices.md).

## Common Tasks

### 1. Generating a Deployment
When asked to create a deployment, use the patterns in `references/manifest-patterns.md` as a base. Ensure you include:
- Labels and Selectors (following naming conventions)
- Resource Limits and Requests
- Liveness and Readiness Probes
- Rolling Update strategy

### 2. Auditing Manifests
When reviewing existing manifests, check against the [best-practices.md](references/best-practices.md) list. Focus on:
- Security Context (runAsNonRoot, readOnlyRootFilesystem)
- Image Pull Policy
- Resource constraints (Missing limits/requests)

### 3. Service & Ingress Setup
- Prefer `ClusterIP` for internal services.
- Use `Ingress` for external access with TLS termination.
- Ensure service selectors match deployment labels.
