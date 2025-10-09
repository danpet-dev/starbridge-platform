# 🤖 Workflow Nexus - Genesis Architecture v2.0.0

This directory contains dual-mode Kubernetes manifests for deploying **Workflow Nexus** (n8n) workflow automation with PostgreSQL Data Vault backend and Guardian Nexus OIDC security integration.

## Prerequisites

- Rancher Desktop with Kubernetes enabled
- Data Vault (PostgreSQL) deployment
- Guardian Nexus (Keycloak) for production mode OIDC authentication

## Fleet Architecture Components

- **workflow-nexus-dev-config.yaml** - Development mode configuration
- **workflow-nexus-prod-config.yaml** - Production mode with Guardian Nexus OIDC
- **workflow-nexus-dev-secret.yaml** - Development environment secrets
- **workflow-nexus-prod-secret.yaml** - Production environment secrets
- **workflow-nexus-dev-pvc.yaml** - Persistent volume for dev data
- **workflow-nexus-dev-deployment.yaml** - Development deployment
- **workflow-nexus-dev-db-setup.yaml** - Database setup job for development

## Dual-Mode Architecture

1. **Deploy PostgreSQL first:**
   ```bash
   ./deploy-postgres.sh
   ```

2. **Deploy n8n:**
   ```bash
   ./deploy-n8n.sh
   ```

3. **Access n8n:**
   Open http://n8n.127.0.0.1.sslip.io in your browser

## Configuration

### Database Configuration
- **Host:** postgres-service
- **Database:** n8n
- **User:** n8n_user
- **Password:** n8n123 (configurable in `n8n-secret.yaml`)

### Environment Variables
Edit `n8n-configmap.yaml` to customize:
- `WEBHOOK_URL` - External webhook URL
- `GENERIC_TIMEZONE` - Timezone setting
- `N8N_LOG_LEVEL` - Logging level
- Database connection settings

### Security
- Change the default database password in `n8n-secret.yaml`
- Generate a new encryption key:
  ```bash
  openssl rand -hex 32 | base64
  ```

## Troubleshooting

### Check pod status:
```bash
kubectl get pods -l app=n8n
```

### View logs:
```bash
kubectl logs -l app=n8n -f
```

### Check database setup:
```bash
kubectl logs job/n8n-db-setup
```

### Manual database setup (if needed):
```bash
kubectl run postgres-client --rm -it --restart=Never --image=postgres:16 -- psql -h postgres-service -U admin -d postgres
```

## Scaling

n8n is currently configured as a single replica. For production use:
1. Use external PostgreSQL cluster
2. Configure shared storage for workflows
3. Set up proper ingress with SSL/TLS
4. Configure environment-specific secrets

## Cleanup

To remove n8n deployment:
```bash
kubectl delete -f n8n_deployment/ -n your-namespace
```

To remove the database setup job:
```bash
kubectl delete job n8n-db-setup -n your-namespace
```