#!/bin/bash
# =============================================================================
# 🔑 Vault Nexus Secret Setup
# =============================================================================
# Migrates existing secrets to Vault and sets up initial secret structure

set -e

VAULT_ADDR="http://localhost:8200"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔑 Setting up Vault secrets..."

# Port forward for configuration
kubectl port-forward -n security-nexus service/vault-nexus 8200:8200 &
PF_PID=$!
sleep 5

export VAULT_ADDR="http://localhost:8200"

echo "📦 Migrating PostgreSQL secrets..."
# PostgreSQL secrets
vault kv put database/postgres/dev \
    username="starbridge_dev" \
    password="starbridge-dev-2025" \
    database="starbridge_dev" \
    host="postgres.data-vault-dev.svc.cluster.local" \
    port="5432"

vault kv put database/postgres/prod \
    username="starbridge_prod" \
    password="starbridge-prod-2025" \
    database="starbridge_prod" \
    host="postgres.data-vault-prod.svc.cluster.local" \
    port="5432"

echo "🤖 Setting up Workflow Nexus (n8n) secrets..."
# n8n secrets
vault kv put workflow/n8n/dev \
    db_host="postgres.data-vault-dev.svc.cluster.local" \
    db_user="starbridge_dev" \
    db_password="starbridge-dev-2025" \
    db_name="starbridge_dev" \
    encryption_key="$(openssl rand -base64 32)" \
    webhook_url="http://workflow-nexus.starbridge-dev.svc.cluster.local:5678"

vault kv put workflow/n8n/prod \
    db_host="postgres.data-vault-prod.svc.cluster.local" \
    db_user="starbridge_prod" \
    db_password="starbridge-prod-2025" \
    db_name="starbridge_prod" \
    encryption_key="$(openssl rand -base64 32)" \
    webhook_url="http://workflow-nexus.starbridge-prod.svc.cluster.local:5678"

echo "🛡️ Setting up Guardian Nexus (Keycloak) secrets..."
# Keycloak secrets
vault kv put security/keycloak/database \
    username="guardian_nexus" \
    password="guardian-nexus-2025" \
    database="guardian_nexus" \
    host="guardian-nexus-postgres-service.security-nexus.svc.cluster.local" \
    port="5432"

vault kv put security/keycloak/admin \
    username="admin" \
    password="starbridge-admin-2025"

vault kv put security/keycloak/oidc \
    client_id="starbridge-platform" \
    client_secret="$(openssl rand -base64 32)" \
    issuer_url="http://guardian-nexus-keycloak.security-nexus.svc.cluster.local:8080/realms/starbridge"

echo "🧠 Setting up Neural Nexus (Ollama) secrets..."
# Ollama secrets
vault kv put neural/ollama/config \
    host="0.0.0.0" \
    port="11434" \
    models_path="/root/.ollama/models" \
    keep_alive="5m" \
    max_loaded_models="1"

vault kv put neural/ollama/api-keys \
    huggingface_token="hf_your_token_here" \
    openai_api_key="sk-your-openai-key-here" \
    anthropic_api_key="your-anthropic-key-here"

echo "🌉 Setting up File Bridge SSH keys..."
# File Bridge SSH keys (these would be generated or imported)
vault kv put starbridge/ssh-keys/input \
    private_key="$(cat <<'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
# This would be the actual private key
# Generated specifically for the input bridge
-----END OPENSSH PRIVATE KEY-----
EOF
)" \
    public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... bridge-user@input"

vault kv put starbridge/ssh-keys/test \
    private_key="$(cat <<'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
# This would be the actual private key
# Generated specifically for the test bridge
-----END OPENSSH PRIVATE KEY-----
EOF
)" \
    public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... bridge-user@test"

echo "📡 Setting up Starbridge Beacon secrets..."
# Web interface secrets
vault kv put starbridge/web/config \
    session_secret="$(openssl rand -base64 32)" \
    jwt_secret="$(openssl rand -base64 32)" \
    api_key="$(openssl rand -base64 24)"

echo "🔐 Setting up TLS certificates..."
# PKI configuration for internal TLS
vault write pki/roles/starbridge-platform \
    allowed_domains="starbridge.local,starbridge.platform,*.starbridge.local,*.starbridge.platform" \
    allow_subdomains=true \
    max_ttl="720h" \
    generate_lease=true

vault write pki/config/urls \
    issuing_certificates="http://vault-nexus.security-nexus.svc.cluster.local:8200/v1/pki/ca" \
    crl_distribution_points="http://vault-nexus.security-nexus.svc.cluster.local:8200/v1/pki/crl"

echo "🔒 Setting up database dynamic secrets..."
# Configure database secrets engine for PostgreSQL
vault write database/config/postgres-dev \
    plugin_name=postgresql-database-plugin \
    connection_url="postgresql://{{username}}:{{password}}@postgres.data-vault-dev.svc.cluster.local:5432/starbridge_dev?sslmode=disable" \
    allowed_roles="postgres-role" \
    username="starbridge_dev" \
    password="starbridge-dev-2025"

vault write database/roles/postgres-role \
    db_name=postgres-dev \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

echo "✅ Vault secrets setup completed successfully!"
echo ""
echo "📋 Secret paths created:"
echo "- database/postgres/* (Database credentials)"
echo "- workflow/n8n/* (n8n configuration)"
echo "- security/keycloak/* (Keycloak settings)"
echo "- neural/ollama/* (AI model configuration)"
echo "- starbridge/ssh-keys/* (SSH keys for bridges)"
echo "- starbridge/web/* (Web interface secrets)"
echo ""

# Cleanup
kill $PF_PID 2>/dev/null || true

echo "🖖 Secrets are securely stored in Vault!"