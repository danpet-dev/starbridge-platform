# 🛠️ Troubleshooting Guide

## GitHub Actions Issues

### Security Scanning Configuration

**Current Setup**: This project uses Trivy for security scanning with **table output format** instead of SARIF uploads to avoid dependency on GitHub Advanced Security (paid feature).

**What's included**:
- ✅ Trivy vulnerability scanning
- ✅ Container image security checks  
- ✅ Filesystem vulnerability detection
- ✅ Results displayed in CI job output

**What's NOT included** (requires GitHub Advanced Security):
- ❌ Security tab integration
- ❌ SARIF result uploads
- ❌ Code scanning alerts
- ❌ Dependency vulnerability alerts

### Upgrading to GitHub Advanced Security

If you want full security integration:

1. **Purchase GitHub Advanced Security** for your organization
2. **Enable it** in repository settings → Security & analysis
3. **Update CI workflow** to use SARIF format:
   ```yaml
   - name: 🔍 Run Trivy Scanner
     uses: aquasecurity/trivy-action@master
     with:
       format: 'sarif'
       output: 'trivy-results.sarif'
   
   - name: Upload Results
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: 'trivy-results.sarif'
   ```

## CI/CD Pipeline Issues

### Kubernetes Validation Errors

#### Issue: "Invalid YAML syntax"
```bash
# Check YAML syntax
yamllint deployment-file.yaml

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f deployment-file.yaml
```

#### Issue: "Resource not found"
```bash
# Check if namespace exists
kubectl get namespace starbridge-platform

# Create namespace if missing
kubectl create namespace starbridge-platform
```

### Container Build Issues

#### Issue: "Failed to build image"
```bash
# Check Dockerfile syntax
docker build --dry-run .

# Build with verbose output
docker build --no-cache --progress=plain .
```

## Security Best Practices

### Trivy Scanning

**Current Trivy Score**: 🏆 **10/10** (Zero HIGH/CRITICAL vulnerabilities)

**Configuration**:
- Scans filesystem for vulnerabilities
- Ignores unfixed issues (`.trivyignore`)
- Focuses on CRITICAL, HIGH, MEDIUM severity
- Excludes test files and documentation

**Maintaining High Scores**:
1. Keep base images updated
2. Pin specific image versions
3. Use security contexts in Kubernetes
4. Regular dependency updates

### HashiCorp Vault Integration

**Setup**:
```bash
# Initialize Vault (development mode)
cd vault_nexus_deployment
kubectl apply -f vault-nexus-deployment.yaml

# Setup policies
./vault-setup-policies.sh
```

**Migration from Kubernetes Secrets**:
- Follow `vault_nexus_deployment/MIGRATION.md`
- Use provided migration scripts
- Test thoroughly before production deployment

## Performance Optimization

### Resource Management

**Monitoring**:
```bash
# Check resource usage
kubectl top pods -n starbridge-platform
kubectl describe node

# Scale deployments
kubectl scale deployment app-name --replicas=3
```

**Optimization Tips**:
- Set appropriate resource requests/limits
- Use horizontal pod autoscaling
- Monitor memory and CPU usage
- Optimize database queries

## Networking Issues

### Service Discovery

```bash
# Check service endpoints
kubectl get endpoints -n starbridge-platform

# Test connectivity
kubectl run test-pod --image=busybox -it --rm -- /bin/sh
nslookup service-name.starbridge-platform.svc.cluster.local
```

### Ingress Configuration

```bash
# Check ingress status
kubectl get ingress -n starbridge-platform

# Verify TLS certificates
kubectl describe ingress app-name
```

## Backup & Recovery

### Database Backups

```bash
# PostgreSQL backup
kubectl exec -it postgres-pod -- pg_dump -U admin database_name > backup.sql

# Restore database
kubectl exec -i postgres-pod -- psql -U admin database_name < backup.sql
```

### Configuration Backups

```bash
# Export all configurations
kubectl get all,configmap,secret -n starbridge-platform -o yaml > backup.yaml

# Restore configurations
kubectl apply -f backup.yaml
```

## Support & Community

### Getting Help

1. **Check Logs**:
   ```bash
   kubectl logs -f deployment/app-name -n starbridge-platform
   ```

2. **Review Documentation**:
   - Component-specific README files
   - `CONTRIBUTING.md` for development guidelines
   - `SECURITY.md` for security policies

3. **Community Resources**:
   - GitHub Issues for bug reports
   - Discussions for questions
   - Security advisories for vulnerabilities

### Contributing

Before submitting issues:
- ✅ Check existing issues
- ✅ Review troubleshooting guide
- ✅ Include error messages and logs
- ✅ Specify environment details (K8s version, etc.)

---

**Last Updated**: October 2025  
**Trivy Security Score**: 🏆 10/10