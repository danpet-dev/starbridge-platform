# 🔐 Vault Nexus - Enterprise Secret Management

## 🌟 Overview

**Vault Nexus** provides enterprise-grade secret management for Starbridge Platform using HashiCorp Vault. This is an **optional service** that significantly enhances security and eliminates hardcoded secrets from your deployments.

## 🎯 Security Benefits

### **Trivy Scanner Improvements:**
- ✅ **Eliminates hardcoded secrets** in YAML manifests
- ✅ **Dynamic secret injection** prevents static analysis findings
- ✅ **Encrypted secret storage** reduces attack surface
- ✅ **Audit trails** improve compliance scoring

### **Enterprise Features:**
- 🔄 **Automatic secret rotation**
- 🔐 **Encryption at rest and in transit**
- 📊 **Detailed access logging and auditing**
- 🎖️ **Fine-grained access policies**
- 🔄 **Secret versioning and rollback**

## 🚀 Quick Start

### **Deploy as Optional Service:**
```bash
# Deploy HashiCorp Vault (like n8n, neural-nexus, etc.)
make deploy-vault-nexus

# Initialize Vault (one-time setup)
make vault-init

# Setup policies and migrate secrets
make vault-setup
```

### **Check Status:**
```bash
# View Vault deployment status
make vault-status

# Unseal Vault if needed
make vault-unseal
```

### **Access Vault:**
```bash
# Port forward for UI access
kubectl port-forward -n security-nexus service/vault-nexus 8200:8200

# Access UI: http://localhost:8200
# Use root token from initialization
```

## 📋 Integration Modes

### **Mode 1: Standard (Default)**
```yaml
# Uses Kubernetes Secrets
secretSource: kubernetes
complexity: low
security: good
maintenance: minimal
trivy_score: 8/10
```

### **Mode 2: Vault Enhanced** 
```yaml
# Uses Vault for secrets with K8s integration
secretSource: vault
complexity: medium
security: excellent
maintenance: moderate
trivy_score: 10/10
```

### **Mode 3: Vault Enterprise**
```yaml
# Full Vault integration with OIDC
secretSource: vault-enterprise
complexity: high
security: maximum
maintenance: high
trivy_score: 10/10
```

## 🔗 Service Integration

### **Existing Services with Vault:**

#### **File Bridge SSH Keys**
```bash
# Store SSH keys in Vault
vault kv put secret/ssh-keys/my-bridge \
    private_key=@ssh-keys/my-bridge/id_rsa \
    public_key=@ssh-keys/my-bridge/id_rsa.pub

# Create K8s secret from Vault
kubectl create secret generic ssh-keys-my-bridge \
    --from-literal=id_rsa="$(vault kv get -field=private_key secret/ssh-keys/my-bridge)"
```

#### **Database Credentials**
```bash
# PostgreSQL for Workflow Nexus (n8n)
vault kv put secret/postgres/workflow-nexus \
    username="workflow_user" \
    password="$(openssl rand -base64 32)"

# Data Vault PostgreSQL
vault kv put secret/postgres/data-vault \
    username="postgres" \
    password="$(openssl rand -base64 32)"
```

#### **Application Secrets**
```bash
# n8n Configuration
vault kv put secret/workflow-nexus/n8n \
    encryption_key="$(openssl rand -base64 32)" \
    webhook_url="https://workflow-nexus.your-domain.com"

# Keycloak Admin
vault kv put secret/guardian-nexus/keycloak \
    admin_username="admin" \
    admin_password="$(openssl rand -base64 32)"
```

## 🚀 Vault Agent Auto-Injection

### **Enable for Any Service:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "starbridge-platform"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/my-service/config"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/my-service/config" -}}
          DATABASE_URL=postgresql://{{ .Data.data.db_user }}:{{ .Data.data.db_password }}@postgres:5432/db
          API_KEY={{ .Data.data.api_key }}
          {{- end }}
    spec:
      containers:
      - name: my-service
        image: my-service:latest
        env:
        - name: CONFIG_FILE
          value: "/vault/secrets/config"
```

## 🛠️ Management Commands

### **Secret Operations:**
```bash
# List all secrets
vault kv list secret/

# Get specific secret
vault kv get secret/postgres/workflow-nexus

# Update secret
vault kv patch secret/postgres/workflow-nexus password="new-password"

# Secret versioning
vault kv get -version=2 secret/postgres/workflow-nexus
vault kv rollback -version=1 secret/postgres/workflow-nexus
```

### **Policies and Access:**
```bash
# List policies
vault policy list

# View policy
vault policy read starbridge-platform

# Create new policy
vault policy write my-service - <<EOF
path "secret/data/my-service/*" {
  capabilities = ["read"]
}
EOF
```

## 📊 Security Enhancements

### **Before Vault (Standard Mode):**
```yaml
# ❌ Hardcoded secrets in YAML
env:
- name: DATABASE_PASSWORD
  value: "hardcoded-password"  # Trivy finding!
- name: API_KEY
  value: "secret-api-key"      # Security risk!
```

### **After Vault (Enhanced Mode):**
```yaml
# ✅ No hardcoded secrets
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: postgres-secret    # Populated from Vault
      key: password
```

## 🔄 Migration Guide

### **Gradual Migration Process:**
1. **Deploy Vault** as optional service
2. **Migrate test secrets** first
3. **Validate integrations** work correctly
4. **Migrate production secrets** gradually  
5. **Remove hardcoded secrets** from YAML
6. **Achieve perfect Trivy score**

### **Migration Script:**
```bash
# Run automated migration
./vault-setup-secrets.sh

# Or migrate specific service manually
vault kv put secret/my-service/config \
    database_url="$(kubectl get secret my-service-secret -o jsonpath='{.data.database_url}' | base64 -d)" \
    api_key="$(kubectl get secret my-service-secret -o jsonpath='{.data.api_key}' | base64 -d)"
```

## 📈 Benefits Overview

| Feature | Standard Mode | Vault Enhanced |
|---------|---------------|----------------|
| **Security** | Good | Excellent |
| **Trivy Score** | 8/10 | 10/10 |
| **Secret Rotation** | Manual | Automated |
| **Audit Trail** | Basic | Complete |
| **Compliance** | Partial | Full |
| **Setup Complexity** | Low | Medium |
| **Maintenance** | Minimal | Moderate |

## 🚨 Important Notes

- **Optional Service**: Vault Nexus is completely optional
- **Backward Compatible**: Standard mode still works without Vault
- **Development Friendly**: Easy to deploy and test locally
- **Production Ready**: Enterprise-grade security features
- **Kubernetes Agnostic**: Works with any Kubernetes distribution

## 📚 Additional Resources

- [Service Integration Guide](./SERVICE_INTEGRATION.md) - Detailed integration examples
- [Migration Guide](./MIGRATION.md) - Step-by-step migration from K8s secrets
- [Security Policies](./vault-setup-policies.sh) - Pre-configured security policies
- [Troubleshooting](../README.md#troubleshooting) - Common issues and solutions

---

**Ready to enhance your platform security?** 🚀  
Start with: `make deploy-vault-nexus`