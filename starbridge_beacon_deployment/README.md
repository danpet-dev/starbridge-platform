# 📡 Starbridge Beacon - Fleet Web Command

## 🌟 Overview

Production-ready Kubernetes deployment for **Starbridge Beacon** - the web interface and fleet monitoring platform for Admiral E.C. Copilot's Genesis Architecture v2.0.0. Provides enterprise-grade hosting with nginx, persistent storage, and scalable architecture.

## 🚀 Fleet Interface Features

- **Enterprise nginx server** with optimized configuration
- **Persistent storage** for web content via PVC
- **High availability** with 2-replica deployment
- **Health monitoring** with liveness and readiness probes
- **Security headers** and best practices
- **Content compression** for optimal performance
- **Ingress support** for external access

## 📁 Components

```
webserver_deployment/
├── webserver-pvc.yaml          # Persistent storage for web content
├── webserver-configmap.yaml    # nginx configuration
├── webserver-deployment.yaml   # Main webserver deployment
├── webserver-service.yaml      # ClusterIP service
├── webserver-ingress.yaml      # Ingress for external access
├── sync-web-content.sh         # Content synchronization script
└── README.md                   # This file
```

## 🎯 Quick Deployment

### Deploy webserver infrastructure:
```bash
# Deploy all webserver components
make deploy-webserver

# Sync web content to PVC
make sync-web-content

# Port-forward for access
make port-forward-webserver
```

### Manual deployment:
```bash
# Create namespace
kubectl create namespace starbridge-platform

# Deploy components
kubectl apply -f webserver_deployment/

# Sync content
./webserver_deployment/sync-web-content.sh
```

## 🌐 Access Methods

### 1. Port-Forward (Development)
```bash
kubectl port-forward -n starbridge-platform service/starbridge-webserver-service 8080:80
# Access: http://localhost:8080
```

### 2. Ingress (Production)
```bash
# Add to /etc/hosts:
echo "127.0.0.1 starbridge.local" | sudo tee -a /etc/hosts

# Access: http://starbridge.local
```

### 3. NodePort (Alternative)
```bash
# Modify service to NodePort and access via node IP
kubectl patch service starbridge-webserver-service -n starbridge-platform -p '{"spec":{"type":"NodePort"}}'
```

## 🛠️ Content Management

### Sync Web Content
The `sync-web-content.sh` script automatically synchronizes content from the `web/` directory to the PVC:

```bash
# Manual sync
./webserver_deployment/sync-web-content.sh

# Via Makefile
make sync-web-content
```

### Update Web Content
1. Modify files in the `web/` directory
2. Run sync script to update production content
3. Changes are immediately available

## 📊 Monitoring

### Health Checks
```bash
# Pod status
kubectl get pods -n starbridge-platform -l app=starbridge-webserver

# Service status
kubectl get service starbridge-webserver-service -n starbridge-platform

# Logs
kubectl logs -n starbridge-platform -l app=starbridge-webserver
```

### nginx Status
```bash
# Access health endpoint
curl http://localhost:8080/health
```

## 🔧 Configuration

### nginx Configuration
Modify `webserver-configmap.yaml` to adjust nginx settings:
- Security headers
- Compression settings
- Cache policies
- Error pages

### Resource Limits
Adjust in `webserver-deployment.yaml`:
- CPU/Memory requests and limits
- Replica count
- Storage size

## 🗂️ File Structure

### Web Content Location (in PVC)
```
/usr/share/nginx/html/
├── index.html                  # Main platform page
├── mission-logs.html           # Mission log interface
├── README.md                   # Documentation
├── logo-starbridge-platform.jpeg
└── 404.html                    # Error page
```

## 🚨 Troubleshooting

### Common Issues

**Pod not starting:**
```bash
kubectl describe pod -n starbridge-platform -l app=starbridge-webserver
```

**PVC not mounting:**
```bash
kubectl describe pvc starbridge-webserver-pvc -n starbridge-platform
```

**Content not syncing:**
```bash
# Check sync pod logs
kubectl logs starbridge-sync-pod -n starbridge-platform
```

**Service not accessible:**
```bash
kubectl get endpoints starbridge-webserver-service -n starbridge-platform
```

## 🎖️ Production Considerations

### Security
- Security headers enabled
- No directory listing
- Error page customization
- Content-Security-Policy headers

### Performance
- Gzip compression enabled
- Static file caching
- Resource limits configured
- Multiple replicas for availability

### Scalability
- Horizontal pod autoscaling ready
- Persistent storage for content
- Load balancer ready
- Ingress controller support

## 🖖 Integration with Starbridge Platform

This webserver deployment integrates seamlessly with the Starbridge Platform:
- Uses same namespace structure
- Follows platform labeling conventions
- Integrates with platform Makefile
- Shares storage classes and configurations