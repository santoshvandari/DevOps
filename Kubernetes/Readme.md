# Kubernetes Guide

## What is Kubernetes?
Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It provides a robust framework for running distributed systems resiliently, handling scaling and failover for your applications.

## Key Concepts

### Pod
The smallest deployable unit in Kubernetes. A pod can contain one or more containers that share storage and network resources.

### Node
A worker machine in Kubernetes that runs pods. Can be a virtual or physical machine.

### Cluster
A set of nodes that run containerized applications managed by Kubernetes.

### Deployment
Manages a set of replica pods and provides declarative updates to applications.

### Service
An abstraction that defines a logical set of pods and enables network access to them.

### Namespace
Virtual clusters within a physical cluster to organize and isolate resources.

### ConfigMap & Secret
Objects to store configuration data and sensitive information separately from application code.

## Installation and Setup

### Install kubectl (Ubuntu/Debian)
```bash
# Download the latest kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Install Minikube (Local Development)
```bash
# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube cluster
minikube start

# Verify cluster status
kubectl cluster-info
kubectl get nodes
```

### Install kind (Kubernetes in Docker)
```bash
# Download and install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind create cluster --name my-cluster

# Set kubectl context
kubectl cluster-info --context kind-my-cluster
```

## Essential kubectl Commands

### Cluster Information
```bash
# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Get cluster version
kubectl version

# View cluster events
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Working with Pods
```bash
# List pods
kubectl get pods
kubectl get pods -A                    # All namespaces
kubectl get pods -o wide               # More details
kubectl get pods --show-labels        # Show labels

# Create pod from command
kubectl run nginx --image=nginx:latest

# Describe pod
kubectl describe pod <pod-name>

# Get pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>            # Follow logs
kubectl logs <pod-name> -c <container> # Specific container

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec <pod-name> -- ls -la

# Delete pod
kubectl delete pod <pod-name>
```

### Working with Deployments
```bash
# Create deployment
kubectl create deployment nginx --image=nginx:latest
kubectl create deployment app --image=myapp:1.0 --replicas=3

# List deployments
kubectl get deployments
kubectl get deploy

# Scale deployment
kubectl scale deployment nginx --replicas=5
kubectl scale deployment app --replicas=0    # Scale down

# Update deployment
kubectl set image deployment/nginx nginx=nginx:1.21
kubectl rollout restart deployment/nginx

# Rollout management
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2

# Delete deployment
kubectl delete deployment nginx
```

### Working with Services
```bash
# Create service
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service nginx

# Delete service
kubectl delete service nginx
```

### Working with Namespaces
```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace development
kubectl create namespace production

# Set default namespace
kubectl config set-context --current --namespace=development

# Get resources in specific namespace
kubectl get pods -n kube-system
kubectl get all -n development

# Delete namespace
kubectl delete namespace development
```

## YAML Manifests

### Basic Pod Manifest
```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Deployment Manifest
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: ENV
          value: "production"
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Service Manifest
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
---
# NodePort Service
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

### ConfigMap and Secret
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  log_level: "info"
  config.properties: |
    property1=value1
    property2=value2
---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=        # base64 encoded 'admin'
  password: cGFzc3dvcmQ=    # base64 encoded 'password'
```

## Working with YAML Files

### Apply and Manage Resources
```bash
# Apply single file
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Apply multiple files
kubectl apply -f .
kubectl apply -f kubernetes/

# Apply from URL
kubectl apply -f https://raw.githubusercontent.com/user/repo/main/k8s.yaml

# Dry run
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server

# Delete resources
kubectl delete -f deployment.yaml
kubectl delete -f .
```

### Generate YAML from kubectl
```bash
# Generate deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml

# Generate service YAML
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > service.yaml

# Generate pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

## ConfigMaps and Secrets

### Working with ConfigMaps
```bash
# Create ConfigMap from literal values
kubectl create configmap app-config \
  --from-literal=database_url=postgresql://localhost:5432 \
  --from-literal=log_level=info

# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.properties

# Create ConfigMap from directory
kubectl create configmap app-config --from-file=configs/

# View ConfigMap
kubectl get configmaps
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml

# Use ConfigMap in pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: nginx
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
EOF
```

### Working with Secrets
```bash
# Create secret from literal values
kubectl create secret generic app-secrets \
  --from-literal=username=admin \
  --from-literal=password=secret123

# Create secret from files
kubectl create secret generic app-secrets \
  --from-file=username.txt \
  --from-file=password.txt

# Create TLS secret
kubectl create secret tls tls-secret \
  --cert=server.crt \
  --key=server.key

# View secrets
kubectl get secrets
kubectl describe secret app-secrets
kubectl get secret app-secrets -o yaml

# Decode secret values
kubectl get secret app-secrets -o jsonpath='{.data.username}' | base64 -d
```

## Volumes and Storage

### Persistent Volume (PV) and Persistent Volume Claim (PVC)
```yaml
# persistent-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-storage
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data
---
# persistent-volume-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

### Using PVC in Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx
        volumeMounts:
        - name: storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: pvc-storage
```

## Ingress and Load Balancing

### Ingress Controller Setup (NGINX)
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml

# Verify installation
kubectl get pods -n ingress-nginx
kubectl get services -n ingress-nginx
```

### Ingress Resource
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
  - host: api.myapp.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### TLS Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - secure.myapp.local
    secretName: tls-secret
  rules:
  - host: secure.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
```

## Resource Management and Monitoring

### Resource Quotas
```yaml
# resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
    pods: "10"
```

### Limit Ranges
```yaml
# limit-range.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range
  namespace: development
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

### Horizontal Pod Autoscaler (HPA)
```bash
# Create HPA
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10

# View HPA
kubectl get hpa
kubectl describe hpa nginx

# HPA YAML manifest
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF
```

## Troubleshooting and Debugging

### Debugging Commands
```bash
# Get detailed information
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl describe service <service-name>

# Check pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>                    # Follow logs
kubectl logs <pod-name> --previous            # Previous container logs
kubectl logs -l app=nginx                     # Logs from all pods with label

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- cat /etc/resolv.conf

# Port forwarding for debugging
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
kubectl port-forward deployment/<deployment-name> 8080:80

# Copy files to/from pods
kubectl cp file.txt <pod-name>:/tmp/file.txt
kubectl cp <pod-name>:/tmp/file.txt ./file.txt
```

### Common Debugging Scenarios
```bash
# Check node resources
kubectl top nodes
kubectl describe nodes

# Check pod resource usage
kubectl top pods
kubectl top pods -A

# View events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=<pod-name>

# Check service endpoints
kubectl get endpoints
kubectl describe endpoints <service-name>

# DNS debugging
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Network debugging
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- /bin/bash
```

## Security and RBAC

### Service Account
```yaml
# service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webapp-sa
  namespace: default
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  template:
    spec:
      serviceAccountName: webapp-sa
      containers:
      - name: webapp
        image: nginx
```

### Role and RoleBinding
```yaml
# rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: development
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
- kind: ServiceAccount
  name: webapp-sa
  namespace: development
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Network Policies
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: development
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: development
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Helm Package Manager

### Install Helm
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Search charts
helm search repo nginx
helm search hub wordpress
```

### Helm Commands
```bash
# Install chart
helm install myrelease bitnami/nginx
helm install myapp ./mychart

# List releases
helm list
helm list -A

# Upgrade release
helm upgrade myrelease bitnami/nginx --set replicaCount=3

# Rollback release
helm rollback myrelease 1

# Uninstall release
helm uninstall myrelease

# Create chart
helm create mychart

# Template rendering
helm template myapp ./mychart
helm template myapp ./mychart --values values-prod.yaml
```

### Basic Helm Chart Structure
```
mychart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── _helpers.tpl
└── charts/
```

## Useful kubectl Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:
```bash
# kubectl aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias kex='kubectl exec -it'

# Specific resource aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'

# Watch aliases
alias kgpw='kubectl get pods -w'
alias kgsw='kubectl get services -w'

# Context aliases
alias kcc='kubectl config current-context'
alias kcs='kubectl config use-context'
```

## Advanced Kubernetes Patterns

### StatefulSet
```yaml
# statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: "mongodb"
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.4
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### DaemonSet
```yaml
# daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### Job and CronJob
```yaml
# job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-migration
spec:
  template:
    spec:
      containers:
      - name: migration
        image: migration:latest
        command: ["python", "migrate.py"]
      restartPolicy: Never
  backoffLimit: 4
---
# cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup:latest
            command: ["sh", "-c", "backup.sh"]
          restartPolicy: OnFailure
```

## Best Practices

### Resource Management
1. **Always set resource requests and limits**
2. **Use namespaces to organize resources**
3. **Implement resource quotas**
4. **Use labels and selectors effectively**

### Security
1. **Use RBAC for access control**
2. **Implement network policies**
3. **Use secrets for sensitive data**
4. **Run containers as non-root users**
5. **Regularly update images**

### Deployment
1. **Use health checks (liveness/readiness probes)**
2. **Implement rolling updates**
3. **Use GitOps for deployment**
4. **Monitor and log everything**
5. **Test in staging environment**

### Configuration
```yaml
# deployment-with-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
```

This comprehensive Kubernetes guide covers essential concepts, commands, and best practices for container orchestration. Practice these commands and patterns to become proficient with Kubernetes!