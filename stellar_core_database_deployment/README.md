# 🌟 Stellar Core Database - PostgreSQL Fleet Service

## 🎯 Overview

**Stellar Core Database** is the central PostgreSQL database service for the Starbridge Platform fleet. It provides enterprise-grade data persistence for all platform services including Workflow Nexus (n8n), Neural Nexus, and other fleet components.

## 🚀 Quick Start

### **Deploy Database Service:**
```bash
# Developer Mode - Fast & Simple
make deploy-dev         # Includes Stellar Core Database

# Production Mode - Enterprise Security  
make deploy-prod        # Includes Stellar Core Database

# Standalone Database Deployment
make deploy-postgres    # PostgreSQL only
```

### **Access Database:**
```bash
# Port forward to access PostgreSQL
kubectl port-forward -n stellar-core-dev service/postgres-service 5432:5432

# Connect with psql
psql -h localhost -p 5432 -U postgres -d postgres
```

## 🏗️ Architecture

### **Service Components:**
- **🐘 PostgreSQL 16.4** - Latest stable enterprise database
- **📦 Persistent Storage** - Cross-namespace data persistence
- **🔐 Security Contexts** - Non-root, read-only filesystem
- **🌐 Network Policies** - Controlled access patterns
- **🔄 Backup Ready** - Volume snapshots and exports

### **Namespace Structure:**
```bash
stellar-core-dev/       # Development database
├── postgres-deployment.yaml
├── postgres-service.yaml
├── postgres-configmap.yaml
├── postgres-secret.yaml
├── postgres-pvc.yaml
└── postgres-network-policy.yaml

stellar-core-prod/      # Production database
├── Same structure with production security
```

## 🔗 Service Integration

### **Workflow Nexus (n8n) Integration:**
```yaml
# n8n connects to Stellar Core Database
env:
- name: DB_TYPE
  value: "postgresdb"
- name: DB_POSTGRESDB_HOST  
  value: "postgres-service.stellar-core-dev.svc.cluster.local"
- name: DB_POSTGRESDB_PORT
  value: "5432"
- name: DB_POSTGRESDB_DATABASE
  value: "n8n"
- name: DB_POSTGRESDB_USER
  valueFrom:
    secretKeyRef:
      name: postgres-secret
      key: username
- name: DB_POSTGRESDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: postgres-secret
      key: password
```

### **Neural Nexus Integration:**
```yaml
# Future: AI model metadata storage
DATABASE_URL: postgresql://user:pass@postgres-service.stellar-core-dev.svc.cluster.local:5432/neural_db
```

### **File Bridge Integration:**
```yaml
# Future: File transfer logs and metadata
AUDIT_DATABASE_URL: postgresql://user:pass@postgres-service.stellar-core-dev.svc.cluster.local:5432/filebridge_db
```

## 🔐 Vault Nexus Integration

### **Database Credentials in Vault:**
```bash
# Store PostgreSQL credentials in Vault
vault kv put secret/stellar-core/postgres \
    username="postgres" \
    password="$(openssl rand -base64 32)" \
    database="postgres"

# Store application-specific credentials
vault kv put secret/stellar-core/workflow-nexus \
    username="n8n_user" \
    password="$(openssl rand -base64 32)" \
    database="n8n"
```

### **Auto-inject Database Credentials:**
```yaml
# Vault Agent injection for services
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/agent-inject-secret-db: "secret/data/stellar-core/workflow-nexus"
    vault.hashicorp.com/agent-inject-template-db: |
      {{- with secret "secret/data/stellar-core/workflow-nexus" -}}
      DB_POSTGRESDB_USER={{ .Data.data.username }}
      DB_POSTGRESDB_PASSWORD={{ .Data.data.password }}
      DB_POSTGRESDB_DATABASE={{ .Data.data.database }}
      {{- end }}
```

## 🛠️ Management Commands

### **Database Operations:**
```bash
# Create database user
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "CREATE USER n8n_user WITH PASSWORD 'secure_password';"

# Create application database
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "CREATE DATABASE n8n OWNER n8n_user;"

# Grant permissions
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;"
```

### **Backup & Restore:**
```bash
# Backup database
kubectl exec -it postgres-pod -n stellar-core-dev -- pg_dump -U postgres n8n > n8n_backup.sql

# Restore database
kubectl exec -i postgres-pod -n stellar-core-dev -- psql -U postgres n8n < n8n_backup.sql

# Volume snapshot (if supported by your cluster)
kubectl create volumesnapshot postgres-snapshot --source-name=postgres-pvc -n stellar-core-dev
```

## 📊 Monitoring & Observability

### **Health Checks:**
```bash
# Check PostgreSQL status
kubectl exec -it postgres-pod -n stellar-core-dev -- pg_isready -U postgres

# View logs
kubectl logs -f deployment/postgres -n stellar-core-dev

# Connection metrics
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

### **Performance Monitoring:**
```bash
# Database size
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('n8n'));"

# Active connections
kubectl exec -it postgres-pod -n stellar-core-dev -- psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"
```

## 🔄 Migration from Data Vault

### **Automatic Migration:**
The system maintains backward compatibility:
```bash
# Old references still work
DEV_DATA_NAMESPACE  := stellar-core-dev      # Remapped
PROD_DATA_NAMESPACE := stellar-core-prod     # Remapped
DATA_VAULT_DIR      := stellar_core_database_deployment  # Remapped
```

### **Service Discovery:**
```bash
# Old service names still resolve
postgres-service.data-vault-dev.svc.cluster.local    # ❌ Old (deprecated)
postgres-service.stellar-core-dev.svc.cluster.local  # ✅ New (recommended)
```

## 🌟 Why "Stellar Core Database"?

### **Star Trek Navigation Computer Analogy:**
- **🌟 Stellar Core** = The heart of the ship's navigation system
- **📊 Central Repository** = Where all critical data is stored
- **🚀 Mission Critical** = Essential for fleet operations
- **🔗 Service Hub** = All systems connect to the core

### **Technical Benefits:**
- ✅ **Clear Identity** - Obviously a database service
- ✅ **No Confusion** - Distinct from Vault Nexus (secrets)
- ✅ **Enterprise Feel** - Professional naming convention
- ✅ **Scalable** - Future multi-database support ready

## 📈 Future Enhancements

### **Planned Features:**
- 🔄 **Automated Backups** - Scheduled database snapshots
- 📊 **Read Replicas** - High availability and performance
- 🔐 **Row-Level Security** - Fine-grained access control
- 📈 **Connection Pooling** - PgBouncer integration
- 🔄 **Blue-Green Deployments** - Zero-downtime updates

### **Multi-Database Support:**
```bash
# Future: Specialized databases per service
stellar-core-analytics/     # Analytics and reporting
stellar-core-logging/       # Centralized logging
stellar-core-metrics/       # Performance metrics
```

---

**Ready to deploy the heart of your fleet?** 🚀  
Start with: `make deploy-postgres`