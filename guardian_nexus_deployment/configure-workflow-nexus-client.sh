#!/bin/bash

# =============================================================================
# 🛡️ Guardian Nexus - Keycloak Client Configuration Script
# =============================================================================
# Configures Workflow Nexus client in Keycloak for OIDC authentication
#
# Author: Starbridge Platform Development Team
# Version: 1.0.0
# =============================================================================

set -e

# Configuration
KEYCLOAK_NAMESPACE="security-nexus"
KEYCLOAK_SERVICE="guardian-nexus-service"
KEYCLOAK_PORT="8080"
REALM_NAME="starbridge-platform"
CLIENT_ID="workflow-nexus"
CLIENT_SECRET="workflow-nexus-secret-2025"

# Admin credentials
ADMIN_USER="admin"
ADMIN_PASSWORD="starbridge-admin-2025"

ROCKET="🚀"
SHIELD="🛡️"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="💡"

echo "${SHIELD} Guardian Nexus - Keycloak Client Configuration"
echo "═══════════════════════════════════════════════════════════"

# Function to wait for Keycloak
wait_for_keycloak() {
    echo "${INFO} Waiting for Keycloak to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
           curl -s -f http://localhost:8080/health/ready > /dev/null 2>&1; then
            echo "${CHECK} Keycloak is ready!"
            return 0
        fi
        
        echo "⏳ Attempt $attempt/$max_attempts - waiting..."
        sleep 10
        ((attempt++))
    done
    
    echo "${ERROR} Keycloak failed to become ready within timeout"
    return 1
}

# Function to get admin token
get_admin_token() {
    echo "${INFO} Obtaining admin access token..."
    
    local token_response
    token_response=$(kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X POST \
        "http://localhost:8080/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$ADMIN_USER" \
        -d "password=$ADMIN_PASSWORD" \
        -d "grant_type=password" \
        -d "client_id=admin-cli")
    
    if [ $? -ne 0 ]; then
        echo "${ERROR} Failed to obtain admin token"
        return 1
    fi
    
    # Extract access token (simplified - would use jq in production)
    local token=$(echo "$token_response" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$token" ]; then
        echo "${ERROR} Failed to extract access token"
        echo "Response: $token_response"
        return 1
    fi
    
    echo "$token"
}

# Function to configure client
configure_workflow_nexus_client() {
    local admin_token="$1"
    
    echo "${INFO} Configuring Workflow Nexus client..."
    
    # Create client configuration
    local client_config=$(cat << EOF
{
  "clientId": "$CLIENT_ID",
  "name": "Workflow Nexus (n8n)",
  "description": "n8n Workflow Automation Platform with OIDC Authentication",
  "enabled": true,
  "clientAuthenticatorType": "client-secret",
  "secret": "$CLIENT_SECRET",
  "redirectUris": [
    "http://localhost:5678/*",
    "http://workflow-nexus-service.n8n-prod.svc.cluster.local:5678/*"
  ],
  "webOrigins": [
    "http://localhost:5678",
    "http://workflow-nexus-service.n8n-prod.svc.cluster.local:5678"
  ],
  "protocol": "openid-connect",
  "publicClient": false,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": true,
  "serviceAccountsEnabled": true,
  "authorizationServicesEnabled": false,
  "attributes": {
    "saml.assertion.signature": "false",
    "saml.force.post.binding": "false",
    "saml.multivalued.roles": "false",
    "saml.encrypt": "false",
    "saml.server.signature": "false",
    "saml.server.signature.keyinfo.ext": "false",
    "exclude.session.state.from.auth.response": "false",
    "saml_force_name_id_format": "false",
    "saml.client.signature": "false",
    "tls.client.certificate.bound.access.tokens": "false",
    "saml.authnstatement": "false",
    "display.on.consent.screen": "false",
    "saml.onetimeuse.condition": "false"
  }
}
EOF
)
    
    # Create or update client
    local response
    response=$(kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X POST \
        "http://localhost:8080/admin/realms/$REALM_NAME/clients" \
        -H "Authorization: Bearer $admin_token" \
        -H "Content-Type: application/json" \
        -d "$client_config")
    
    if [ $? -eq 0 ]; then
        echo "${CHECK} Workflow Nexus client configured successfully"
    else
        echo "${WARNING} Client may already exist, attempting update..."
        
        # Get existing client ID
        local client_uuid
        client_uuid=$(kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
            curl -s -X GET \
            "http://localhost:8080/admin/realms/$REALM_NAME/clients?clientId=$CLIENT_ID" \
            -H "Authorization: Bearer $admin_token" | \
            grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
        
        if [ -n "$client_uuid" ]; then
            echo "${INFO} Updating existing client..."
            kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
                curl -s -X PUT \
                "http://localhost:8080/admin/realms/$REALM_NAME/clients/$client_uuid" \
                -H "Authorization: Bearer $admin_token" \
                -H "Content-Type: application/json" \
                -d "$client_config"
            echo "${CHECK} Client updated successfully"
        fi
    fi
}

# Function to create client roles
create_client_roles() {
    local admin_token="$1"
    
    echo "${INFO} Creating client roles for Workflow Nexus..."
    
    # Get client UUID
    local client_uuid
    client_uuid=$(kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X GET \
        "http://localhost:8080/admin/realms/$REALM_NAME/clients?clientId=$CLIENT_ID" \
        -H "Authorization: Bearer $admin_token" | \
        grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -z "$client_uuid" ]; then
        echo "${ERROR} Failed to get client UUID"
        return 1
    fi
    
    # Create workflow-admin role
    kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X POST \
        "http://localhost:8080/admin/realms/$REALM_NAME/clients/$client_uuid/roles" \
        -H "Authorization: Bearer $admin_token" \
        -H "Content-Type: application/json" \
        -d '{"name":"workflow-admin","description":"Workflow Administrator - Full n8n access"}'
    
    # Create workflow-editor role
    kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X POST \
        "http://localhost:8080/admin/realms/$REALM_NAME/clients/$client_uuid/roles" \
        -H "Authorization: Bearer $admin_token" \
        -H "Content-Type: application/json" \
        -d '{"name":"workflow-editor","description":"Workflow Editor - Create and edit workflows"}'
    
    # Create workflow-viewer role
    kubectl exec -n "$KEYCLOAK_NAMESPACE" deployment/guardian-nexus-keycloak -- \
        curl -s -X POST \
        "http://localhost:8080/admin/realms/$REALM_NAME/clients/$client_uuid/roles" \
        -H "Authorization: Bearer $admin_token" \
        -H "Content-Type: application/json" \
        -d '{"name":"workflow-viewer","description":"Workflow Viewer - Read-only access"}'
    
    echo "${CHECK} Client roles created successfully"
}

# Main execution
main() {
    echo "${ROCKET} Starting Keycloak client configuration..."
    
    # Wait for Keycloak to be ready
    if ! wait_for_keycloak; then
        exit 1
    fi
    
    # Get admin token
    local admin_token
    admin_token=$(get_admin_token)
    if [ $? -ne 0 ] || [ -z "$admin_token" ]; then
        echo "${ERROR} Failed to obtain admin token"
        exit 1
    fi
    
    # Configure client
    configure_workflow_nexus_client "$admin_token"
    
    # Create client roles
    create_client_roles "$admin_token"
    
    echo "${CHECK} Keycloak client configuration completed!"
    echo ""
    echo "${INFO} Client Details:"
    echo "  Client ID: $CLIENT_ID"
    echo "  Client Secret: $CLIENT_SECRET"
    echo "  Realm: $REALM_NAME"
    echo "  OIDC Issuer: http://guardian-nexus-service.security-nexus.svc.cluster.local:8080/realms/$REALM_NAME"
    echo ""
    echo "${SHIELD} Workflow Nexus is ready for OIDC integration!"
}

# Execute main function
main "$@"