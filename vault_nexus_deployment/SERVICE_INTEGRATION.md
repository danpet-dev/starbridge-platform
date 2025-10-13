# 🔐 Vault Nexus Service Integration Guide

## 🌟 Overview

**Vault Nexus** is an **optional service** in the Starbridge Platform that provides enterprise-grade secret management using HashiCorp Vault. When deployed, it centralizes all secrets for the entire platform.

## 🚀 Deployment

### **Deploy Vault Service**
```bash
# Deploy as optional service (like n8n, neural-nexus, etc.)
make deploy-vault-nexus
```

### **Initialize Vault (One-time)**
```bash
cd vault_nexus_deployment
./vault-init.sh
```

### **Setup Policies and Secrets**
```bash
./vault-setup-policies.sh
./vault-setup-secrets.sh
```

## 🔗 Service Integration

### **File Bridge SSH Keys**
```bash
# Generate SSH keys as usual
cd file_bridge_deployment
./ssh-key-manager.sh generate my-bridge

# Store in Vault instead of Kubernetes secrets
vault kv put secret/ssh-keys/my-bridge \
    private_key=@ssh-keys/my-bridge/id_rsa \
    public_key=@ssh-keys/my-bridge/id_rsa.pub \
    ssh_config=@ssh-keys/my-bridge/ssh_config

# Create Kubernetes secret from Vault
kubectl create secret generic ssh-keys-my-bridge \
    --from-literal=id_rsa="$(vault kv get -field=private_key secret/ssh-keys/my-bridge)"
```

### **Database Credentials**
```bash
# PostgreSQL for Workflow Nexus
vault kv put secret/postgres/workflow-nexus \
    username="workflow_user" \
    password="$(openssl rand -base64 32)" \
    database="workflow_nexus_db"

# PostgreSQL for Data Vault
vault kv put secret/postgres/data-vault \
    username="postgres" \
    password="$(openssl rand -base64 32)"
```

### **Application Secrets**
```bash
# n8n Encryption Key
vault kv put secret/workflow-nexus/n8n \
    encryption_key="$(openssl rand -base64 32)" \
    db_postgresdb_password="$(vault kv get -field=password secret/postgres/workflow-nexus)"

# Keycloak Admin Credentials
vault kv put secret/guardian-nexus/keycloak \
    admin_username="admin" \
    admin_password="$(openssl rand -base64 32)"

# JWT Secrets
vault kv put secret/platform/jwt \
    secret="$(openssl rand -base64 64)" \
    issuer="starbridge-platform"
```

## 🔧 Vault Agent Integration

### **Automatic Secret Injection**
```yaml
# Add to any deployment for automatic secret injection
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
          DATABASE_URL=postgresql://{{ .Data.data.db_user }}:{{ .Data.data.db_password }}@postgres:5432/{{ .Data.data.db_name }}
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

## 📊 Monitoring & Management

### **Vault UI Access**
```bash
# Port forward to access UI
kubectl port-forward -n security-nexus service/vault-nexus 8200:8200

# Access UI at: http://localhost:8200
```

### **CLI Configuration**
```bash
# Set Vault address
export VAULT_ADDR="http://vault-nexus.security-nexus.svc.cluster.local:8200"

# Authenticate (using root token from initialization)
export VAULT_TOKEN="hvs.xxxxx"

# Or use Kubernetes auth
vault auth -method=kubernetes role=starbridge-platform jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```

### **Secret Management**
```bash
# List all secrets
vault kv list secret/

# Get specific secret
vault kv get secret/postgres/workflow-nexus

# Update secret
vault kv patch secret/postgres/workflow-nexus password="new-password"

# Delete secret
vault kv delete secret/old-service/config
```

## 🔄 Secret Rotation

### **Manual Rotation**
```bash
# Rotate database password
NEW_PASSWORD=$(openssl rand -base64 32)
vault kv patch secret/postgres/workflow-nexus password="$NEW_PASSWORD"

# Update database user
kubectl exec -it postgres-pod -- psql -c "ALTER USER workflow_user PASSWORD '$NEW_PASSWORD';"

# Restart services to pick up new password
kubectl rollout restart deployment/workflow-nexus-n8n
```

### **Automated Rotation (Future)**
```bash
# Enable database secrets engine for automatic rotation
vault secrets enable database
vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/postgres" \
    allowed_roles="workflow-nexus"
```

## 🛡️ Security Policies

### **Service-Specific Access**
```hcl
# File Bridge can only access SSH keys
path "secret/data/ssh-keys/*" {
  capabilities = ["read"]
}

# Workflow Nexus can access its secrets
path "secret/data/workflow-nexus/*" {
  capabilities = ["read", "update"]
}

# Database admin can rotate credentials
path "secret/data/postgres/*" {
  capabilities = ["read", "update", "delete"]
}
```

## 📈 Benefits

### **Security Improvements**
- 🚫 **No hardcoded secrets** in YAML manifests
- 🔐 **Encryption at rest** and in transit
- 📊 **Complete audit trail** of secret access
- 🔄 **Automatic secret rotation** capabilities
- 🎯 **Fine-grained access control**

### **Operational Benefits**
- 🏠 **Centralized secret management**
- 🚀 **Easy secret injection** into services
- 🔧 **Developer-friendly CLI**
- 📋 **Backup and recovery** of secrets
- 🔄 **Secret versioning** and rollback

### **Compliance**
- ✅ **Perfect Trivy scores** (no hardcoded secrets)
- ✅ **SOC 2** compliance ready
- ✅ **GDPR** compliant secret handling
- ✅ **ISO 27001** audit requirements

## 🔄 Migration from Kubernetes Secrets

### **Automated Migration**
```bash
# Use provided migration script
./vault-setup-secrets.sh

# Or migrate manually:
kubectl get secret my-secret -o yaml | \
  yq eval '.data | to_entries | .[] | .key + "=" + (.value | @base64d)' | \
  while IFS='=' read key value; do
    vault kv put secret/my-service/$key value="$value"
  done
```

### **Gradual Migration**
1. **Deploy Vault** alongside existing secrets
2. **Migrate non-critical** secrets first  
3. **Test integrations** thoroughly
4. **Migrate production** secrets
5. **Remove old** Kubernetes secrets

---

**Ready to enhance your platform security?** 🚀  
Start with: `make deploy-vault-nexus`