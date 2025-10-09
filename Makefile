# =============================================================================
# 🌟 Starbridge Platform - Dual-Mode Enterprise Deployment System
# =============================================================================
# Genesis Architecture v2.0.0 - Enterprise Fleet Deployment System
# 
# DEVELOPER MODE:  Fast iteration, minimal complexity, rapid prototyping
# PRODUCTION MODE: Enterprise security, Guardian Nexus OIDC, full fleet
#
# Fleet Service Designations:
# - Workflow Nexus (n8n)        - Data Vault (PostgreSQL)
# - Neural Nexus (Ollama)       - Starbridge Beacon (webserver)  
# - File Bridge (data sync)     - Guardian Nexus (Keycloak OIDC)
#
# Version: 2.0.0 - GENESIS ARCHITECTURE
# =============================================================================

# 🎯 Fleet Command Center
ROCKET    := 🚀
DATABASE  := 🐘
ROBOT     := 🤖
BRAIN     := 🧠
SHIELD    := 🛡️
BEACON    := 📡
BRIDGE    := 🌉
CLEAN     := 🧹
LOGS      := 📋
CONFIG    := ⚙️
NETWORK   := 🔗
CHECK     := ✅
WARNING   := ⚠️
ERROR     := ❌
INFO      := 💡

# 🏗️ Platform Architecture Configuration
# Developer Mode - Fast & Simple
DEV_NAMESPACE           := starbridge-dev
DEV_DATA_NAMESPACE      := data-vault-dev

# Production Mode - Enterprise & Secure  
PROD_NAMESPACE          := starbridge-prod
PROD_DATA_NAMESPACE     := data-vault-prod
SECURITY_NAMESPACE      := security-nexus

# Common Configuration
DEFAULT_PORT            := 8080
SFRS_SCRIPT            := ./sfrs.sh

# Environment variables with defaults
MODE                   ?= dev
PORT                   ?= $(DEFAULT_PORT)
FOLLOW                 ?= false
TAIL_LINES             ?= 100

# Legacy compatibility for cleanup functions (Fleet Redesignation)
N8N_NAMESPACE          := $(if $(filter prod,$(MODE)),$(PROD_NAMESPACE),$(DEV_NAMESPACE))

# Fleet directory structure (Genesis Architecture v2.0.0)
WORKFLOW_NEXUS_DIR     := workflow_nexus_deployment
DATA_VAULT_DIR         := data_vault_deployment  
GUARDIAN_NEXUS_DIR     := guardian_nexus_deployment
NEURAL_NEXUS_DIR       := neural_nexus_deployment
STARBRIDGE_BEACON_DIR  := starbridge_beacon_deployment
FILE_BRIDGE_DIR        := file_bridge_deployment

# Legacy directory compatibility for cleanup functions
N8N_DIR               := $(WORKFLOW_NEXUS_DIR)
POSTGRES_DIR          := $(DATA_VAULT_DIR)

# Derived variables for cross-namespace deployment
DB_NAME_SAFE            := $(shell echo "$(N8N_NAMESPACE)" | tr '-' '_')
DB_USER_SAFE            := $(shell echo "$(N8N_NAMESPACE)" | tr '-' '_')

# Ollama configuration
DEFAULT_OLLAMA_NAMESPACE := ollama-models
OLLAMA_NAMESPACE        ?= $(DEFAULT_OLLAMA_NAMESPACE)
MODEL                   ?= llama3.1
SIZE                    ?= 7b
REPLICAS                ?= 1
GPU                     ?= false
STORAGE                 ?= 50Gi

# Port-forwarding configuration
SERVICE                 ?= n8n-service
TARGET_NAMESPACE        ?= $(N8N_NAMESPACE)
TARGET_PORT             ?= 80
POSTGRES_PORT           ?= 5432
OLLAMA_PORT             ?= 11434

# Model catalog with metadata (format: model:size:cpu_req:mem_req:cpu_limit:mem_limit:type)
MODEL_LLAMA31_7B     := llama3.1:7b:2:8:4:12:text
MODEL_LLAMA31_8B     := llama3.1:8b:2:8:4:12:text
MODEL_LLAMA31_70B    := llama3.1:70b:8:32:12:48:text
MODEL_CODELLAMA_7B   := codellama:7b:2:8:4:12:code
MODEL_CODELLAMA_13B  := codellama:13b:4:16:6:24:code
MODEL_CODELLAMA_34B  := codellama:34b:8:32:12:48:code
MODEL_MISTRAL_7B     := mistral:7b:2:8:4:12:text
MODEL_PHI3_3B        := phi3:3.8b:1:4:2:6:text
MODEL_GEMMA_2B       := gemma:2b:0.5:2:1:3:text
MODEL_GEMMA_7B       := gemma:7b:2:8:4:12:text
MODEL_LLAVA_7B       := llava:7b:2:8:4:12:vision
MODEL_LLAVA_13B      := llava:13b:4:16:6:24:vision
MODEL_LLAVA_34B      := llava:34b:8:32:12:48:vision
MODEL_BAKLLAVA_7B    := bakllava:7b:2:8:4:12:vision
MODEL_MOONDREAM_2B   := moondream:1.8b:0.5:2:1:3:vision
MODEL_DOLPHIN_8X7B   := dolphin-mixtral:8x7b:8:32:12:48:text
MODEL_NEURAL_7B      := neural-chat:7b:2:8:4:12:chat
MODEL_STARLING_7B    := starling-lm:7b:2:8:4:12:reasoning

# Helper to get model specifications
get_model_spec = $(if $(MODEL_$(shell echo $(1)_$(2) | tr 'a-z.-' 'A-Z__')),$(MODEL_$(shell echo $(1)_$(2) | tr 'a-z.-' 'A-Z__')),$(1):$(2):1:4:2:6:text)
get_spec_field = $(word $(2),$(subst :, ,$(call get_model_spec,$(1),$(SIZE))))

# Auto-detect model parameters
MODEL_FULL            := $(MODEL):$(SIZE)
MODEL_NAME_SAFE       := $(shell echo "$(MODEL)-$(SIZE)" | tr '.' '-' | tr ':' '-')
MODEL_CPU_REQUEST     := $(call get_spec_field,$(MODEL),3)
MODEL_MEMORY_REQUEST  := $(call get_spec_field,$(MODEL),4)Gi
MODEL_CPU_LIMIT       := $(call get_spec_field,$(MODEL),5)
MODEL_MEMORY_LIMIT    := $(call get_spec_field,$(MODEL),6)Gi
MODEL_TYPE            := $(call get_spec_field,$(MODEL),7)

.DEFAULT_GOAL := help

# =============================================================================
# 📋 FLEET COMMAND CENTER - HELP & DOCUMENTATION  
# =============================================================================

.PHONY: help
help: ## 📋 Display Starbridge Platform Fleet Command Center
	@echo "$(ROCKET) Starbridge Platform - Genesis Architecture v2.0.0"
	@echo "═════════════════════════════════════════════════════════════════════════════════"
	@echo "$(SHIELD) Genesis Architecture - Dual-Mode Enterprise Deployment System"
	@echo ""
	@echo "$(ROCKET) DUAL-MODE DEPLOYMENT:"
	@awk '/^[a-zA-Z_-]+:.*?## .*DEPLOY.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(BEACON) DEVELOPER MODE (Fast & Simple):"
	@awk '/^[a-zA-Z_-]+:.*?## .*DEV.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(SHIELD) PRODUCTION MODE (Enterprise Security):"
	@awk '/^[a-zA-Z_-]+:.*?## .*PROD.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(DATABASE) DATA VAULT OPERATIONS:"
	@awk '/^[a-zA-Z_-]+:.*?## .*VAULT.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(ROBOT) WORKFLOW NEXUS OPERATIONS:"
	@awk '/^[a-zA-Z_-]+:.*?## .*WORKFLOW.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(BRAIN) NEURAL NEXUS OPERATIONS:"
	@awk '/^[a-zA-Z_-]+:.*?## .*NEURAL.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(BRIDGE) FILE BRIDGE OPERATIONS:"
	@awk '/^[a-zA-Z_-]+:.*?## .*BRIDGE.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(BEACON) STARBRIDGE BEACON (Web Interface):"
	@awk '/^[a-zA-Z_-]+:.*?## .*BEACON.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(SHIELD) GUARDIAN NEXUS (Security):"
	@awk '/^[a-zA-Z_-]+:.*?## .*GUARDIAN.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(NETWORK) SFRS (Fleet Relay System):"
	@awk '/^[a-zA-Z_-]+:.*?## .*SFRS.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(LOGS) FLEET MONITORING:"
	@awk '/^[a-zA-Z_-]+:.*?## .*MONITOR.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "$(CLEAN) CLEANUP OPERATIONS:"
	@awk '/^[a-zA-Z_-]+:.*?## .*CLEAN.*/ { printf "  %-30s %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sed 's/:.*##//'
	@echo ""
	@echo "═════════════════════════════════════════════════════════════════════════════════"
	@echo "$(ROCKET) Quick Start Examples:"
	@echo "  make deploy-dev                         - Deploy Developer Mode (minimal setup)"
	@echo "  make deploy-prod                        - Deploy Production Mode (full security)"
	@echo "  make platform-status                    - Show both platform modes status"
	@echo "  make sfrs-start-fleet                   - Start complete fleet with SFRS"
	@echo "  make nuclear-clean                      - Complete platform reset"
	@echo ""
	@echo "$(CONFIG) Fleet Configuration:"
	@echo "  MODE             - Deployment mode: dev|prod (default: dev)"
	@echo "  DEV_NAMESPACE    - Developer namespace (default: $(DEV_NAMESPACE))"
	@echo "  PROD_NAMESPACE   - Production namespace (default: $(PROD_NAMESPACE))"
	@echo "  SECURITY_NS      - Security namespace (default: $(SECURITY_NAMESPACE))"
	@echo "  VAULT            - Enable Vault integration (default: disabled)"
	@echo ""

# =============================================================================
# 🔐 VAULT NEXUS - ADVANCED SECRET MANAGEMENT
# =============================================================================

.PHONY: deploy-vault-nexus
deploy-vault-nexus: ## 🔐 DEPLOY Vault Nexus secret management
	@echo "$(SHIELD) Deploying Vault Nexus - Advanced Secret Management"
	@echo "═══════════════════════════════════════════════════════════════"
	@$(MAKE) _create-security-namespace
	@echo "$(SHIELD) Deploying Vault configuration..."
	kubectl apply -f vault_nexus_deployment/vault-nexus-config.yaml
	@echo "$(SHIELD) Setting up RBAC..."
	kubectl apply -f vault_nexus_deployment/vault-nexus-rbac.yaml
	@echo "$(SHIELD) Deploying Vault server..."
	kubectl apply -f vault_nexus_deployment/vault-nexus-deployment.yaml
	@echo "$(CHECK) Waiting for Vault to be ready..."
	kubectl wait --for=condition=available deployment/vault-nexus -n security-nexus --timeout=300s
	@echo "$(SHIELD) Deploying Vault Agent Injector..."
	kubectl apply -f vault_nexus_deployment/vault-agent-injector.yaml
	@echo "✅ Vault Nexus deployed successfully!"
	@echo ""
	@echo "📋 Next steps:"
	@echo "  1. make vault-init       - Initialize Vault"
	@echo "  2. make vault-setup      - Configure policies and secrets"
	@echo "  3. Deploy services with VAULT=enabled"

.PHONY: vault-init
vault-init: ## 🔑 Initialize Vault (first-time setup)
	@echo "$(SHIELD) Initializing Vault Nexus..."
	@chmod +x vault_nexus_deployment/vault-init.sh
	@vault_nexus_deployment/vault-init.sh

.PHONY: vault-setup
vault-setup: vault-setup-policies vault-setup-secrets ## 🛡️ Complete Vault setup (policies + secrets)

.PHONY: vault-setup-policies
vault-setup-policies: ## 📋 Setup Vault policies
	@echo "$(SHIELD) Setting up Vault policies..."
	@chmod +x vault_nexus_deployment/vault-setup-policies.sh
	@vault_nexus_deployment/vault-setup-policies.sh

.PHONY: vault-setup-secrets
vault-setup-secrets: ## 🔑 Setup initial secrets in Vault
	@echo "$(SHIELD) Setting up Vault secrets..."
	@chmod +x vault_nexus_deployment/vault-setup-secrets.sh
	@vault_nexus_deployment/vault-setup-secrets.sh

.PHONY: vault-status
vault-status: ## 📊 Check Vault status
	@echo "$(SHIELD) Vault Nexus Status:"
	@kubectl get pods -n security-nexus -l app=vault-nexus
	@echo ""
	@kubectl port-forward -n security-nexus service/vault-nexus 8200:8200 &
	@sleep 2
	@export VAULT_ADDR="http://localhost:8200" && vault status || true
	@pkill -f "kubectl port-forward.*vault-nexus" || true

.PHONY: vault-unseal
vault-unseal: ## 🔓 Unseal Vault (provide unseal key when prompted)
	@echo "$(SHIELD) Unsealing Vault..."
	@kubectl port-forward -n security-nexus service/vault-nexus 8200:8200 &
	@sleep 2
	@export VAULT_ADDR="http://localhost:8200" && vault operator unseal
	@pkill -f "kubectl port-forward.*vault-nexus" || true

.PHONY: vault-ui
vault-ui: ## 🖥️ Access Vault UI (opens port-forward)
	@echo "$(SHIELD) Starting Vault UI access..."
	@echo "$(INFO) Vault UI will be available at: http://localhost:8200"
	@echo "$(INFO) Press Ctrl+C to stop port forwarding"
	kubectl port-forward -n security-nexus service/vault-nexus 8200:8200

# =============================================================================
# 🚀 DUAL-MODE DEPLOYMENT SYSTEM - GENESIS ARCHITECTURE
# =============================================================================

.PHONY: deploy-dev
deploy-dev: ## $(ROCKET) DEPLOY Developer Mode - Fast minimal setup
	@echo "$(ROCKET) Deploying Starbridge Platform - DEVELOPER MODE"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "$(INFO) Fast iteration setup with minimal complexity"
	@echo "$(BEACON) Namespace: $(DEV_NAMESPACE)"
	@echo "$(DATABASE) Data Vault: $(DEV_DATA_NAMESPACE)"
	@echo ""
	@$(MAKE) _create-dev-namespaces
	@$(MAKE) _deploy-data-vault-dev
	@$(MAKE) _deploy-workflow-nexus-dev
	@$(MAKE) _deploy-neural-nexus-dev
	@$(MAKE) _deploy-file-bridge-dev
	@$(MAKE) _deploy-starbridge-beacon-dev
	@$(MAKE) _start-dev-fleet
	@echo ""
	@echo "$(CHECK) Developer Mode deployment complete!"
	@echo "$(NETWORK) SFRS Fleet Relay managing all connections"

.PHONY: deploy-prod
deploy-prod: ## $(SHIELD) DEPLOY Production Mode - Enterprise security with Guardian Nexus
	@echo "$(ROCKET) Deploying Starbridge Platform - PRODUCTION MODE"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "$(SHIELD) Enterprise security with Guardian Nexus OIDC"
	@echo "$(BEACON) Namespace: $(PROD_NAMESPACE)"
	@echo "$(DATABASE) Data Vault: $(PROD_DATA_NAMESPACE)"
	@echo "$(SHIELD) Security: $(SECURITY_NAMESPACE)"
	@echo ""
	@$(MAKE) _create-prod-namespaces
	@$(MAKE) _deploy-guardian-nexus
	@$(MAKE) _deploy-data-vault-prod
	@$(MAKE) _deploy-workflow-nexus-secure
	@$(MAKE) _deploy-neural-nexus-prod
	@$(MAKE) _deploy-file-bridge-prod
	@$(MAKE) _deploy-starbridge-beacon-prod
	@$(MAKE) _start-prod-fleet
	@echo ""
	@echo "$(CHECK) Production Mode deployment complete!"
	@echo "$(SHIELD) Guardian Nexus OIDC authentication active"
	@echo "$(NETWORK) SFRS Fleet Relay managing all connections"

.PHONY: platform-status
platform-status: ## $(LOGS) MONITOR Show status of both platform modes
	@echo "$(ROCKET) Starbridge Platform - Fleet Status Report"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "$(BEACON) DEVELOPER MODE STATUS:"
	@kubectl get pods -n $(DEV_NAMESPACE) 2>/dev/null | head -10 || echo "  $(WARNING) Developer mode not deployed"
	@echo ""
	@echo "$(SHIELD) PRODUCTION MODE STATUS:"
	@kubectl get pods -n $(PROD_NAMESPACE) 2>/dev/null | head -10 || echo "  $(WARNING) Production mode not deployed"
	@echo ""
	@echo "$(SHIELD) GUARDIAN NEXUS STATUS:"
	@kubectl get pods -n $(SECURITY_NAMESPACE) 2>/dev/null | head -10 || echo "  $(WARNING) Guardian Nexus not deployed"
	@echo ""
	@echo "$(NETWORK) SFRS FLEET RELAY STATUS:"
	@$(SFRS_SCRIPT) list || echo "  $(WARNING) SFRS not active"

.PHONY: deploy-dev-clean
deploy-dev-clean: ## $(CLEAN) CLEAN Remove developer mode deployment
	@echo "$(CLEAN) Cleaning Developer Mode deployment..."
	@kubectl delete namespace $(DEV_NAMESPACE) $(DEV_DATA_NAMESPACE) --ignore-not-found=true
	@echo "$(CHECK) Developer Mode cleaned"

.PHONY: deploy-prod-clean
deploy-prod-clean: ## $(CLEAN) CLEAN Remove production mode deployment
	@echo "$(CLEAN) Cleaning Production Mode deployment..."
	@kubectl delete namespace $(PROD_NAMESPACE) $(PROD_DATA_NAMESPACE) $(SECURITY_NAMESPACE) --ignore-not-found=true
	@echo "$(CHECK) Production Mode cleaned"

.PHONY: nuclear-clean
nuclear-clean: ## $(CLEAN) CLEAN Complete platform reset - remove everything
	@echo "$(WARNING) Initiating NUCLEAR CLEAN protocol..."
	@echo "$(CLEAN) Stopping all SFRS sessions..."
	@$(SFRS_SCRIPT) stop-all || true
	@echo "$(CLEAN) Removing all platform namespaces..."
	@kubectl get namespaces | grep -E "(starbridge|data-vault|guardian)" | awk '{print $$1}' | xargs -I {} kubectl delete namespace {} --timeout=60s --ignore-not-found=true || true
	@echo "$(CHECK) Nuclear clean complete - all platforms reset"

# =============================================================================
# 🛠️ INTERNAL DEPLOYMENT HELPERS - DEVELOPER MODE
# =============================================================================

.PHONY: _create-dev-namespaces
_create-dev-namespaces:
	@echo "$(INFO) Creating developer mode namespaces..."
	@kubectl create namespace $(DEV_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create namespace $(DEV_DATA_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

.PHONY: _deploy-data-vault-dev
_deploy-data-vault-dev:
	@echo "$(DATABASE) Deploying Data Vault (PostgreSQL) for developer mode..."
	@kubectl apply -f data_vault_deployment/ -n $(DEV_DATA_NAMESPACE)
	@kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s -n $(DEV_DATA_NAMESPACE)

.PHONY: _deploy-workflow-nexus-dev
_deploy-workflow-nexus-dev:
	@echo "$(ROBOT) Deploying Workflow Nexus (n8n) for developer mode..."
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-config.yaml -n $(DEV_NAMESPACE)
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-secret.yaml -n $(DEV_NAMESPACE)
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-pvc.yaml -n $(DEV_NAMESPACE)
	@echo "$(DATABASE) Setting up cross-namespace Data Vault connection..."
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-db-setup.yaml -n $(DEV_NAMESPACE)
	@kubectl wait --for=condition=complete job/workflow-nexus-db-setup-dev --timeout=120s -n $(DEV_NAMESPACE)
	@echo "$(CHECK) Data Vault setup completed successfully"
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-deployment.yaml -n $(DEV_NAMESPACE)
	@kubectl wait --for=condition=ready pod -l app=workflow-nexus --timeout=300s -n $(DEV_NAMESPACE)

.PHONY: _deploy-neural-nexus-dev
_deploy-neural-nexus-dev:
	@echo "$(BRAIN) Deploying Neural Nexus (AI Models) for developer mode..."
	@$(MAKE) _create-neural-nexus-namespace
	@$(MAKE) _deploy-neural-nexus-storage
	@$(MAKE) _deploy-neural-nexus-default-model

.PHONY: _create-neural-nexus-namespace
_create-neural-nexus-namespace:
	@kubectl create namespace neural-nexus-dev --dry-run=client -o yaml | kubectl apply -f -

.PHONY: _deploy-neural-nexus-storage
_deploy-neural-nexus-storage:
	@echo "$(DATABASE) Setting up Neural Nexus storage..."
	@kubectl apply -f neural_nexus_deployment/ollama-configmap.yaml -n neural-nexus-dev
	@kubectl apply -f neural_nexus_deployment/ollama-pvc.yaml -n neural-nexus-dev

.PHONY: _deploy-neural-nexus-default-model
_deploy-neural-nexus-default-model:
	@echo "$(BRAIN) Deploying default AI model from catalog..."
	@$(MAKE) deploy-neural-nexus-model MODEL=llama31-7b NAMESPACE=neural-nexus-dev MODE=dev

.PHONY: _deploy-file-bridge-dev
_deploy-file-bridge-dev:
	@echo "$(BRIDGE) Deploying File Bridge for developer mode..."
	@kubectl apply -f file_bridge_deployment/ -n $(DEV_NAMESPACE)

.PHONY: _deploy-starbridge-beacon-dev
_deploy-starbridge-beacon-dev:
	@echo "$(BEACON) Deploying Starbridge Beacon (webserver) for developer mode..."
	@kubectl apply -f starbridge_beacon_deployment/ -n $(DEV_NAMESPACE)

.PHONY: _start-dev-fleet
_start-dev-fleet:
	@echo "$(NETWORK) Starting SFRS Fleet Relay for developer mode..."
	@$(SFRS_SCRIPT) start workflow-nexus-dev workflow-nexus-service $(DEV_NAMESPACE) 5678 8080 || true
	@$(SFRS_SCRIPT) start data-vault-dev postgres-service $(DEV_DATA_NAMESPACE) 5432 8082 || true
	@$(SFRS_SCRIPT) start starbridge-beacon-dev starbridge-webserver-service $(DEV_NAMESPACE) 80 8083 || true

# =============================================================================
# 🛠️ INTERNAL DEPLOYMENT HELPERS - PRODUCTION MODE
# =============================================================================

.PHONY: _create-prod-namespaces
_create-prod-namespaces:
	@echo "$(INFO) Creating production mode namespaces..."
	@kubectl create namespace $(PROD_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create namespace $(PROD_DATA_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create namespace $(SECURITY_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

.PHONY: _deploy-guardian-nexus
_deploy-guardian-nexus:
	@echo "$(SHIELD) Deploying Guardian Nexus (Keycloak) security system..."
	@kubectl apply -f guardian_nexus_deployment/ -n $(SECURITY_NAMESPACE)
	@kubectl wait --for=condition=ready pod -l app=guardian-nexus-keycloak --timeout=300s -n $(SECURITY_NAMESPACE)

.PHONY: _deploy-data-vault-prod
_deploy-data-vault-prod:
	@echo "$(DATABASE) Deploying Data Vault (PostgreSQL) for production mode..."
	@kubectl apply -f data_vault_deployment/ -n $(PROD_DATA_NAMESPACE)
	@kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s -n $(PROD_DATA_NAMESPACE)

.PHONY: _deploy-workflow-nexus-secure
_deploy-workflow-nexus-secure:
	@echo "$(ROBOT)$(SHIELD) Deploying Workflow Nexus (n8n) with OIDC security..."
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-prod-config.yaml -n $(PROD_NAMESPACE)
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-prod-secret.yaml -n $(PROD_NAMESPACE)
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-pvc.yaml -n $(PROD_NAMESPACE)
	@kubectl apply -f workflow_nexus_deployment/workflow-nexus-dev-deployment.yaml -n $(PROD_NAMESPACE)
	@kubectl wait --for=condition=ready pod -l app=workflow-nexus --timeout=300s -n $(PROD_NAMESPACE)

.PHONY: _deploy-neural-nexus-prod
_deploy-neural-nexus-prod:
	@echo "$(BRAIN) Deploying Neural Nexus (Ollama) for production mode..."
	@kubectl apply -f neural_nexus_deployment/ -n $(PROD_NAMESPACE)

.PHONY: _deploy-file-bridge-prod
_deploy-file-bridge-prod:
	@echo "$(BRIDGE) Deploying File Bridge for production mode..."
	@kubectl apply -f file_bridge_deployment/ -n $(PROD_NAMESPACE)

.PHONY: _deploy-starbridge-beacon-prod
_deploy-starbridge-beacon-prod:
	@echo "$(BEACON) Deploying Starbridge Beacon (webserver) for production mode..."
	@kubectl apply -f starbridge_beacon_deployment/ -n $(PROD_NAMESPACE)

.PHONY: _start-prod-fleet
_start-prod-fleet:
	@echo "$(NETWORK) Starting SFRS Fleet Relay for production mode..."
	@$(SFRS_SCRIPT) start guardian-nexus guardian-nexus-service $(SECURITY_NAMESPACE) 8080 8081 || true
	@$(SFRS_SCRIPT) start workflow-nexus-prod workflow-nexus-service $(PROD_NAMESPACE) 5678 8080 || true
	@$(SFRS_SCRIPT) start data-vault-prod postgres-service $(PROD_DATA_NAMESPACE) 5432 8084 || true

# =============================================================================
# �🐘 LEGACY DATABASE DEPLOYMENT TARGETS (COMPATIBILITY)
# =============================================================================

.PHONY: deploy-postgres
deploy-postgres: ## 🐘 DATABASE Deploy PostgreSQL database in specified namespace
	@echo "✅$(ROCKET) Deploying PostgreSQL to namespace: ⚙️$(NAMESPACE)"
	@kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@echo "🔷💡 Applying PostgreSQL manifests..."
	@kubectl apply -f $(POSTGRES_DIR)/ -n $(NAMESPACE)
	@echo "🔷💡 Waiting for PostgreSQL to be ready..."
	@kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s -n $(NAMESPACE)
	@echo "✅$(CHECK) PostgreSQL deployed successfully!"

# =============================================================================
# 🤖 N8N DEPLOYMENT TARGETS  
# =============================================================================

.PHONY: deploy-n8n
deploy-n8n: ## 🤖 N8N Deploy n8n workflow automation in specified namespace
	@echo "✅$(ROCKET) Deploying n8n to namespace: ⚙️$(NAMESPACE)"
	@kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@echo "🔷💡 Applying n8n manifests..."
	@kubectl apply -f $(N8N_DIR)/ -n $(NAMESPACE)
	@echo "🔷💡 Waiting for n8n to be ready..."
	@kubectl wait --for=condition=ready pod -l app=n8n --timeout=300s -n $(NAMESPACE)
	@echo "✅$(CHECK) n8n deployed successfully!"
	@echo "⚙️💡 Starting port-forward to access n8n..."
	@$(MAKE) port-forward-n8n PORT=$(PORT)

# =============================================================================
# � N8N SSH KEY MANAGEMENT TARGETS
# =============================================================================

.PHONY: n8n-deploy-ssh-keys
n8n-deploy-ssh-keys: ## 🤖 N8N Deploy SSH keys for file bridge access to n8n pod
	@echo "🔑 Deploying SSH keys to n8n..."
	@./n8n-ssh-key-manager.sh deploy-keys $(if $(BRIDGE_NAME),$(BRIDGE_NAME),all)

.PHONY: n8n-list-ssh-keys
n8n-list-ssh-keys: ## 🤖 N8N List available SSH keys in n8n secret
	@./n8n-ssh-key-manager.sh list-keys

.PHONY: n8n-get-private-key
n8n-get-private-key: ## 🤖 N8N Get private key content for n8n credential setup (requires BRIDGE_NAME=<name>)
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME parameter required"; \
		echo "💡 Usage: make n8n-get-private-key BRIDGE_NAME=input"; \
		exit 1; \
	fi
	@./n8n-ssh-key-manager.sh get-private-key $(BRIDGE_NAME)

.PHONY: n8n-test-bridge-connection
n8n-test-bridge-connection: ## 🤖 N8N Test connection from n8n to file bridge (requires BRIDGE_NAME=<name>)
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME parameter required"; \
		echo "💡 Usage: make n8n-test-bridge-connection BRIDGE_NAME=input"; \
		exit 1; \
	fi
	@./n8n-ssh-key-manager.sh test-n8n-connection $(BRIDGE_NAME)

.PHONY: n8n-delete-ssh-keys
n8n-delete-ssh-keys: ## 🤖 N8N Delete all SSH keys from n8n secret
	@./n8n-ssh-key-manager.sh delete-keys

# =============================================================================
# �🔗 CROSS-NAMESPACE DEPLOYMENT TARGETS
# =============================================================================

.PHONY: deploy-cross
deploy-cross: ## 🔗 CROSS Deploy n8n in cross-namespace configuration with shared PostgreSQL
	@echo "✅$(ROCKET) Deploying cross-namespace setup:"
	@echo "  ─Database Namespace: ⚙️$(DB_NAMESPACE)"
	@echo "  ─n8n Namespace:     ⚙️$(N8N_NAMESPACE)"
	@echo ""
	@$(MAKE) _ensure-postgres
	@$(MAKE) _setup-cross-db
	@$(MAKE) _deploy-cross-manifests
	@$(MAKE) _wait-cross-ready
	@echo "✅$(CHECK) Cross-namespace deployment completed!"
	@echo "⚙️💡 Starting port-forward for access..."
	@$(MAKE) port-forward-n8n PORT=$(PORT)

.PHONY: _ensure-postgres
_ensure-postgres:
	@echo "🔷💡 Ensuring PostgreSQL is running in $(DB_NAMESPACE)..."
	@kubectl create namespace $(DB_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@if ! kubectl get deployment postgres -n $(DB_NAMESPACE) >/dev/null 2>&1; then \
		echo "⚙️⚠️ PostgreSQL not found, deploying..."; \
		$(MAKE) deploy-postgres NAMESPACE=$(DB_NAMESPACE); \
	else \
		echo "✅$(CHECK) PostgreSQL already running"; \
	fi

.PHONY: _setup-cross-db
_setup-cross-db:
	@echo "🔷💡 Setting up database for $(N8N_NAMESPACE)..."
	@echo 'apiVersion: batch/v1' > /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo 'kind: Job' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo 'metadata:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '  name: n8n-db-setup-$(N8N_NAMESPACE)' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '  labels:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '    app: n8n-db-setup' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo 'spec:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '  backoffLimit: 3' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '  template:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '    spec:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '      restartPolicy: OnFailure' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '      containers:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '        - name: postgres-client' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '          image: postgres:16' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '          env:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '            - name: PGPASSWORD' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              value: "postgres123"' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '          command: ["/bin/bash", "-c"]' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '          args:' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '            - |' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              set -e' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              until pg_isready -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -p 5432 -U admin; do sleep 2; done' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '\''$(DB_NAME_SAFE)'\''" | grep -q 1 || psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c "CREATE DATABASE $(DB_NAME_SAFE);"' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='\''$(DB_USER_SAFE)'\''" | grep -q 1 || psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c "CREATE USER $(DB_USER_SAFE) WITH PASSWORD '\''$(DB_USER_SAFE)@123'\'';"' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $(DB_NAME_SAFE) TO $(DB_USER_SAFE);"' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@echo '              psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d $(DB_NAME_SAFE) -c "GRANT ALL ON SCHEMA public TO $(DB_USER_SAFE);"' >> /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml
	@kubectl apply -f /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml -n $(N8N_NAMESPACE)
	@kubectl wait --for=condition=complete --timeout=120s job/n8n-db-setup-$(N8N_NAMESPACE) -n $(N8N_NAMESPACE)
	@rm -f /tmp/n8n-db-setup-$(N8N_NAMESPACE).yaml

.PHONY: _deploy-cross-manifests
_deploy-cross-manifests:
	@echo "🔷💡 Creating namespace $(N8N_NAMESPACE)..."
	@kubectl create namespace $(N8N_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@$(MAKE) _deploy-cross-configmap
	@$(MAKE) _deploy-cross-secret
	@echo "🔷💡 Deploying n8n manifests..."
	@kubectl apply -f $(N8N_DIR)/n8n-pvc.yaml -n $(N8N_NAMESPACE)
	@kubectl apply -f $(N8N_DIR)/n8n-deployment.yaml -n $(N8N_NAMESPACE)
	@kubectl apply -f $(N8N_DIR)/n8n-service.yaml -n $(N8N_NAMESPACE)

.PHONY: _deploy-cross-configmap
_deploy-cross-configmap:
	@echo "🔷💡 Creating ConfigMap for $(N8N_NAMESPACE)..."
	@echo 'apiVersion: v1' > /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo 'kind: ConfigMap' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo 'metadata:' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  name: n8n-config' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  labels:' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '    app: n8n' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo 'data:' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  N8N_HOST: "localhost"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  N8N_PORT: "5678"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  N8N_PROTOCOL: "http"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  WEBHOOK_URL: "http://localhost:$(PORT)"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  GENERIC_TIMEZONE: "UTC"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  TZ: "UTC"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_TYPE: "postgresdb"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_POSTGRESDB_HOST: "postgres-service.$(DB_NAMESPACE).svc.cluster.local"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_POSTGRESDB_PORT: "5432"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_POSTGRESDB_DATABASE: "$(DB_NAME_SAFE)"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_POSTGRESDB_USER: "$(DB_USER_SAFE)"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@echo '  DB_POSTGRESDB_PASSWORD: "$(DB_USER_SAFE)@123"' >> /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml
	@kubectl apply -f /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml -n $(N8N_NAMESPACE)
	@rm -f /tmp/n8n-configmap-$(N8N_NAMESPACE).yaml

.PHONY: _deploy-cross-secret
_deploy-cross-secret:
	@echo "🔷💡 Creating Secret for $(N8N_NAMESPACE)..."
	@echo 'apiVersion: v1' > /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo 'kind: Secret' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo 'metadata:' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo '  name: n8n-secret' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo '  labels:' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo '    app: n8n' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo 'type: Opaque' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo 'stringData:' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@echo '  N8N_ENCRYPTION_KEY: "n8n-secret-key-$(N8N_NAMESPACE)"' >> /tmp/n8n-secret-$(N8N_NAMESPACE).yaml
	@kubectl apply -f /tmp/n8n-secret-$(N8N_NAMESPACE).yaml -n $(N8N_NAMESPACE)
	@rm -f /tmp/n8n-secret-$(N8N_NAMESPACE).yaml

.PHONY: _wait-cross-ready
_wait-cross-ready:
	@echo "🔷💡 Waiting for n8n to be ready..."
	@kubectl wait --for=condition=ready pod -l app=n8n --timeout=300s -n $(N8N_NAMESPACE)

# =============================================================================
# � AI MODEL DEPLOYMENT TARGETS
# =============================================================================

.PHONY: new-ollama-pod
new-ollama-pod: ## 🧠 AI Deploy new Ollama AI model pod (MODEL=llama3.1 SIZE=7b GPU=false REPLICAS=1)
	@echo "✅$(ROCKET) Deploying Ollama Model: ⚙️$(MODEL_FULL)"
	@echo "  ─Model:      ⚙️$(MODEL_FULL)"
	@echo "  ─Type:       ⚙️$(MODEL_TYPE) $(if $(filter vision,$(MODEL_TYPE)),$(VISION),$(BRAIN))"
	@echo "  ─Namespace:  ⚙️$(OLLAMA_NAMESPACE)"
	@echo "  ─Replicas:   ⚙️$(REPLICAS)"
	@echo "  ─GPU:        ⚙️$(GPU) $(if $(filter true,$(GPU)),$(GPU),)"
	@echo "  ─Resources:  🔷$(MODEL_CPU_REQUEST) CPU, $(MODEL_MEMORY_REQUEST) RAM"
	@echo ""
	@$(MAKE) _ensure-ollama-namespace
	@$(MAKE) _deploy-ollama-storage
	@$(MAKE) _deploy-ollama-config
	@$(MAKE) _deploy-ollama-model
	@$(MAKE) _wait-ollama-ready
	@echo "✅$(CHECK) Ollama model $(MODEL_FULL) deployed successfully!"
	@echo "🔷💡 Access URL: http://ollama-$(MODEL_NAME_SAFE).$(OLLAMA_NAMESPACE).svc.cluster.local:11434"

.PHONY: list-ollama-pods
list-ollama-pods: ## 🧠 AI List all deployed Ollama model pods with details
	@echo "$(BRAIN) Ollama Model Status Overview"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "$(BRAIN) AI Models in $(OLLAMA_NAMESPACE):"
	@kubectl get pods,services -l app=ollama -n $(OLLAMA_NAMESPACE) -o wide 2>/dev/null || echo "  ❌No Ollama models deployed"
	@echo ""
	@echo "⚙️Storage Usage:"
	@kubectl get pvc -l app=ollama -n $(OLLAMA_NAMESPACE) 2>/dev/null || echo "  ❌No storage allocated"

.PHONY: scale-ollama
scale-ollama: ## 🧠 AI Scale existing Ollama model deployment (MODEL=llama3.1 SIZE=7b REPLICAS=3)
	@echo "ℹ️$(ROCKET) Scaling Ollama Model: ⚙️$(MODEL_FULL)"
	@echo "  ─Target Replicas: ⚙️$(REPLICAS)"
	@kubectl scale deployment ollama-$(MODEL_NAME_SAFE) --replicas=$(REPLICAS) -n $(OLLAMA_NAMESPACE)
	@kubectl wait --for=condition=available deployment/ollama-$(MODEL_NAME_SAFE) --timeout=300s -n $(OLLAMA_NAMESPACE)
	@echo "✅$(CHECK) Model scaled to $(REPLICAS) replicas"

.PHONY: logs-ollama
logs-ollama: ## 🧠 AI View Ollama model logs (MODEL=llama3.1 SIZE=7b FOLLOW=false)
	@echo "ℹ️$(LOGS) Ollama $(MODEL_FULL) logs:"
	@if [ "$(FOLLOW)" = "true" ]; then \
		kubectl logs -f -l app=ollama,model=$(MODEL_NAME_SAFE) --tail=$(TAIL_LINES) -n $(OLLAMA_NAMESPACE); \
	else \
		kubectl logs -l app=ollama,model=$(MODEL_NAME_SAFE) --tail=$(TAIL_LINES) -n $(OLLAMA_NAMESPACE); \
	fi

.PHONY: test-ollama
test-ollama: ## 🧠 AI Test Ollama model with a simple prompt (MODEL=llama3.1 SIZE=7b)
	@echo "ℹ️💡 Testing Ollama Model: ⚙️$(MODEL_FULL)"
	@kubectl run ollama-test-$(MODEL_NAME_SAFE) --rm -i --tty --image=curlimages/curl --restart=Never -n $(OLLAMA_NAMESPACE) -- \
		sh -c 'curl -X POST http://ollama-$(MODEL_NAME_SAFE).$(OLLAMA_NAMESPACE).svc.cluster.local:11434/api/generate \
		-H "Content-Type: application/json" \
		-d "{\"model\":\"$(MODEL_FULL)\",\"prompt\":\"Hello! Please respond with a brief greeting.\",\"stream\":false}" \
		| grep -o "\"response\":\"[^\"]*\"" | sed "s/\"response\":\"//" | sed "s/\"$$//" || echo "Model test failed"'

.PHONY: cleanup-ollama
cleanup-ollama: ## 🧹 AI CLEANUP Remove specific Ollama model deployment (MODEL=llama3.1 SIZE=7b)
	@echo "⚙️🧹 Cleaning up Ollama Model: ❌$(MODEL_FULL)"
	@kubectl delete deployment ollama-$(MODEL_NAME_SAFE) -n $(OLLAMA_NAMESPACE) --ignore-not-found=true
	@kubectl delete service ollama-$(MODEL_NAME_SAFE) -n $(OLLAMA_NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) Ollama model $(MODEL_FULL) cleanup completed"

.PHONY: cleanup-all-ollama
cleanup-all-ollama: ## 🧹 AI CLEANUP Remove ALL Ollama models and storage
	@echo "❌⚠️ NUCLEAR OLLAMA CLEANUP - Removing ALL AI models!"
	@echo "⚙️⚠️ This will destroy all Ollama deployments and model storage!"
	@read -p "Are you absolutely sure? Type 'YES' to continue: " confirm && [ "$$confirm" = "YES" ] || exit 1
	@echo "❌🧹 Starting Ollama nuclear cleanup..."
	@kubectl delete namespace $(OLLAMA_NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) All Ollama models destroyed!"

.PHONY: show-model-catalog
show-model-catalog: ## 🧠 AI Display available model catalog with specifications
	@echo "$(BRAIN) Available Ollama Models"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "🗣️  Text Models:"
	@echo "  🔷llama3.1:7b     - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷llama3.1:8b     - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.7GB"
	@echo "  🔷llama3.1:70b    - CPU: 8 cores, RAM: 32Gi, ❌Size: ~39GB"
	@echo "  🔷mistral:7b      - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷gemma:2b        - CPU: 1 cores, RAM: 2Gi, ✅Size: ~1.4GB"
	@echo "  🔷gemma:7b        - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷phi3:3.8b       - CPU: 2 cores, RAM: 4Gi, ✅Size: ~2.3GB"
	@echo ""
	@echo "$(VISION) Vision Models:"
	@echo "  🔷llava:7b        - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷llava:13b       - CPU: 6 cores, RAM: 16Gi, ⚙️Size: ~7.3GB"
	@echo "  🔷llava:34b       - CPU: 8 cores, RAM: 32Gi, ❌Size: ~19GB"
	@echo "  🔷bakllava:7b     - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷moondream:1.8b  - CPU: 1 cores, RAM: 2Gi, ✅Size: ~1.4GB"
	@echo ""
	@echo "🔬 Specialized Models:"
	@echo "  🔷codellama:7b    - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷codellama:13b   - CPU: 6 cores, RAM: 16Gi, ⚙️Size: ~7.3GB"
	@echo "  🔷codellama:34b   - CPU: 8 cores, RAM: 32Gi, ❌Size: ~19GB"
	@echo "  🔷neural-chat:7b  - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo "  🔷starling-lm:7b  - CPU: 4 cores, RAM: 8Gi, ✅Size: ~4.1GB"
	@echo ""
	@echo "💡 Usage Examples:"
	@echo "  make new-ollama-pod MODEL=llama3.1 SIZE=7b      - Deploy text model"
	@echo "  make new-ollama-pod MODEL=llava SIZE=7b         - Deploy vision model"
	@echo "  make new-ollama-pod MODEL=codellama SIZE=13b     - Deploy code model"
	@echo "  make new-ollama-pod MODEL=mistral GPU=true      - Deploy with GPU"

# Internal Ollama deployment helpers
.PHONY: _ensure-ollama-namespace
_ensure-ollama-namespace:
	@echo "🔷💡 Ensuring Ollama namespace $(OLLAMA_NAMESPACE) exists..."
	@kubectl create namespace $(OLLAMA_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

.PHONY: _deploy-ollama-storage
_deploy-ollama-storage:
	@echo "🔷💡 Setting up persistent storage..."
	@if ! kubectl get pvc ollama-models-pvc -n $(OLLAMA_NAMESPACE) >/dev/null 2>&1; then \
		kubectl apply -f $(OLLAMA_DIR)/ollama-pvc.yaml -n $(OLLAMA_NAMESPACE); \
		echo "✅$(CHECK) Storage provisioned"; \
	else \
		echo "✅$(CHECK) Storage already exists"; \
	fi

.PHONY: _deploy-ollama-config
_deploy-ollama-config:
	@echo "🔷💡 Deploying Ollama configuration..."
	@kubectl apply -f $(OLLAMA_DIR)/ollama-configmap.yaml -n $(OLLAMA_NAMESPACE)

.PHONY: _deploy-ollama-model
_deploy-ollama-model:
	@echo "🔷💡 Creating deployment for $(MODEL_FULL)..."
	@cp $(OLLAMA_DIR)/ollama-deployment.yaml /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@cp $(OLLAMA_DIR)/ollama-service.yaml /tmp/ollama-service-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/MODEL_NAME/$(MODEL_NAME_SAFE)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/MODEL_FULL_NAME/$(MODEL_FULL)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/REPLICAS_COUNT/$(REPLICAS)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/CPU_REQUEST/$(MODEL_CPU_REQUEST)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/MEMORY_REQUEST/$(MODEL_MEMORY_REQUEST)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/CPU_LIMIT/$(MODEL_CPU_LIMIT)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/MEMORY_LIMIT/$(MODEL_MEMORY_LIMIT)/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml
	@sed -i 's/MODEL_NAME/$(MODEL_NAME_SAFE)/g' /tmp/ollama-service-$(MODEL_NAME_SAFE).yaml
	@if [ "$(GPU)" = "true" ]; then \
		echo "⚙️$(GPU) Adding GPU support..."; \
		sed -i 's/# GPU_PLACEHOLDER/        - name: nvidia.com\/gpu\n          value: "1"\n        env:\n        - name: NVIDIA_VISIBLE_DEVICES\n          value: "all"/g' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml; \
	else \
		sed -i '/# GPU_PLACEHOLDER/d' /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml; \
	fi
	@kubectl apply -f /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml -n $(OLLAMA_NAMESPACE)
	@kubectl apply -f /tmp/ollama-service-$(MODEL_NAME_SAFE).yaml -n $(OLLAMA_NAMESPACE)
	@rm -f /tmp/ollama-deployment-$(MODEL_NAME_SAFE).yaml /tmp/ollama-service-$(MODEL_NAME_SAFE).yaml

.PHONY: _wait-ollama-ready
_wait-ollama-ready:
	@echo "🔷💡 Waiting for $(MODEL_FULL) to be ready..."
	@case "$(MODEL_FULL)" in \
		*:2b*) echo "⚙️📊 Downloading ~1.4GB (est. 3-8 minutes)" ;; \
		*:3b*|*:3.8b*) echo "⚙️📊 Downloading ~2.3GB (est. 5-12 minutes)" ;; \
		*:7b*) echo "⚙️📊 Downloading ~4.1GB (est. 8-20 minutes)" ;; \
		*:8b*) echo "⚙️📊 Downloading ~4.7GB (est. 10-25 minutes)" ;; \
		*:13b*) echo "⚙️📊 Downloading ~7.3GB (est. 15-35 minutes)" ;; \
		*:34b*) echo "⚙️📊 Downloading ~19GB (est. 30-60 minutes)" ;; \
		*:70b*) echo "⚙️📊 Downloading ~39GB (est. 60-120 minutes)" ;; \
		*8x7b*) echo "⚙️📊 Downloading ~26GB (est. 45-90 minutes)" ;; \
		*) echo "⚙️📊 Downloading ~4-8GB (est. 10-30 minutes)" ;; \
	esac
	@echo "🔷💡 Monitor progress: make logs-ollama MODEL=$(MODEL) SIZE=$(SIZE) FOLLOW=true"
	@echo "🔷💡 Check status: make list-ollama-pods"
	@kubectl wait --for=condition=ready pod -l app=ollama,model=$(MODEL_NAME_SAFE) --timeout=7200s -n $(OLLAMA_NAMESPACE)

# =============================================================================
# �🧹 CLEANUP TARGETS
# =============================================================================

.PHONY: cleanup-postgres
cleanup-postgres: ## 🧹 CLEANUP Remove PostgreSQL deployment from specified namespace
	@echo "⚙️🧹 Cleaning up PostgreSQL in namespace: ❌$(NAMESPACE)"
	@kubectl delete -f $(POSTGRES_DIR)/ -n $(NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) PostgreSQL cleanup completed"

.PHONY: cleanup-n8n
cleanup-n8n: ## 🧹 CLEANUP Remove n8n deployment from specified namespace
	@echo "⚙️🧹 Cleaning up n8n in namespace: ❌$(NAMESPACE)"
	@kubectl delete -f $(N8N_DIR)/ -n $(NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) n8n cleanup completed"

.PHONY: cleanup-cross
cleanup-cross: ## 🧹 CLEANUP Remove cross-namespace n8n deployment and database resources
	@echo "⚙️🧹 Cleaning up cross-namespace deployment:"
	@echo "  ─n8n Namespace:     ❌$(N8N_NAMESPACE)"
	@echo "  ─Database Namespace: ❌$(DB_NAMESPACE)"
	@$(MAKE) _cleanup-cross-db
	@$(MAKE) cleanup-n8n NAMESPACE=$(N8N_NAMESPACE)
	@kubectl delete namespace $(N8N_NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) Cross-namespace cleanup completed"

.PHONY: _cleanup-cross-db
_cleanup-cross-db:
	@echo "🔷💡 Cleaning up database resources for $(N8N_NAMESPACE)..."
	@echo 'apiVersion: batch/v1' > /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo 'kind: Job' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo 'metadata:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '  name: db-cleanup-$(N8N_NAMESPACE)' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '  labels:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '    app: db-cleanup' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo 'spec:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '  backoffLimit: 2' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '  template:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '    spec:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '      restartPolicy: OnFailure' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '      containers:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '        - name: postgres-client' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '          image: postgres:16' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '          env:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '            - name: PGPASSWORD' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              value: "postgres123"' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '          command: ["/bin/bash", "-c"]' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '          args:' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '            - |' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              set -e' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              echo "Cleaning up database $(DB_NAME_SAFE)..."' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              if pg_isready -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -p 5432 -U admin; then' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '                psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c "DROP DATABASE IF EXISTS $(DB_NAME_SAFE);" || true' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '                psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c "DROP ROLE IF EXISTS $(DB_USER_SAFE);" || true' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '                echo "Database cleanup completed"' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              else' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '                echo "PostgreSQL not accessible, skipping cleanup"' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@echo '              fi' >> /tmp/db-cleanup-$(N8N_NAMESPACE).yaml
	@kubectl apply -f /tmp/db-cleanup-$(N8N_NAMESPACE).yaml -n $(N8N_NAMESPACE) 2>/dev/null || true
	@kubectl wait --for=condition=complete --timeout=60s job/db-cleanup-$(N8N_NAMESPACE) -n $(N8N_NAMESPACE) 2>/dev/null || true
	@kubectl delete job db-cleanup-$(N8N_NAMESPACE) -n $(N8N_NAMESPACE) --ignore-not-found=true
	@rm -f /tmp/db-cleanup-$(N8N_NAMESPACE).yaml

.PHONY: cleanup-all
cleanup-all: ## 🧹 CLEANUP Nuclear option - remove everything from all namespaces
	@echo "❌⚠️ NUCLEAR CLEANUP - Removing EVERYTHING!"
	@echo "⚙️⚠️ This will destroy all deployments in all namespaces!"
	@echo "  ❌• PostgreSQL database"
	@echo "  ❌• n8n workflows"
	@echo "  ❌• ALL Ollama AI models"
	@read -p "Are you absolutely sure? Type 'YES' to continue: " confirm && [ "$$confirm" = "YES" ] || exit 1
	@echo "❌🧹 Starting nuclear cleanup..."
	@$(MAKE) cleanup-cross
	@$(MAKE) cleanup-postgres NAMESPACE=$(DB_NAMESPACE)
	@kubectl delete namespace $(DB_NAMESPACE) --ignore-not-found=true
	@kubectl delete namespace $(OLLAMA_NAMESPACE) --ignore-not-found=true
	@echo "✅$(CHECK) Nuclear cleanup completed!"

# =============================================================================
# 📋 MONITORING TARGETS
# =============================================================================

.PHONY: logs-postgres
logs-postgres: ## 📋 MONITOR View PostgreSQL logs with optional follow
	@echo "ℹ️$(LOGS) PostgreSQL logs from namespace: ⚙️$(NAMESPACE)"
	@if [ "$(FOLLOW)" = "true" ]; then \
		kubectl logs -f -l app=postgres --tail=$(TAIL_LINES) -n $(NAMESPACE); \
	else \
		kubectl logs -l app=postgres --tail=$(TAIL_LINES) -n $(NAMESPACE); \
	fi

.PHONY: logs-n8n
logs-n8n: ## 📋 MONITOR View n8n logs with optional follow
	@echo "ℹ️$(LOGS) n8n logs from namespace: ⚙️$(NAMESPACE)"
	@if [ "$(FOLLOW)" = "true" ]; then \
		kubectl logs -f -l app=n8n --tail=$(TAIL_LINES) -n $(NAMESPACE); \
	else \
		kubectl logs -l app=n8n --tail=$(TAIL_LINES) -n $(NAMESPACE); \
	fi

.PHONY: status
status: ## 📋 MONITOR Show deployment status across all namespaces
	@echo "ℹ️💡 Deployment Status Overview"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "⚙️$(DATABASE) PostgreSQL Status:"
	@kubectl get pods,services -l app=postgres --all-namespaces -o wide 2>/dev/null || echo "  ❌No PostgreSQL deployments found"
	@echo ""
	@echo "⚙️$(ROBOT) n8n Status:"
	@kubectl get pods,services -l app=n8n --all-namespaces -o wide 2>/dev/null || echo "  ❌No n8n deployments found"
	@echo ""
	@echo "⚙️$(NETWORK) Namespaces:"
	@kubectl get namespaces -o wide

.PHONY: port-forward
port-forward: ## 📋 MONITOR Start configurable port-forwarding to any service
	@echo "✅$(NETWORK) Starting port-forward for service: ⚙️$(SERVICE)"
	@echo "🔷💡 Target: $(SERVICE) in namespace $(TARGET_NAMESPACE)"
	@echo "🔷💡 Mapping: localhost:$(PORT) → $(SERVICE):$(TARGET_PORT)"
	@echo "🔷💡 Access at: http://localhost:$(PORT)"
	@echo "⚙️⚠️ Press Ctrl+C to stop port-forwarding"
	@kubectl port-forward -n $(TARGET_NAMESPACE) service/$(SERVICE) $(PORT):$(TARGET_PORT)

.PHONY: port-forward-n8n
port-forward-n8n: ## 📋 MONITOR Quick port-forward to n8n service
	@$(MAKE) port-forward SERVICE=n8n-service TARGET_NAMESPACE=$(N8N_NAMESPACE) TARGET_PORT=5678 PORT=$(PORT)

.PHONY: port-forward-postgres
port-forward-postgres: ## 📋 MONITOR Quick port-forward to PostgreSQL service  
	@$(MAKE) port-forward SERVICE=postgres-service TARGET_NAMESPACE=$(DB_NAMESPACE) TARGET_PORT=5432 PORT=${POSTGRES_PORT}

.PHONY: port-forward-ollama
port-forward-ollama: ## 📋 MONITOR Quick port-forward to Ollama AI service
	@$(MAKE) port-forward SERVICE=ollama-service TARGET_NAMESPACE=$(OLLAMA_NAMESPACE) TARGET_PORT=11434 PORT=${OLLAMA_PORT}

# =============================================================================
# ⚙️ CONFIGURATION TARGETS
# =============================================================================

.PHONY: config-localhost
config-localhost: ## ⚙️ CONFIG Switch n8n configuration to localhost mode
	@echo "ℹ️$(CONFIG) Switching to localhost configuration in namespace: ⚙️$(NAMESPACE)"
	@kubectl patch configmap n8n-config -n $(NAMESPACE) --type='merge' -p='{"data":{"N8N_HOST":"localhost","N8N_PROTOCOL":"http","WEBHOOK_URL":"http://localhost:$(PORT)"}}'
	@kubectl rollout restart deployment/n8n -n $(NAMESPACE)
	@echo "✅$(CHECK) Configuration updated to localhost mode"

.PHONY: config-ingress
config-ingress: ## ⚙️ CONFIG Switch n8n configuration to ingress mode
	@echo "ℹ️$(CONFIG) Switching to ingress configuration in namespace: ⚙️$(NAMESPACE)"
	@kubectl patch configmap n8n-config -n $(NAMESPACE) --type='merge' -p='{"data":{"N8N_HOST":"0.0.0.0","N8N_PROTOCOL":"http","WEBHOOK_URL":"http://n8n.local"}}'
	@kubectl rollout restart deployment/n8n -n $(NAMESPACE)
	@echo "✅$(CHECK) Configuration updated to ingress mode"

.PHONY: debug-connection
debug-connection: ## ⚙️ CONFIG Test database connectivity from n8n namespace
	@echo "ℹ️💡 Testing database connection from ⚙️$(NAMESPACE)"
	@kubectl run debug-connection --rm -i --tty --image=postgres:16 --restart=Never -n $(NAMESPACE) -- \
		bash -c "PGPASSWORD=postgres123 psql -h postgres-service.$(DB_NAMESPACE).svc.cluster.local -U admin -d postgres -c '\l'"

.PHONY: setup-help
setup-help: ## ⚙️ CONFIG Display setup troubleshooting guide
	@echo "ℹ️💡 n8n Setup Troubleshooting Guide"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "⚙️⚠️ Common Issues and Solutions:"
	@echo ""
	@echo "1. Database Connection Issues:"
	@echo "   make debug-connection NAMESPACE=<namespace>"
	@echo "   🔷- Tests connectivity between n8n and PostgreSQL"
	@echo ""
	@echo "2. n8n Not Accessible:"
	@echo "   make config-localhost NAMESPACE=<namespace>"
	@echo "   🔷- Switches to localhost configuration"
	@echo "   make port-forward-n8n PORT=8080"
	@echo "   make port-forward SERVICE=postgres-service TARGET_NAMESPACE=database PORT=5432"
	@echo "   🔷- Start port-forwarding to access n8n"
	@echo ""
	@echo "3. Owner Registration Issues:"
	@echo "   🔷- Ensure WEBHOOK_URL matches your access method"
	@echo "   🔷- Use localhost configuration for port-forwarding"
	@echo "   🔷- Use ingress configuration for ingress access"
	@echo ""
	@echo "4. Check Logs:"
	@echo "   make logs-n8n NAMESPACE=<namespace> FOLLOW=true"
	@echo "   make logs-postgres NAMESPACE=<namespace>"
	@echo ""
	@echo "5. Reset Everything:"
	@echo "   make cleanup-all"
	@echo "   ❌⚠️ This will destroy all deployments!"

# =============================================================================
# ⚙️ UTILITY TARGETS
# =============================================================================

.PHONY: validate-env
validate-env: ## Validate environment and display current configuration
	@echo "ℹ️💡 Current Configuration:"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo "  🔷NAMESPACE:        ⚙️$(NAMESPACE)"
	@echo "  🔷DB_NAMESPACE:     ⚙️$(DB_NAMESPACE)"
	@echo "  🔷N8N_NAMESPACE:    ⚙️$(N8N_NAMESPACE)"
	@echo "  🔷OLLAMA_NAMESPACE: ⚙️$(OLLAMA_NAMESPACE)"
	@echo "  🔷PORT:             ⚙️$(PORT)"
	@echo "  🔷FOLLOW:           ⚙️$(FOLLOW)"
	@echo "  🔷TAIL_LINES:       ⚙️$(TAIL_LINES)"
	@echo "  🔷DB_NAME_SAFE:     ⚙️$(DB_NAME_SAFE)"
	@echo "  🔷DB_USER_SAFE:     ⚙️$(DB_USER_SAFE)"
	@echo ""
	@echo "$(BRAIN) AI Model Configuration:"
	@echo "  🔷MODEL:            ⚙️$(MODEL)"
	@echo "  🔷SIZE:             ⚙️$(SIZE)"
	@echo "  🔷MODEL_FULL:       ⚙️$(MODEL_FULL)"
	@echo "  🔷MODEL_NAME_SAFE:  ⚙️$(MODEL_NAME_SAFE)"
	@echo "  🔷MODEL_TYPE:       ⚙️$(MODEL_TYPE) $(if $(filter vision,$(MODEL_TYPE)),$(VISION),$(BRAIN))"
	@echo "  🔷GPU:              ⚙️$(GPU) $(if $(filter true,$(GPU)),$(GPU),)"
	@echo "  🔷REPLICAS:         ⚙️$(REPLICAS)"
	@echo "  🔷MODEL_NAME_SAFE:  ⚙️$(MODEL_NAME_SAFE)"
	@echo "  🔷MODEL_TYPE:       ⚙️$(MODEL_TYPE) $(if $(filter vision,$(MODEL_TYPE)),$(VISION),$(BRAIN))"
	@echo "  🔷GPU:              ⚙️$(GPU) $(if $(filter true,$(GPU)),$(GPU),)"
	@echo "  🔷REPLICAS:         ⚙️$(REPLICAS)"
	@echo "  🔷CPU_REQUEST:      ⚙️$(MODEL_CPU_REQUEST)"

# =============================================================================
# 📁 FILE BRIDGE OPERATIONS
# =============================================================================
# Advanced SSHFS/SFTP bridge platform for n8n file operations
# Provides secure, scalable file system bridges with enterprise features

# File bridge configuration
FILE_BRIDGE_NAMESPACE    := file-bridges
BRIDGE_NAME              ?= 
BRIDGE_HOST              ?= 
BRIDGE_PATH              ?= 
BRIDGE_USER              ?= bridge-user
BRIDGE_MODE              ?= read-write
BRIDGE_PORT              ?= auto

# Available access modes
VALID_MODES := read-only write-only read-write append-only

# Get next available SFTP port (2200-2299 range)
get-next-port = $(shell LAST_PORT=$$(kubectl get svc -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.items[*].spec.ports[?(@.name=="sftp")].port}' 2>/dev/null | tr ' ' '\n' | sort -n | tail -1); if [ -z "$$LAST_PORT" ] || [ "$$LAST_PORT" -lt 2200 ]; then echo 2200; else echo $$(($$LAST_PORT + 1)); fi)

# Validate bridge parameters
validate-bridge-params:
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make new-file-bridge BRIDGE_NAME=<name> BRIDGE_HOST=<host> BRIDGE_PATH=<path>"; \
		exit 1; \
	fi
	@if [ -z "$(BRIDGE_HOST)" ]; then \
		echo "❌ BRIDGE_HOST is required"; \
		echo "💡 Usage: make new-file-bridge BRIDGE_NAME=<name> BRIDGE_HOST=<host> BRIDGE_PATH=<path>"; \
		exit 1; \
	fi
	@if [ -z "$(BRIDGE_PATH)" ]; then \
		echo "❌ BRIDGE_PATH is required"; \
		echo "💡 Usage: make new-file-bridge BRIDGE_NAME=<name> BRIDGE_HOST=<host> BRIDGE_PATH=<path>"; \
		exit 1; \
	fi
	@if ! echo "$(VALID_MODES)" | grep -q "$(BRIDGE_MODE)"; then \
		echo "❌ Invalid BRIDGE_MODE: $(BRIDGE_MODE)"; \
		echo "💡 Valid modes: $(VALID_MODES)"; \
		exit 1; \
	fi

.PHONY: new-file-bridge
new-file-bridge: validate-bridge-params ## 📁 BRIDGE Create new SSHFS/SFTP file bridge
	@echo "📁 Creating File Bridge: $(BRIDGE_NAME)"
	@echo "═════════════════════════════════════════════════════════════════════════════════"
	
	# Ensure namespace exists
	@kubectl create namespace $(FILE_BRIDGE_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	
	# Generate SSH keys if not exists
	@if [ ! -d "file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)" ]; then \
		echo "🔑 Generating SSH keypair for bridge..."; \
		cd file_bridge_deployment && ./ssh-key-manager.sh generate $(BRIDGE_NAME); \
	fi
	
	# Deploy base configuration
	@echo "⚙️ Deploying bridge configuration..."
	@kubectl apply -f file_bridge_deployment/file-bridge-configmap.yaml
	
	# Create SSH secret
	@echo "🔐 Creating SSH secret..."
	@kubectl create secret generic file-bridge-ssh-$(BRIDGE_NAME) \
		-n $(FILE_BRIDGE_NAMESPACE) \
		--from-file=id_rsa=file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/id_rsa \
		--from-file=id_rsa.pub=file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/id_rsa.pub \
		--dry-run=client -o yaml | kubectl apply -f -
	
	# Deploy bridge with parameter substitution
	@echo "⚙️🚀 Deploying file bridge..."
	@SFTP_PORT=$$(if [ "$(BRIDGE_PORT)" = "auto" ]; then echo $(call get-next-port); else echo $(BRIDGE_PORT); fi); \
	sed \
	     -e "s/BRIDGE_NAME/$(BRIDGE_NAME)/g" \
	     -e "s/TARGET_HOST_VALUE/$(BRIDGE_HOST)/g" \
	     -e "s/SSH_USER_VALUE/$(BRIDGE_USER)/g" \
	     -e "s|REMOTE_PATH_VALUE|$(BRIDGE_PATH)|g" \
	     -e "s/ACCESS_MODE_VALUE/$(BRIDGE_MODE)/g" \
	     -e "s/SFTP_PORT_VALUE/$$SFTP_PORT/g" \
	     -e "s/SFTP_PORT/$$SFTP_PORT/g" \
	     file_bridge_deployment/file-bridge-deployment.yaml | kubectl apply -f -
	
	@echo ""
	@echo "✅ File Bridge '$(BRIDGE_NAME)' deployment initiated!"
	@echo ""
	@echo "🔷🔗 Bridge Configuration:"
	@echo "  📝 Name: $(BRIDGE_NAME)"
	@echo "  🖥️  Host: $(BRIDGE_HOST)"
	@echo "  📁 Path: $(BRIDGE_PATH)"
	@echo "  👤 User: $(BRIDGE_USER)"
	@echo "  🔒 Mode: $(BRIDGE_MODE)"
	@echo ""
	@echo "⚙️📋 Next Steps:"
	@echo "  1. Deploy SSH key: cd file_bridge_deployment && ./ssh-key-manager.sh deploy $(BRIDGE_NAME) $(BRIDGE_USER)@$(BRIDGE_HOST)"
	@echo "  2. Test connection: make test-file-bridge BRIDGE_NAME=$(BRIDGE_NAME)"
	@echo "  3. Monitor status: make status-file-bridge BRIDGE_NAME=$(BRIDGE_NAME)"

.PHONY: new-local-file-bridge
new-local-file-bridge: ## 📁 BRIDGE Create local file bridge with direct volume mount (no SSH)
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make new-local-file-bridge BRIDGE_NAME=<name> BRIDGE_PATH=<local-path>"; \
		exit 1; \
	fi
	@if [ -z "$(BRIDGE_PATH)" ]; then \
		echo "❌ BRIDGE_PATH is required"; \
		echo "💡 Usage: make new-local-file-bridge BRIDGE_NAME=<name> BRIDGE_PATH=<local-path>"; \
		exit 1; \
	fi
	@echo "📁 Creating Local File Bridge: $(BRIDGE_NAME)"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	
	# Ensure namespace exists
	@kubectl create namespace $(FILE_BRIDGE_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	
	# Generate SSH keys for SFTP access
	@if [ ! -d "file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)" ]; then \
		echo "🔑 Generating SSH keypair for SFTP access..."; \
		cd file_bridge_deployment && ./ssh-key-manager.sh generate $(BRIDGE_NAME); \
	fi
	
	# Deploy base configuration
	@echo "⚙️ Deploying bridge configuration..."
	@kubectl apply -f file_bridge_deployment/file-bridge-configmap.yaml
	
	# Create SSH secret for SFTP
	@echo "🔐 Creating SSH secret..."
	@kubectl create secret generic file-bridge-ssh-$(BRIDGE_NAME) \
		-n $(FILE_BRIDGE_NAMESPACE) \
		--from-file=id_rsa=file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/id_rsa \
		--from-file=id_rsa.pub=file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/id_rsa.pub \
		--dry-run=client -o yaml | kubectl apply -f -
	
	# Create local directory if it doesn't exist
	@echo "⚙️📁 Ensuring local directory exists: $(BRIDGE_PATH)"
	@EXPANDED_PATH=$$(echo "$(BRIDGE_PATH)" | sed 's|~|$(HOME)|g'); \
	mkdir -p "$$EXPANDED_PATH"; \
	chmod 755 "$$EXPANDED_PATH"
	
	# Deploy local bridge with parameter substitution (Lima-aware)
	@echo "⚙️🚀 Deploying local file bridge..."
	@SFTP_PORT=$$(if [ "$(BRIDGE_PORT)" = "auto" ]; then echo $(call get-next-port); else echo $(BRIDGE_PORT); fi); \
	NODE_NAME=$$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}'); \
	EXPANDED_PATH=$$(echo "$(BRIDGE_PATH)" | sed 's|~|$(HOME)|g'); \
	if kubectl get nodes -o yaml | grep -q "lima-rancher-desktop"; then \
		echo "🔧 Lima environment detected - adjusting host path..."; \
		HOST_PATH_MOUNT="/host_mnt$$EXPANDED_PATH"; \
	else \
		HOST_PATH_MOUNT="$$EXPANDED_PATH"; \
	fi; \
	sed \
	     -e "s/BRIDGE_NAME/$(BRIDGE_NAME)/g" \
	     -e "s|HOST_PATH_VALUE|$$HOST_PATH_MOUNT|g" \
	     -e "s/ACCESS_MODE_VALUE/$(BRIDGE_MODE)/g" \
	     -e "s/SFTP_PORT_VALUE/$$SFTP_PORT/g" \
	     -e "s/CONTAINER_PORT/$$SFTP_PORT/g" \
	     -e "s/SERVICE_PORT/$$SFTP_PORT/g" \
	     -e "s/NODE_NAME/$$NODE_NAME/g" \
	     file_bridge_deployment/file-bridge-local-deployment.yaml | kubectl apply -f -
	
	@echo ""
	@echo "✅ Local File Bridge '$(BRIDGE_NAME)' deployment initiated!"
	@echo ""
	@echo "🔷🔗 Bridge Configuration:"
	@echo "  📝 Name: $(BRIDGE_NAME)"
	@echo "  📁 Local Path: $(BRIDGE_PATH)"
	@echo "  🔒 Mode: $(BRIDGE_MODE)"
	@echo "  🚫 No SSH setup required!"
	@echo ""
	@echo "✅🎉 Ready to use immediately!"
	@echo "  📋 Check status: make status-file-bridge BRIDGE_NAME=$(BRIDGE_NAME)"
	@echo "  🔗 SFTP access: Use private key from file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/"

.PHONY: list-file-bridges
list-file-bridges: ## 📁 BRIDGE List all active file bridges with status
	@echo "📁 Active File Bridges"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@if ! kubectl get namespace $(FILE_BRIDGE_NAMESPACE) >/dev/null 2>&1; then \
		echo "⚠️ No file bridges namespace found"; \
		echo "💡 Create your first bridge: make new-file-bridge NAME=<name> HOST=<host> PATH=<path>"; \
		exit 0; \
	fi
	@if [ $$(kubectl get deployments -n $(FILE_BRIDGE_NAMESPACE) --no-headers 2>/dev/null | wc -l) -eq 0 ]; then \
		echo "⚠️ No file bridges deployed"; \
		echo "💡 Create your first bridge: make new-file-bridge NAME=<name> HOST=<host> PATH=<path>"; \
		exit 0; \
	fi
	@echo "📋 Bridge Name           Status    SFTP Port  Access Mode   Host"
	@echo "────────────────────────────────────────────────────────────────────────"
	@kubectl get deployments -n $(FILE_BRIDGE_NAMESPACE) -o custom-columns=\
NAME:.metadata.labels.bridge-name,\
READY:.status.readyReplicas,\
TOTAL:.status.replicas \
--no-headers 2>/dev/null | while read name ready total; do \
		if [ "$$ready" = "$$total" ] && [ "$$ready" != "<none>" ]; then \
			status="✅ Ready"; \
		else \
			status="❌ Not Ready"; \
		fi; \
		port=$$(kubectl get svc file-bridge-$$name -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || echo "N/A"); \
		mode=$$(kubectl get deployment file-bridge-$$name -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="ACCESS_MODE")].value}' 2>/dev/null || echo "N/A"); \
		host=$$(kubectl get deployment file-bridge-$$name -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.template.spec.initContainers[0].env[?(@.name=="TARGET_HOST")].value}' 2>/dev/null || echo "N/A"); \
		printf "%-20s %s  %-9s  %-12s  %s\n" "$$name" "$$status" "$$port" "$$mode" "$$host"; \
	done
	@echo ""
	@echo "💡 Use 'make status-file-bridge NAME=<name>' for detailed information"

.PHONY: status-file-bridge
status-file-bridge: ## 📁 BRIDGE Show detailed status of specific file bridge
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make status-file-bridge NAME=<bridge-name>"; \
		exit 1; \
	fi
	@echo "📁 Bridge Status: $(BRIDGE_NAME)"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	
	@if ! kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) >/dev/null 2>&1 && ! kubectl get deployment file-bridge-local-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) >/dev/null 2>&1; then \
		echo "❌ Bridge '$(BRIDGE_NAME)' not found"; \
		echo "💡 Available bridges:"; \
		make list-file-bridges 2>/dev/null || true; \
		exit 1; \
	fi
	
	# Determine bridge type and deployment name
	@if kubectl get deployment file-bridge-local-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) >/dev/null 2>&1; then \
		DEPLOYMENT_NAME="file-bridge-local-$(BRIDGE_NAME)"; \
		SERVICE_NAME="file-bridge-local-$(BRIDGE_NAME)"; \
		BRIDGE_TYPE="Local"; \
	else \
		DEPLOYMENT_NAME="file-bridge-$(BRIDGE_NAME)"; \
		SERVICE_NAME="file-bridge-$(BRIDGE_NAME)"; \
		BRIDGE_TYPE="Remote"; \
	fi; \
	echo "🔷🔗 Bridge Type: $$BRIDGE_TYPE"
	
	@echo "🔷🔗 Bridge Configuration:"
	@kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.template.spec.initContainers[0].env[*]}' | \
	jq -r 'select(.name=="TARGET_HOST") | "  🖥️  Host: \(.value)"' 2>/dev/null || \
	kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  🖥️  Host: {.spec.template.spec.initContainers[0].env[?(@.name=="TARGET_HOST")].value}{"\n"}'
	
	@kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  📁 Path: {.spec.template.spec.initContainers[0].env[?(@.name=="REMOTE_PATH")].value}{"\n"}'
	@kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  👤 User: {.spec.template.spec.initContainers[0].env[?(@.name=="SSH_USER")].value}{"\n"}'
	@kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  🔒 Mode: {.spec.template.spec.containers[0].env[?(@.name=="ACCESS_MODE")].value}{"\n"}'
	@kubectl get svc file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  🔌 SFTP Port: {.spec.ports[0].port}{"\n"}'
	
	@echo ""
	@echo "🔷📊 Runtime Status:"
	@kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='  📦 Replicas: {.status.readyReplicas}/{.status.replicas}{"\n"}'
	@echo "  🕐 Age: $$(kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) --no-headers | awk '{print $$5}')"
	
	@echo ""
	@echo "🔷🔍 Pod Status:"
	@kubectl get pods -n $(FILE_BRIDGE_NAMESPACE) -l bridge-name=$(BRIDGE_NAME) --no-headers | while read pod ready status restarts age; do \
		if [ "$$status" = "Running" ]; then \
			echo "  ✅ $$pod: $$status ($$ready ready, $$restarts restarts)"; \
		else \
			echo "  ❌ $$pod: $$status ($$ready ready, $$restarts restarts)"; \
		fi; \
	done
	
	@echo ""
	@echo "🔷🌐 Service Endpoints:"
	@echo "  📡 Internal SFTP: file-bridge-$(BRIDGE_NAME).$(FILE_BRIDGE_NAMESPACE).svc.cluster.local:$$(kubectl get svc file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.ports[0].port}')"
	@echo "  🔑 SSH Key: file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/"

.PHONY: test-file-bridge
test-file-bridge: ## 📁 BRIDGE Test file bridge connectivity and operations
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make test-file-bridge NAME=<bridge-name>"; \
		exit 1; \
	fi
	@echo "ℹ️🧪 Testing File Bridge: $(BRIDGE_NAME)"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	
	# Test SSH connectivity
	@echo "🔐 Testing SSH connectivity..."
	@cd file_bridge_deployment && ./ssh-key-manager.sh test $(BRIDGE_NAME)
	
	# Test Kubernetes deployment
	@echo ""
	@echo "⚙️☸️  Testing Kubernetes deployment..."
	@if kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) >/dev/null 2>&1; then \
		echo "✅ Deployment exists"; \
	else \
		echo "❌ Deployment not found"; \
		exit 1; \
	fi
	
	# Test pod readiness
	@echo "⚙️📦 Testing pod readiness..."
	@ready=$$(kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.status.readyReplicas}'); \
	total=$$(kubectl get deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.status.replicas}'); \
	if [ "$$ready" = "$$total" ] && [ "$$ready" != "" ]; then \
		echo "✅ Pod ready ($$ready/$$total)"; \
	else \
		echo "❌ Pod not ready ($$ready/$$total)"; \
		exit 1; \
	fi
	
	# Test SFTP service
	@echo "⚙️🔌 Testing SFTP service..."
	@port=$$(kubectl get svc file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.ports[0].port}'); \
	if [ "$$port" != "" ]; then \
		echo "✅ SFTP service available on port $$port"; \
	else \
		echo "❌ SFTP service not available"; \
		exit 1; \
	fi
	
	@echo ""
	@echo "✅🎉 Bridge '$(BRIDGE_NAME)' is fully operational!"
	@echo ""
	@echo "🔷🔗 Connection Details:"
	@port=$$(kubectl get svc file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) -o jsonpath='{.spec.ports[0].port}'); \
	echo "  📡 SFTP URL: sftp://file-bridge-$(BRIDGE_NAME).$(FILE_BRIDGE_NAMESPACE).svc.cluster.local:$$port"; \
	echo "  👤 Username: bridge-user"; \
	echo "  🔑 Private Key: file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/id_rsa"

.PHONY: logs-file-bridge
logs-file-bridge: ## 📁 BRIDGE View logs for specific file bridge
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make logs-file-bridge NAME=<bridge-name>"; \
		exit 1; \
	fi
	@echo "ℹ️📋 Bridge Logs: $(BRIDGE_NAME)"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@kubectl logs -n $(FILE_BRIDGE_NAMESPACE) -l bridge-name=$(BRIDGE_NAME) --all-containers=true --tail=$(TAIL_LINES) $(if $(filter true,$(FOLLOW)),-f)

.PHONY: cleanup-file-bridge
cleanup-file-bridge: ## 📁 BRIDGE Remove specific file bridge
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make cleanup-file-bridge NAME=<bridge-name>"; \
		exit 1; \
	fi
	@echo "❌🧹 Cleaning up File Bridge: $(BRIDGE_NAME)"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	
	@echo "⚙️⚠️  This will permanently delete:"
	@echo "  • Deployment: file-bridge-$(BRIDGE_NAME)"
	@echo "  • Service: file-bridge-$(BRIDGE_NAME)"
	@echo "  • Secret: file-bridge-ssh-$(BRIDGE_NAME)"
	@echo "  • SSH keys (optional)"
	@echo ""
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "⚙️🗑️  Removing Kubernetes resources..."; \
		kubectl delete deployment file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) --ignore-not-found; \
		kubectl delete service file-bridge-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) --ignore-not-found; \
		kubectl delete secret file-bridge-ssh-$(BRIDGE_NAME) -n $(FILE_BRIDGE_NAMESPACE) --ignore-not-found; \
		echo "✅ Kubernetes resources cleaned up"; \
		echo ""; \
		read -p "Also remove SSH keys? (y/N): " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			cd file_bridge_deployment && ./ssh-key-manager.sh cleanup $(BRIDGE_NAME); \
		else \
			echo "💡 SSH keys preserved in file_bridge_deployment/ssh-keys/$(BRIDGE_NAME)/"; \
		fi; \
	else \
		echo "💡 Cleanup cancelled"; \
	fi

.PHONY: cleanup-all-file-bridges
cleanup-all-file-bridges: ## 📁 BRIDGE Nuclear cleanup of all file bridges
	@echo "❌☢️  NUCLEAR FILE BRIDGE CLEANUP"
	@echo "─════════════════════════════════════════════════════════════════════════════════"
	@echo "❌⚠️  WARNING: This will destroy ALL file bridges!"
	@echo ""
	@echo "This will permanently delete:"
	@echo "  • All file bridge deployments"
	@echo "  • All SFTP services"
	@echo "  • All SSH secrets"
	@echo "  • Entire file-bridges namespace"
	@echo ""
	@read -p "Type 'DESTROY' to confirm: " confirm; \
	if [ "$$confirm" = "DESTROY" ]; then \
		echo "⚙️☢️  Initiating nuclear cleanup..."; \
		kubectl delete namespace $(FILE_BRIDGE_NAMESPACE) --ignore-not-found; \
		echo "✅ All file bridges destroyed"; \
		echo ""; \
		read -p "Also remove all SSH keys? (y/N): " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			rm -rf file_bridge_deployment/ssh-keys/*/; \
			echo "✅ All SSH keys removed"; \
		else \
			echo "💡 SSH keys preserved"; \
		fi; \
	else \
		echo "💡 Nuclear cleanup cancelled"; \
	fi

.PHONY: show-file-bridge-keys
show-file-bridge-keys: ## 📁 BRIDGE Show SSH key information for bridge
	@if [ -z "$(BRIDGE_NAME)" ]; then \
		echo "❌ BRIDGE_NAME is required"; \
		echo "💡 Usage: make show-file-bridge-keys NAME=<bridge-name>"; \
		exit 1; \
	fi
	@cd file_bridge_deployment && ./ssh-key-manager.sh show $(BRIDGE_NAME)

.PHONY: list-file-bridge-keys
list-file-bridge-keys: ## 📁 BRIDGE List all available SSH keypairs
	@cd file_bridge_deployment && ./ssh-key-manager.sh list

# =============================================================================
# 🌐 WEB INTERFACE TARGETS
# =============================================================================

# Web server configuration
WEB_PORT ?= 8000
WEB_ROOT ?= web

.PHONY: web-server
web-server: ## 🌐 WEB Start local web server for Starbridge Platform showcase
	@echo "🌟 Starting Starbridge Platform Web Interface..."
	@cd $(WEB_ROOT) && ./serve.sh --port $(WEB_PORT)

.PHONY: web-server-from-root
web-server-from-root: ## 🌐 WEB Start web server from project root (serves all files)
	@echo "🌟 Starting Starbridge Platform Web Server from project root..."
	@echo "🔗 Access at: http://localhost:$(WEB_PORT)/web/"
	@cd web && ./serve.sh --port $(WEB_PORT) --root ..

.PHONY: web-open
web-open: ## 🌐 WEB Open Starbridge Platform web interface in browser
	@echo "🌟 Opening Starbridge Platform Web Interface..."
	@echo "🔗 Starting server on port $(WEB_PORT)..."
	@if command -v xdg-open > /dev/null; then \
		(sleep 2 && xdg-open http://localhost:$(WEB_PORT)) & \
	elif command -v open > /dev/null; then \
		(sleep 2 && open http://localhost:$(WEB_PORT)) & \
	else \
		echo "💡 Please open http://localhost:$(WEB_PORT) in your browser"; \
	fi
	@$(MAKE) web-server WEB_PORT=$(WEB_PORT)

.PHONY: web-preview
web-preview: ## 🌐 WEB Preview web page in VS Code Simple Browser
	@echo "🌟 Opening Starbridge Platform in VS Code Simple Browser..."
	@echo "🔗 Starting server on port 8001..."
	@cd web && ./serve.sh --port 8001 &

# =============================================================================
# 🚀 PRODUCTION WEBSERVER DEPLOYMENT TARGETS
# =============================================================================

.PHONY: deploy-webserver
deploy-webserver: ## 🚀 WEBSERVER Deploy production nginx webserver to Kubernetes
	@echo "🌟 Deploying Starbridge Platform Production Webserver..."
	@kubectl apply -f webserver_deployment/webserver-pvc.yaml
	@kubectl apply -f webserver_deployment/webserver-configmap.yaml
	@kubectl apply -f webserver_deployment/webserver-deployment.yaml
	@kubectl apply -f webserver_deployment/webserver-service.yaml
	@kubectl apply -f webserver_deployment/webserver-ingress.yaml
	@echo "✅ Production webserver deployed!"
	@echo "💡 Run 'make sync-web-content' to upload web files"
	@echo "💡 Run 'make port-forward-webserver' to access locally"

.PHONY: sync-web-content
sync-web-content: ## 📁 WEBSERVER Sync web content to production webserver PVC
	@echo "🌟 Syncing web content to production webserver..."
	@./webserver_deployment/sync-web-content.sh
	@echo "✅ Web content synchronized!"

.PHONY: port-forward-webserver
port-forward-webserver: ## 🌐 WEBSERVER Port-forward to production webserver
	@echo "🌟 Starting port-forward to production webserver..."
	@echo "🔗 Access at: http://localhost:8080"
	@echo "🛑 Press Ctrl+C to stop"
	@kubectl port-forward -n starbridge-platform service/starbridge-webserver-service 8080:80

.PHONY: status-webserver
status-webserver: ## 📊 WEBSERVER Show production webserver status
	@echo "🌟 Starbridge Platform Production Webserver Status"
	@echo ""
	@echo "📦 Pods:"
	@kubectl get pods -n starbridge-platform -l app=starbridge-webserver --no-headers 2>/dev/null || echo "❌ No webserver pods found"
	@echo ""
	@echo "🔗 Service:"
	@kubectl get service starbridge-webserver-service -n starbridge-platform --no-headers 2>/dev/null || echo "❌ No webserver service found"
	@echo ""
	@echo "💾 PVC:"
	@kubectl get pvc starbridge-webserver-pvc -n starbridge-platform --no-headers 2>/dev/null || echo "❌ No webserver PVC found"
	@echo ""
	@echo "🌐 Ingress:"
	@kubectl get ingress starbridge-webserver-ingress -n starbridge-platform --no-headers 2>/dev/null || echo "❌ No webserver ingress found"

.PHONY: logs-webserver
logs-webserver: ## 📋 WEBSERVER Show production webserver logs
	@echo "🌟 Starbridge Platform Production Webserver Logs"
	@kubectl logs -n starbridge-platform -l app=starbridge-webserver --tail=50

.PHONY: restart-webserver
restart-webserver: ## 🔄 WEBSERVER Restart production webserver pods
	@echo "🌟 Restarting production webserver..."
	@kubectl rollout restart deployment/starbridge-webserver -n starbridge-platform
	@kubectl rollout status deployment/starbridge-webserver -n starbridge-platform
	@echo "✅ Webserver restarted!"

.PHONY: undeploy-webserver
undeploy-webserver: ## 🗑️ WEBSERVER Remove production webserver deployment
	@echo "🌟 Removing production webserver deployment..."
	@kubectl delete -f webserver_deployment/webserver-ingress.yaml --ignore-not-found=true
	@kubectl delete -f webserver_deployment/webserver-service.yaml --ignore-not-found=true
	@kubectl delete -f webserver_deployment/webserver-deployment.yaml --ignore-not-found=true
	@kubectl delete -f webserver_deployment/webserver-configmap.yaml --ignore-not-found=true
	@echo "⚠️  PVC preserved for data safety. Remove manually if needed:"
	@echo "    kubectl delete pvc starbridge-webserver-pvc -n starbridge-platform"
	@echo "✅ Production webserver undeployed!"

.PHONY: webserver-shell
webserver-shell: ## 🐚 WEBSERVER Access webserver container shell for debugging
	@echo "🌟 Accessing webserver container shell..."
	@kubectl exec -it -n starbridge-platform deployment/starbridge-webserver -- /bin/sh

# =============================================================================
# 🛡️ GUARDIAN NEXUS (SECURITY) - KEYCLOAK AUTHENTICATION SYSTEM
# =============================================================================

.PHONY: deploy-guardian-nexus
deploy-guardian-nexus: ## 🛡️ SECURITY Deploy Guardian Nexus (Keycloak) authentication system
	@echo "🛡️ Deploying Guardian Nexus - Central Security Command..."
	@kubectl apply -f security_nexus_deployment/security-nexus-namespace.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-secrets.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-pvc.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-postgres-config.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-postgres.yaml
	@echo "⏳ Waiting for PostgreSQL to be ready..."
	@kubectl wait --for=condition=ready pod -l app=guardian-nexus,component=database -n security-nexus --timeout=300s
	@kubectl apply -f security_nexus_deployment/guardian-nexus-keycloak-config.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-keycloak.yaml
	@kubectl apply -f security_nexus_deployment/guardian-nexus-ingress.yaml
	@echo "✅ Guardian Nexus deployed!"
	@echo "💡 Run 'make port-forward-guardian-nexus' to access admin console"
	@echo "💡 Admin credentials: admin / starbridge-admin-2025"

.PHONY: port-forward-guardian-nexus
port-forward-guardian-nexus: ## 🛡️ SECURITY Port-forward to Guardian Nexus admin console
	@echo "🛡️ Starting port-forward to Guardian Nexus..."
	@echo "🔗 Access at: http://localhost:8080/admin"
	@echo "🔑 Admin: admin / starbridge-admin-2025"
	@echo "🛑 Press Ctrl+C to stop"
	@kubectl port-forward -n security-nexus service/guardian-nexus-service 8080:8080

.PHONY: status-guardian-nexus
status-guardian-nexus: ## 🛡️ SECURITY Show Guardian Nexus status
	@echo "🛡️ Guardian Nexus - Central Security Command Status"
	@echo ""
	@echo "📦 Keycloak Pods:"
	@kubectl get pods -n security-nexus -l component=keycloak --no-headers 2>/dev/null || echo "❌ No Keycloak pods found"
	@echo ""
	@echo "📦 PostgreSQL Pods:"
	@kubectl get pods -n security-nexus -l component=database --no-headers 2>/dev/null || echo "❌ No PostgreSQL pods found"
	@echo ""
	@echo "🔗 Services:"
	@kubectl get service -n security-nexus --no-headers 2>/dev/null || echo "❌ No services found"
	@echo ""
	@echo "💾 PVCs:"
	@kubectl get pvc -n security-nexus --no-headers 2>/dev/null || echo "❌ No PVCs found"

.PHONY: logs-guardian-nexus
logs-guardian-nexus: ## 🛡️ SECURITY Show Guardian Nexus logs
	@echo "🛡️ Guardian Nexus Logs"
	@echo "📋 Keycloak Logs:"
	@kubectl logs -n security-nexus -l component=keycloak --tail=50
	@echo ""
	@echo "📋 PostgreSQL Logs:"
	@kubectl logs -n security-nexus -l component=database --tail=20

.PHONY: restart-guardian-nexus
restart-guardian-nexus: ## 🛡️ SECURITY Restart Guardian Nexus components
	@echo "🛡️ Restarting Guardian Nexus..."
	@kubectl rollout restart deployment/guardian-nexus-keycloak -n security-nexus
	@kubectl rollout restart deployment/guardian-nexus-postgres -n security-nexus
	@kubectl rollout status deployment/guardian-nexus-keycloak -n security-nexus
	@kubectl rollout status deployment/guardian-nexus-postgres -n security-nexus
	@echo "✅ Guardian Nexus restarted!"

.PHONY: undeploy-guardian-nexus
undeploy-guardian-nexus: ## 🛡️ SECURITY Remove Guardian Nexus deployment
	@echo "🛡️ Removing Guardian Nexus deployment..."
	@kubectl delete -f security_nexus_deployment/guardian-nexus-ingress.yaml --ignore-not-found=true
	@kubectl delete -f security_nexus_deployment/guardian-nexus-keycloak.yaml --ignore-not-found=true
	@kubectl delete -f security_nexus_deployment/guardian-nexus-postgres.yaml --ignore-not-found=true
	@kubectl delete -f security_nexus_deployment/guardian-nexus-keycloak-config.yaml --ignore-not-found=true
	@kubectl delete -f security_nexus_deployment/guardian-nexus-postgres-config.yaml --ignore-not-found=true
	@echo "⚠️  PVCs and secrets preserved for data safety. Remove manually if needed:"
	@echo "    kubectl delete pvc -n security-nexus --all"
	@echo "    kubectl delete secret -n security-nexus --all"
	@echo "    kubectl delete namespace security-nexus"
	@echo "✅ Guardian Nexus undeployed!"

.PHONY: sfrs-start-guardian-nexus
sfrs-start-guardian-nexus: ## 🛡️ SFRS Start Guardian Nexus session with Fleet Relay System
	@echo "🛡️ Starting SFRS session for Guardian Nexus..."
	@./sfrs.sh start guardian-nexus guardian-nexus-service security-nexus 8080

.PHONY: configure-workflow-nexus-oidc
configure-workflow-nexus-oidc: ## 🛡️ SECURITY Configure Workflow Nexus OIDC client in Keycloak
	@echo "🛡️ Configuring Workflow Nexus OIDC authentication..."
	@./security_nexus_deployment/configure-workflow-nexus-client.sh

.PHONY: deploy-workflow-nexus-secure
deploy-workflow-nexus-secure: ## 🛡️ SECURITY Deploy secure Workflow Nexus with OIDC integration
	@echo "🛡️ Deploying secure Workflow Nexus..."
	@kubectl apply -f n8n_deployment/workflow-nexus-security-config.yaml
	@kubectl apply -f n8n_deployment/workflow-nexus-oidc-secrets.yaml
	@kubectl apply -f n8n_deployment/workflow-nexus-secure-deployment.yaml
	@echo "✅ Secure Workflow Nexus deployed!"
	@echo "💡 Run 'make configure-workflow-nexus-oidc' to configure OIDC client"
	@echo "💡 Run 'make sfrs-start-workflow-nexus-secure' to access securely"

.PHONY: sfrs-start-workflow-nexus-secure
sfrs-start-workflow-nexus-secure: ## 🛡️ SFRS Start secure Workflow Nexus session
	@echo "🛡️ Starting SFRS session for secure Workflow Nexus..."
	@./sfrs.sh start workflow-nexus-secure workflow-nexus-service n8n-prod 5678

.PHONY: phase2-security-deployment
phase2-security-deployment: ## 🛡️ SECURITY Execute complete Phase 2 security deployment
	@echo "🛡️ Executing Phase 2 - Workflow Nexus Security Integration..."
	@echo "🚀 Step 1: Deploying secure Workflow Nexus..."
	@$(MAKE) deploy-workflow-nexus-secure
	@echo "🚀 Step 2: Configuring OIDC client..."
	@$(MAKE) configure-workflow-nexus-oidc
	@echo "🚀 Step 3: Starting secure SFRS sessions..."
	@$(MAKE) sfrs-start-workflow-nexus-secure
	@echo "✅ Phase 2 deployment complete!"
	@echo ""
	@echo "🎯 Access Points:"
	@echo "  🛡️  Guardian Nexus: http://localhost:8081/admin"
	@echo "  🤖  Workflow Nexus: http://localhost:5678 (secured)"
	@echo "  🐘  Data Vault: http://localhost:8082"
	@echo ""
	@echo "🔑 Default Credentials:"
	@echo "  Guardian Admin: admin / starbridge-admin-2025"
	@echo "  Platform Admin: admin / starbridge-admin-2025"

# =============================================================================
# 🌉 STARBRIDGE FLEET RELAY SYSTEM (SFRS) - MULTI-SESSION PORT-FORWARDING
# =============================================================================

.PHONY: sfrs-start-n8n
sfrs-start-n8n: ## 🌉 SFRS Start n8n session with Fleet Relay System
	@echo "🚀 Starting SFRS session for n8n..."
	@./sfrs.sh start n8n n8n-service n8n-prod 5678

.PHONY: sfrs-start-webserver
sfrs-start-webserver: ## 🌉 SFRS Start webserver session with Fleet Relay System
	@echo "🚀 Starting SFRS session for webserver..."
	@./sfrs.sh start webserver starbridge-webserver-service starbridge-platform 80

.PHONY: sfrs-start-postgres
sfrs-start-postgres: ## 🌉 SFRS Start PostgreSQL session with Fleet Relay System
	@echo "🚀 Starting SFRS session for PostgreSQL..."
	@./sfrs.sh start postgres postgres-service database 5432

.PHONY: sfrs-start-fleet
sfrs-start-fleet: ## 🌉 SFRS Start complete fleet (n8n + webserver + postgres)
	@echo "🚀 Deploying Starbridge Fleet Relay System..."
	@echo "🌟 Starting n8n session..."
	@./sfrs.sh start n8n n8n-service n8n-prod 5678 || true
	@echo "🌟 Starting webserver session..."
	@./sfrs.sh start webserver starbridge-webserver-service starbridge-platform 80 || true
	@echo "🌟 Starting PostgreSQL session..."
	@./sfrs.sh start postgres postgres-service database 5432 || true
	@echo "✅ Fleet deployment complete!"
	@./sfrs.sh list

.PHONY: sfrs-list
sfrs-list: ## 🌉 SFRS List all active sessions
	@./sfrs.sh list

.PHONY: sfrs-stop
sfrs-stop: ## 🌉 SFRS Stop specific session (usage: make sfrs-stop SESSION=n8n)
	@if [ -z "$(SESSION)" ]; then \
		echo "❌ Usage: make sfrs-stop SESSION=<session_name>"; \
		echo "💡 Available sessions:"; \
		./sfrs.sh list; \
	else \
		./sfrs.sh stop $(SESSION); \
	fi

.PHONY: sfrs-stop-all
sfrs-stop-all: ## 🌉 SFRS Stop all active sessions
	@./sfrs.sh stop-all

# ═══════════════════════════════════════════════════════════════
# 🧠 NEURAL NEXUS - AI MODEL DEPLOYMENT AUTOMATION
# ═══════════════════════════════════════════════════════════════

.PHONY: deploy-neural-nexus-model
deploy-neural-nexus-model: ## 🧠 Deploy Neural Nexus AI model from catalog (usage: make deploy-neural-nexus-model MODEL=llama31-7b NAMESPACE=neural-nexus-dev MODE=dev)
	@if [ -z "$(MODEL)" ]; then \
		echo "❌ MODEL parameter required"; \
		echo "💡 Available models:"; \
		$(MAKE) list-neural-nexus-models; \
	elif [ -z "$(NAMESPACE)" ]; then \
		echo "❌ NAMESPACE parameter required"; \
		echo "💡 Usage: make deploy-neural-nexus-model MODEL=llama31-7b NAMESPACE=neural-nexus-dev MODE=dev"; \
	else \
		$(MAKE) _deploy-neural-model MODEL=$(MODEL) NAMESPACE=$(NAMESPACE) MODE=$(MODE); \
	fi

.PHONY: _deploy-neural-model
_deploy-neural-model:
	@echo "🧠 Deploying Neural Nexus model from catalog..."
	@$(eval MODEL_SPEC := $(MODEL_$(shell echo $(MODEL) | tr '[:lower:]' '[:upper:]' | tr '-' '_')))
	@if [ -z "$(MODEL_SPEC)" ]; then \
		echo "❌ Unknown model: $(MODEL)"; \
		echo "💡 Available models:"; \
		$(MAKE) list-neural-nexus-models; \
		exit 1; \
	fi
	@$(eval MODEL_FULL := $(word 1,$(subst :, ,$(MODEL_SPEC))))
	@$(eval MODEL_SIZE := $(word 2,$(subst :, ,$(MODEL_SPEC))))
	@$(eval CPU_REQ := $(word 3,$(subst :, ,$(MODEL_SPEC))))
	@$(eval MEM_REQ := $(word 4,$(subst :, ,$(MODEL_SPEC))))
	@$(eval CPU_LIM := $(word 5,$(subst :, ,$(MODEL_SPEC))))
	@$(eval MEM_LIM := $(word 6,$(subst :, ,$(MODEL_SPEC))))
	@$(eval MODEL_TYPE := $(word 7,$(subst :, ,$(MODEL_SPEC))))
	@echo "Model: $(MODEL_FULL):$(MODEL_SIZE)"
	@echo "Type: $(MODEL_TYPE)"
	@echo "Resources: $(CPU_REQ)CPU/$(MEM_REQ)GB → $(CPU_LIM)CPU/$(MEM_LIM)GB"
	@echo "Namespace: $(NAMESPACE)"
	@echo "Mode: $(MODE)"
	@echo ""
	@echo "🚀 Generating deployment manifest..."
	@sed -e 's/$${MODEL_NAME}/$(MODEL)/g' \
		-e 's/$${MODEL_FULL_NAME}/$(MODEL_FULL):$(MODEL_SIZE)/g' \
		-e 's/$${MODEL_TYPE}/$(MODEL_TYPE)/g' \
		-e 's/$${NAMESPACE}/$(NAMESPACE)/g' \
		-e 's/$${MODE}/$(MODE)/g' \
		-e 's/$${REPLICAS_COUNT}/1/g' \
		-e 's/$${CPU_REQUEST}/$(CPU_REQ)/g' \
		-e 's/$${MEMORY_REQUEST}/$(MEM_REQ)/g' \
		-e 's/$${CPU_LIMIT}/$(CPU_LIM)/g' \
		-e 's/$${MEMORY_LIMIT}/$(MEM_LIM)/g' \
		neural_nexus_deployment/neural-nexus-model-template.yaml | kubectl apply -f - -n $(NAMESPACE)
	@echo "✅ Neural Nexus model deployment initiated!"
	@echo "💡 Monitor progress: kubectl logs -n $(NAMESPACE) -l model=$(MODEL) -f"

.PHONY: list-neural-nexus-models
list-neural-nexus-models: ## 🧠 List available Neural Nexus AI models from catalog
	@echo "🧠 Neural Nexus AI Model Catalog"
	@echo "════════════════════════════════"
	@echo "📋 Text Models:"
	@echo "  llama31-7b     - Llama 3.1 7B (General text, 4GB)"
	@echo "  llama31-8b     - Llama 3.1 8B (General text, 5GB)"
	@echo "  llama31-70b    - Llama 3.1 70B (Advanced text, 39GB)"
	@echo "  mistral-7b     - Mistral 7B (Efficient text, 4GB)"
	@echo "  phi3-3b        - Phi3 3.8B (Compact text, 2GB)"
	@echo "  gemma-2b       - Gemma 2B (Ultra-compact, 1GB)"
	@echo "  gemma-7b       - Gemma 7B (Balanced text, 4GB)"
	@echo ""
	@echo "💻 Code Models:"
	@echo "  codellama-7b   - CodeLlama 7B (Code generation, 4GB)"
	@echo "  codellama-13b  - CodeLlama 13B (Advanced code, 7GB)"
	@echo "  codellama-34b  - CodeLlama 34B (Expert code, 19GB)"
	@echo ""
	@echo "👁️ Vision Models:"
	@echo "  llava-7b       - LLaVA 7B (Image + text, 4GB)"
	@echo "  llava-13b      - LLaVA 13B (Advanced vision, 7GB)"
	@echo "  llava-34b      - LLaVA 34B (Expert vision, 19GB)"
	@echo "  moondream-2b   - Moondream 1.8B (Compact vision, 1GB)"
	@echo ""
	@echo "🧠 Specialized Models:"
	@echo "  neural-7b      - Neural Chat 7B (Conversational)"
	@echo "  starling-7b    - Starling 7B (Reasoning)"
	@echo "  dolphin-8x7b   - Dolphin Mixtral 8x7B (Expert)"
	@echo ""
	@echo "💡 Usage: make deploy-neural-nexus-model MODEL=<model> NAMESPACE=<ns> MODE=<mode>"

.PHONY: sfrs-show
sfrs-show: ## 🌉 SFRS Show session details (usage: make sfrs-show SESSION=n8n)
	@if [ -z "$(SESSION)" ]; then \
		echo "❌ Usage: make sfrs-show SESSION=<session_name>"; \
		echo "💡 Available sessions:"; \
		./sfrs.sh list; \
	else \
		./sfrs.sh show $(SESSION); \
	fi

.PHONY: sfrs-init
sfrs-init: ## 🌉 SFRS Initialize Fleet Relay System
	@./sfrs.sh init

# =============================================================================
# 🔧 CONFIGURATION AND VALIDATION TARGETS  
# =============================================================================

.PHONY: validate-environment
validate-environment: ## ⚙️ CONFIG Validate current environment and show configuration
	@echo "✅ Validating Starbridge Platform Environment"
	@echo "  🔷MEMORY_REQUEST:   ⚙️$(MODEL_MEMORY_REQUEST)"
	@echo "  🔷CPU_LIMIT:        ⚙️$(MODEL_CPU_LIMIT)"
	@echo "  🔷MEMORY_LIMIT:     ⚙️$(MODEL_MEMORY_LIMIT)"
	@echo ""
	@echo "✅$(CHECK) Environment validation completed"