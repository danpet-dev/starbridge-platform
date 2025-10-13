<div align="center"- **🧠 Neural Nexus** - Ollama-powered AI model deployment with GPU support
- **🛡️ Guardian Nexus** - Keycloak OIDC security and role-based access control
- **🔐 Vault Nexus** - HashiCorp Vault for enterprise secret management (optional)
- **📡 Starbridge Beacon** - Web interface and service monitoring <img src="assets/logo-starbridge-platform.jpeg" alt="Starbridge Platform Logo" width="500"/>
  
  # **Starbridge Platform**

  > *"Seamlessly connecting workflows across the digital frontier"* 🖖
</div>

---

## 🎯 What is the Starbridge Platform?

**Starbridge Platform** is a comprehensive Kubernetes service architecture, designed to transform your infrastructure into an enterprise-grade workflow orchestration system. Built specifically for **Workflow Nexus (n8n)**, **Data Vault (PostgreSQL)**, **Neural Nexus (AI models)**, **Guardian Nexus (security)**, and **secure File Bridge services**.

### **🚀 Service Architecture**

- **🌉 File Bridge** - Transform local directories into secure SFTP endpoints
- **🤖 Workflow Nexus** - Complete n8n automation with dual-mode deployment  
- **🐘 Data Vault** - Cross-namespace PostgreSQL database services
- **🧠 Neural Nexus** - Ollama-powered AI model deployment with GPU support
- **�️ Guardian Nexus** - Keycloak OIDC security and role-based access control
- **📡 Starbridge Beacon** - Web interface and service monitoring
- **⚙️ Cross-Namespace Operations** - Enterprise-scale service isolation

---

## 🛠️ Quick Start

### **Prerequisites**
- Kubernetes cluster (Rancher Desktop as example for local development)
- `kubectl` configured
- `make` installed

### **🚀 Ultra-Quick Start (30 seconds to running platform)**
```bash
# 1. Deploy complete development environment
make fresh-dev-auto

# 2. Start n8n in background
make start-n8n-port-forward

# 3. Access n8n
open http://localhost:5678
```

### **📂 File Operations Made Easy**
```bash
# Create bridge and copy files in one workflow
make new-local-file-bridge BRIDGE_NAME=data BRIDGE_PATH=~/mydata
./bridge-copy.sh to data ~/important-file.csv
./bridge-copy.sh ls data  # Verify files are there
```

### **🚀 One-Command Deployment**
```bash
# Complete fresh development deployment (automated)
make fresh-dev-auto

# Interactive deployment with port forwarding
make fresh-dev-deployment

# Manual deployment steps
make deploy-dev
make start-n8n-port-forward
make start-postgres-port-forward
```

### **📂 File Bridge Copy Operations**
```bash
# Copy files to bridge (script method)
./bridge-copy.sh to starbridge-transfer ~/myfile.txt
./bridge-copy.sh to starbridge-transfer ~/myfolder/ /data/input/

# Copy files from bridge
./bridge-copy.sh from starbridge-transfer /data/output.txt ~/downloads/

# List bridge contents
./bridge-copy.sh ls starbridge-transfer

# Copy via Makefile
make copy-to-bridge BRIDGE_NAME=starbridge-transfer SOURCE=~/myfile.txt
make ls-bridge BRIDGE_NAME=starbridge-transfer
```

### **🔗 Background Port-Forward Management**
```bash
# Start services in background
make start-n8n-port-forward          # n8n at http://localhost:5678
make start-postgres-port-forward     # PostgreSQL at localhost:5432
make start-vault-port-forward        # Vault at http://localhost:8200

# Management commands
make list-port-forwards              # Show all active port forwards
make stop-port-forward PORT=5678     # Stop specific port forward
make stop-all-port-forwards          # Stop all port forwards
```

---

## 📋 Platform Components

| Component | Purpose | Status |
|-----------|---------|--------|
| **File Bridges** | Secure SFTP file access + Copy operations | ✅ Production Ready |
| **Workflow Nexus (n8n)** | Workflow automation with background port-forward | ✅ Production Ready |
| **Stellar Core Database** | PostgreSQL services (cross-namespace) | ✅ Production Ready |
| **Neural Nexus (Ollama)** | LLM model deployment | ✅ Production Ready |
| **Guardian Nexus (Keycloak)** | OIDC authentication | ✅ Production Ready |
| **Vault Nexus (HashiCorp)** | Enterprise secret management | ✅ Production Ready |
| **Port-Forward Management** | Background service access | 🆕 **NEW** Production Ready |
| **File Copy System** | Host ↔ Bridge file operations | 🆕 **NEW** Production Ready |
| **One-Command Deployment** | Automated platform setup | 🆕 **NEW** Production Ready |

---

## 🎮 Management Commands

### **� Platform Deployment**
```bash
make fresh-dev-auto                       # Complete automated deployment
make fresh-dev-deployment                 # Interactive deployment + port forward
make deploy-dev                           # Deploy development environment
make deploy-prod                          # Deploy production environment
make nuclear-clean                        # Complete platform reset
```

### **🔗 Port-Forward Management**
```bash
make start-n8n-port-forward              # Start n8n in background (port 5678)
make start-postgres-port-forward         # Start PostgreSQL in background (port 5432)
make start-vault-port-forward            # Start Vault in background (port 8200)
make list-port-forwards                  # Show all active port forwards
make stop-port-forward PORT=5678         # Stop specific port forward
make stop-all-port-forwards              # Stop all port forwards
```

### **📂 File Bridge Operations**
```bash
make list-file-bridges                    # List all bridges
make new-local-file-bridge BRIDGE_NAME=data BRIDGE_PATH=~/data # Create local bridge
make copy-to-bridge BRIDGE_NAME=data SOURCE=~/file.txt        # Copy to bridge
make copy-from-bridge BRIDGE_NAME=data SOURCE=/data/output.txt # Copy from bridge
make ls-bridge BRIDGE_NAME=data          # List bridge contents
./bridge-copy.sh list                    # Show available bridges (script)
./bridge-copy.sh to data ~/myfile.txt    # Copy via script (recommended)
```

### **🤖 Workflow Nexus (n8n) Operations**
```bash
make workflow-nexus-port-forward         # Direct n8n port forward
make deploy-workflow-nexus-dev           # Deploy n8n development
make logs-workflow-nexus                 # View n8n logs
```

### **🔐 Vault Secret Management**
```bash
make deploy-vault-nexus                   # Deploy Vault Nexus
make vault-init                           # Initialize Vault
make vault-setup                          # Configure policies
make vault-status                         # Check Vault health
```

### **🧠 Neural Nexus (AI) Operations**
```bash
make show-model-catalog                   # Available models
make new-ollama-pod MODEL=llava          # Deploy vision model
make list-ollama-pods                     # List deployments
```

---

## 🔗 Integration Example: n8n + File Bridge

### **1. Quick Start - Complete Setup**
```bash
# Deploy everything with one command
make fresh-dev-auto

# Start services in background
make start-n8n-port-forward
```

### **2. File Bridge + Copy Operations**
```bash
# Create file bridge
make new-local-file-bridge BRIDGE_NAME=workflows BRIDGE_PATH=~/n8n-data

# Copy files to bridge
./bridge-copy.sh to workflows ~/mydata.csv /data/input/

# List files in bridge
./bridge-copy.sh ls workflows
```

### **3. Configure n8n SFTP Node**
```json
{
  "host": "file-bridge-workflows.file-bridges.svc.cluster.local",
  "port": 2202,
  "username": "bridge-user",
  "path": "/data/input/"
}
```

### **4. Access Files in Workflows**
- **n8n UI**: http://localhost:5678 (via background port-forward)
- **Files available**: `/data/input/`, `/data/output/`, etc.
- **Copy results back**: `./bridge-copy.sh from workflows /data/output/ ~/results/`

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   n8n Workflows │────│  File Bridges   │────│   Local Files   │
│   (n8n-prod)    │    │ (file-bridges)  │    │  (/your/data)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   (database)    │
                    └─────────────────┘
```

---

## � New Features (Genesis Architecture v2.0)

### **🚀 One-Command Deployment**
Deploy the entire development environment with a single command:
```bash
make fresh-dev-auto  # Fully automated: nuclear-clean → deploy-dev → file-bridge
```

### **🔗 Background Port-Forward Management**
Professional port-forward management with PID tracking:
```bash
make start-n8n-port-forward        # n8n in background
make list-port-forwards            # Show all active forwards
make stop-all-port-forwards        # Clean shutdown
```

### **📂 Advanced File Bridge Operations**
Intelligent file copy system with both Makefile and script interfaces:
```bash
# Smart copy script (recommended)
./bridge-copy.sh to starbridge-transfer ~/data/ /data/input/
./bridge-copy.sh from starbridge-transfer /data/results/ ~/output/

# Makefile integration
make copy-to-bridge BRIDGE_NAME=data SOURCE=~/file.txt DEST=/data/
```

### **🏗️ Service Redesignation**
Clean enterprise naming with backward compatibility:
- **Stellar Core Database** (formerly data_vault_deployment)
- **Workflow Nexus** (n8n with enhanced configuration)
- **Background Process Management** (PID tracking and cleanup)

---

## �🌟 Why "Starbridge"?

- **Star** - Reaches for the stars in automation excellence
- **Bridge** - Connects disparate systems seamlessly
- **Platform** - Foundation for enterprise workflows
- **🖖 Star Trek Inspiration** - Built for exploration and discovery

---

## 📚 Documentation

- **[File Bridge Module](file_bridge_deployment/README.md)** - Complete file bridge documentation
- **[Workflow Nexus Deployment](workflow_nexus_deployment/README.md)** - n8n setup and configuration
- **[Neural Nexus Deployment](neural_nexus_deployment/README.md)** - AI model deployment guide
- **[Guardian Nexus Security](guardian_nexus_deployment/README.md)** - Authentication and authorization
- **[Vault Nexus Security](vault_nexus_deployment/README.md)** - Enterprise secret management
- **[Stellar Core Database](stellar_core_database_deployment/README.md)** - PostgreSQL database services
- **[Starbridge Beacon Web](starbridge_beacon_deployment/README.md)** - Web interface and monitoring

---

## ⚠️ Known Limitations & Requirements

### **Prerequisites:**
- **Kubernetes cluster** (v1.20+ recommended)
- **kubectl** configured and working
- **make** installed on your system
- **Persistent storage** available for databases and file services

### **Current Limitations:**
- **Single-cluster design** - Cross-cluster deployments not yet supported
- **Manual secret management** - Automated secret rotation not implemented
- **Basic monitoring** - Advanced observability features planned for future releases
- **Development focus** - Production hardening is ongoing

### **Resource Requirements:**
- **Minimum**: 4 CPU cores, 8GB RAM, 50GB storage
- **Recommended**: 8 CPU cores, 16GB RAM, 200GB storage
- **Production**: Scale according to workload demands

### **Supported Platforms:**
- ✅ **Linux** (primary development platform)
- ✅ **macOS** (tested with Rancher Desktop)
- ⚠️ **Windows** (may require WSL2 for best compatibility)

---

## 🖖 About the Star Trek Inspiration

The Starbridge Platform draws inspiration from **Star Trek's** vision of exploration, cooperation, and technological advancement. The naming conventions (Nexus, Bridge, Beacon, Guardian) reflect the series' optimistic view of technology as a tool for connection and progress rather than conflict.

- **"Starbridge"** represents the connections we build across digital systems
- **Service names** are inspired by Star Trek's collaborative technology concepts
- **🖖 "Live long and prosper"** embodies our commitment to sustainable, long-term platform solutions

This is a tribute to Star Trek's inspiring vision of the future, not a military simulation.

---

## 🤝 Contributing

Built with love for the DevOps community. Contributions welcome!

**Live long and prosper!** 🖖

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### What this means for you:
- ✅ **Free to use** for personal and commercial projects
- ✅ **Modify and distribute** as needed
- ✅ **No royalties or fees** required
- ✅ **Enterprise-friendly** licensing

The only requirement is to **include the original copyright notice** when redistributing.

---

*Starbridge Platform - Where enterprise meets automation*