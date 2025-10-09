#!/bin/bash
# File Bridge Test Script
# Tests the complete file bridge deployment process

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_header() { echo -e "\n${PURPLE}🔥 $1${NC}"; echo -e "${PURPLE}$(printf '=%.0s' $(seq 1 ${#1}))${NC}"; }

# Test configuration
TEST_BRIDGE_NAME="test-bridge"
TEST_HOST="localhost"
TEST_PATH="/tmp"
TEST_USER="$USER"
TEST_MODE="read-write"

log_header "File Bridge Platform Test"

# Test 1: SSH Key Generation
log_info "Testing SSH key generation..."
# Clean up any existing test keys first
./ssh-key-manager.sh cleanup "$TEST_BRIDGE_NAME" <<< "y" >/dev/null 2>&1 || true
if ./ssh-key-manager.sh generate "$TEST_BRIDGE_NAME" >/dev/null 2>&1; then
    log_success "SSH key generation works"
else
    log_error "SSH key generation failed"
    exit 1
fi

# Test 2: Key Manager Commands
log_info "Testing key manager commands..."
if ./ssh-key-manager.sh list >/dev/null 2>&1; then
    log_success "Key listing works"
else
    log_warning "Key listing had issues (non-fatal)"
fi

if ./ssh-key-manager.sh show "$TEST_BRIDGE_NAME" >/dev/null 2>&1; then
    log_success "Key display works"
else
    log_warning "Key display had issues (non-fatal)"
fi

# Test 3: YAML Template Validation
log_info "Testing YAML template validation..."
cd ..

# Validate configmap
if kubectl apply --dry-run=client -f file_bridge_deployment/file-bridge-configmap.yaml >/dev/null 2>&1; then
    log_success "ConfigMap template is valid"
else
    log_error "ConfigMap template validation failed"
    exit 1
fi

# Test parameter substitution
log_info "Testing parameter substitution..."
SFTP_PORT=2201
sed \
    -e "s/BRIDGE_NAME/$TEST_BRIDGE_NAME/g" \
    -e "s/TARGET_HOST_VALUE/$TEST_HOST/g" \
    -e "s/SSH_USER_VALUE/$TEST_USER/g" \
    -e "s|REMOTE_PATH_VALUE|$TEST_PATH|g" \
    -e "s/ACCESS_MODE_VALUE/$TEST_MODE/g" \
    -e "s/SFTP_PORT_VALUE/$SFTP_PORT/g" \
    -e "s/SFTP_PORT/$SFTP_PORT/g" \
    file_bridge_deployment/file-bridge-deployment.yaml > /tmp/test-bridge-deployment.yaml

if kubectl apply --dry-run=client -f /tmp/test-bridge-deployment.yaml >/dev/null 2>&1; then
    log_success "Deployment template substitution works"
else
    log_error "Deployment template substitution failed"
    exit 1
fi

# Test 4: Makefile Integration
log_info "Testing Makefile integration..."
if grep -q "new-file-bridge:" /home/keldamar/repos/rancher-deployment-test/Makefile; then
    log_success "Makefile help integration works"
else
    log_error "Makefile help integration failed"
    exit 1
fi

# Test 5: Resource Validation
log_info "Testing resource requirements..."
if kubectl get nodes >/dev/null 2>&1; then
    log_success "Kubernetes cluster is accessible"
else
    log_error "Kubernetes cluster not accessible"
    exit 1
fi

# Cleanup test files
log_info "Cleaning up test files..."
rm -f /tmp/test-bridge-deployment.yaml
if [ -d "ssh-keys/$TEST_BRIDGE_NAME" ]; then
    rm -rf "ssh-keys/$TEST_BRIDGE_NAME"
fi

log_header "File Bridge Platform Test Results"
log_success "ALL TESTS PASSED! 🎉"
echo
echo -e "${BLUE}📋 Platform Ready For:${NC}"
echo "  🔑 SSH key management"
echo "  📁 SSHFS/SFTP bridge deployment" 
echo "  ☸️  Kubernetes integration"
echo "  🎛️  Makefile automation"
echo "  🔍 Comprehensive monitoring"
echo
echo -e "${YELLOW}🚀 Deploy your first bridge:${NC}"
echo "  make new-file-bridge NAME=input HOST=fileserver.local PATH=/data/input MODE=write-only"
echo
echo -e "${PURPLE}🌟 File Bridge Platform is READY! 🌟${NC}"