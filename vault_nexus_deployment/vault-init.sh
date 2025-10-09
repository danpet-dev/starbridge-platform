#!/bin/bash
# =============================================================================
# 🔐 Vault Nexus Initialization Script
# =============================================================================
# Initializes HashiCorp Vault for Starbridge Platform
# Sets up authentication, policies, and secret engines

set -e

VAULT_ADDR="http://vault-nexus.security-nexus.svc.cluster.local:8200"
VAULT_NAMESPACE="security-nexus"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔐 Vault Nexus Initialization Starting..."
echo "🎯 Target: $VAULT_ADDR"

# Wait for Vault to be ready
echo "⏳ Waiting for Vault to be ready..."
kubectl wait --for=condition=ready pod -l app=vault-nexus -n $VAULT_NAMESPACE --timeout=300s

# Port forward for initialization
echo "🌉 Setting up port forward..."
kubectl port-forward -n $VAULT_NAMESPACE service/vault-nexus 8200:8200 &
PF_PID=$!
sleep 5

export VAULT_ADDR="http://localhost:8200"

# Check if Vault is already initialized
if vault status | grep -q "Initialized.*true"; then
    echo "ℹ️  Vault is already initialized"
    echo "🔑 Please provide the unseal key and root token manually"
    kill $PF_PID 2>/dev/null || true
    exit 0
fi

echo "🚀 Initializing Vault..."
INIT_OUTPUT=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

# Extract keys and token
UNSEAL_KEY=$(echo $INIT_OUTPUT | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(echo $INIT_OUTPUT | jq -r '.root_token')

echo "✅ Vault initialized successfully!"
echo ""
echo "🔑 IMPORTANT - Save these credentials securely:"
echo "=================================================="
echo "Unseal Key: $UNSEAL_KEY"
echo "Root Token: $ROOT_TOKEN"
echo "=================================================="
echo ""

# Unseal Vault
echo "🔓 Unsealing Vault..."
vault operator unseal $UNSEAL_KEY

# Authenticate with root token
echo "🔑 Authenticating with root token..."
vault auth $ROOT_TOKEN

# Enable audit logging
echo "📊 Enabling audit logging..."
vault audit enable file file_path=/vault/logs/audit.log

# Enable secret engines
echo "🏗️  Setting up secret engines..."

# KV v2 for application secrets
vault secrets enable -path=starbridge kv-v2
vault secrets enable -path=database kv-v2
vault secrets enable -path=workflow kv-v2
vault secrets enable -path=security kv-v2
vault secrets enable -path=neural kv-v2

# Database secrets engine for dynamic credentials
vault secrets enable database

# PKI for certificate management
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# Enable Kubernetes auth method
echo "🔐 Setting up Kubernetes authentication..."
vault auth enable kubernetes

# Configure Kubernetes auth
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

echo "✅ Vault Nexus initialization completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Save the unseal key and root token securely"
echo "2. Run: make vault-setup-policies"
echo "3. Run: make vault-setup-secrets"
echo ""

# Cleanup
kill $PF_PID 2>/dev/null || true

echo "🖖 Live long and prosper!"