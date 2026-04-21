# Kubernetes Manifest Patterns

## Standard Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-name
  labels:
    app: app-name
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-name
  template:
    metadata:
      labels:
        app: app-name
    spec:
      containers:
      - name: main
        image: app-image:v1
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
```

## Service (ClusterIP)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-name
spec:
  selector:
    app: app-name
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

## Ingress (Nginx)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-name
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-name
            port:
              number: 80
```
