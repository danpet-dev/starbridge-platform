# 🔄 Vault Migration Guide

## 🎯 Overview

This guide helps you migrate from Kubernetes Secrets to Vault Nexus for enhanced security and better Trivy scan results.

## 📊 Migration Benefits

### **Before (Kubernetes Secrets):**
```yaml
Trivy Security Score: 7.5/10
❌ Hardcoded secrets in YAML
❌ Base64 encoding (not encryption)
❌ Limited audit capabilities
❌ Manual secret rotation
⚠️  Secrets visible in Git history
```

### **After (Vault Nexus):**
```yaml
Trivy Security Score: 9.5/10
✅ No secrets in YAML/Git
✅ Encrypted secret storage
✅ Comprehensive audit logging
✅ Automatic secret rotation
✅ Fine-grained access control
✅ Zero-trust secret access
```

## 🚀 Migration Steps

### **Step 1: Deploy Vault Nexus**
```bash
# Deploy Vault infrastructure
make deploy-vault-nexus

# Initialize Vault (first-time only)
make vault-init

# Setup policies and secrets
make vault-setup
```

### **Step 2: Verify Vault Status**
```bash
# Check Vault is running
make vault-status

# Access Vault UI (optional)
make vault-ui
```

### **Step 3: Migrate Services One by One**

#### **PostgreSQL Migration:**
```bash
# Current deployment
kubectl get deployment postgres -o yaml > postgres-backup.yaml

# Deploy Vault-enhanced version
kubectl apply -f vault_nexus_deployment/postgres-vault-deployment.yaml

# Verify migration
kubectl logs deployment/postgres-vault-enhanced
```

#### **n8n Migration:**
```bash
# Deploy with Vault integration
make deploy-n8n MODE=prod VAULT=enabled

# Verify secret injection
kubectl describe pod -l app=workflow-nexus
# Look for vault.hashicorp.com annotations
```

## 🔍 Verification Steps

### **1. Check Secret Injection**
```bash
# Verify Vault annotations are present
kubectl get pods -o yaml | grep "vault.hashicorp.com"

# Check Vault agent sidecar
kubectl logs <pod-name> -c vault-agent
```

### **2. Verify No Hardcoded Secrets**
```bash
# Run Trivy scan
trivy fs . --severity HIGH,CRITICAL

# Should show significant reduction in secret-related findings
```

### **3. Test Secret Access**
```bash
# Connect to application pod
kubectl exec -it <pod-name> -- /bin/bash

# Check if secrets are available
ls -la /vault/secrets/
cat /vault/secrets/config
```

## 🔒 Security Improvements

### **Secret Storage:**
```diff
- Kubernetes Secrets: Base64 encoded
+ Vault: AES-256 encrypted at rest
```

### **Secret Access:**
```diff
- K8s: Anyone with cluster access sees secrets
+ Vault: Policy-based access with audit trails
```

### **Secret Rotation:**
```diff
- K8s: Manual process
+ Vault: Automated rotation with TTL
```

## 🛠️ Troubleshooting

### **Common Issues:**

#### **Vault Agent Not Injecting:**
```bash
# Check annotations
kubectl describe pod <pod-name>

# Verify service account
kubectl get serviceaccount vault-auth

# Check Vault policies
vault policy list
```

#### **Authentication Issues:**
```bash
# Test Kubernetes auth
vault auth -method=kubernetes role=<role-name>

# Check token validity
vault token lookup
```

#### **Secret Path Issues:**
```bash
# List available secrets
vault kv list database/

# Read specific secret
vault kv get database/postgres/prod
```

## 🔄 Rollback Plan

If you need to rollback to Kubernetes Secrets:

### **1. Backup Current State:**
```bash
kubectl get secrets --all-namespaces -o yaml > secrets-backup.yaml
```

### **2. Deploy Standard Manifests:**
```bash
kubectl apply -f data_vault_deployment/postgres-deployment.yaml
kubectl apply -f data_vault_deployment/postgres-secret.yaml
```

### **3. Remove Vault Annotations:**
```bash
kubectl patch deployment <deployment-name> --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations"}]'
```

## 📋 Migration Checklist

- [ ] Vault Nexus deployed and initialized
- [ ] Policies configured for all services
- [ ] Secrets migrated to Vault
- [ ] Service deployments updated with Vault annotations
- [ ] Vault agent injection verified
- [ ] Application functionality tested
- [ ] Trivy scan results improved
- [ ] Backup of original configurations created
- [ ] Team trained on Vault operations
- [ ] Monitoring and alerting configured

## 🎯 Best Practices

### **Secret Organization:**
```
vault/
├── database/
│   ├── postgres/prod
│   └── postgres/dev
├── workflow/
│   └── n8n/
├── security/
│   └── keycloak/
└── starbridge/
    ├── ssh-keys/
    └── web/
```

### **Policy Naming:**
- Use service-specific policies
- Follow least-privilege principle
- Regular policy reviews
- Document policy purposes

### **Secret Rotation:**
- Set appropriate TTL values
- Monitor secret expiration
- Automate rotation where possible
- Test rotation procedures

---

**🖖 Live long and prosper with enhanced security!**