#!/bin/bash
#
# MIT License
#
# Copyright (c) 2025 Starbridge Platform
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# =============================================================================
# 🛡️ Vault Nexus Policy Setup
# =============================================================================
# Creates policies for different Starbridge Platform components

set -e

VAULT_ADDR="http://localhost:8200"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🛡️  Setting up Vault policies..."

# Port forward for configuration
kubectl port-forward -n security-nexus service/vault-nexus 8200:8200 &
PF_PID=$!
sleep 5

export VAULT_ADDR="http://localhost:8200"

# PostgreSQL Database Policy
echo "📝 Creating PostgreSQL policy..."
vault policy write postgres-policy - <<EOF
# PostgreSQL Database Secrets Policy
path "database/data/postgres/*" {
  capabilities = ["read"]
}

path "database/metadata/postgres/*" {
  capabilities = ["list", "read"]
}

# Dynamic database credentials
path "database/creds/postgres-role" {
  capabilities = ["read"]
}
EOF

# Workflow Nexus (n8n) Policy
echo "📝 Creating Workflow Nexus policy..."
vault policy write workflow-nexus-policy - <<EOF
# Workflow Nexus (n8n) Secrets Policy
path "workflow/data/n8n/*" {
  capabilities = ["read", "create", "update"]
}

path "workflow/metadata/n8n/*" {
  capabilities = ["list", "read"]
}

# Database access for n8n
path "database/data/postgres/n8n" {
  capabilities = ["read"]
}

# SSH keys for file bridges
path "starbridge/data/ssh-keys/*" {
  capabilities = ["read"]
}
EOF

# Guardian Nexus (Keycloak) Policy
echo "📝 Creating Guardian Nexus policy..."
vault policy write guardian-nexus-policy - <<EOF
# Guardian Nexus (Keycloak) Secrets Policy
path "security/data/keycloak/*" {
  capabilities = ["read"]
}

path "security/metadata/keycloak/*" {
  capabilities = ["list", "read"]
}

# Database access for Keycloak
path "database/data/postgres/keycloak" {
  capabilities = ["read"]
}

# OIDC configuration
path "security/data/oidc/*" {
  capabilities = ["read"]
}
EOF

# Neural Nexus (Ollama) Policy
echo "📝 Creating Neural Nexus policy..."
vault policy write neural-nexus-policy - <<EOF
# Neural Nexus (Ollama) Secrets Policy
path "neural/data/ollama/*" {
  capabilities = ["read"]
}

path "neural/metadata/ollama/*" {
  capabilities = ["list", "read"]
}

# API keys for AI models
path "neural/data/api-keys/*" {
  capabilities = ["read"]
}
EOF

# File Bridge Policy
echo "📝 Creating File Bridge policy..."
vault policy write file-bridge-policy - <<EOF
# File Bridge Secrets Policy
path "starbridge/data/ssh-keys/*" {
  capabilities = ["read"]
}

path "starbridge/metadata/ssh-keys/*" {
  capabilities = ["list", "read"]
}

# Bridge configurations
path "starbridge/data/bridges/*" {
  capabilities = ["read"]
}
EOF

# Starbridge Beacon Policy
echo "📝 Creating Starbridge Beacon policy..."
vault policy write starbridge-beacon-policy - <<EOF
# Starbridge Beacon (Web) Secrets Policy
path "starbridge/data/web/*" {
  capabilities = ["read"]
}

# TLS certificates
path "pki/issue/starbridge-platform" {
  capabilities = ["create", "update"]
}
EOF

# Platform Admin Policy
echo "📝 Creating Platform Admin policy..."
vault policy write platform-admin-policy - <<EOF
# Platform Administrator Full Access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

# Setup Kubernetes auth roles
echo "🔗 Setting up Kubernetes auth roles..."

# PostgreSQL role
vault write auth/kubernetes/role/postgres \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=data-vault-prod,data-vault-dev \
    policies=postgres-policy \
    ttl=1h

# Workflow Nexus role
vault write auth/kubernetes/role/workflow-nexus \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=starbridge-prod,starbridge-dev \
    policies=workflow-nexus-policy \
    ttl=1h

# Guardian Nexus role
vault write auth/kubernetes/role/guardian-nexus \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=security-nexus \
    policies=guardian-nexus-policy \
    ttl=1h

# Neural Nexus role
vault write auth/kubernetes/role/neural-nexus \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=neural-nexus \
    policies=neural-nexus-policy \
    ttl=1h

# File Bridge role
vault write auth/kubernetes/role/file-bridge \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=file-bridges \
    policies=file-bridge-policy \
    ttl=1h

# Starbridge Beacon role
vault write auth/kubernetes/role/starbridge-beacon \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=starbridge-platform \
    policies=starbridge-beacon-policy \
    ttl=1h

echo "✅ Vault policies configured successfully!"

# Cleanup
kill $PF_PID 2>/dev/null || true

echo "🖖 Policies are ready for secure secret access!"