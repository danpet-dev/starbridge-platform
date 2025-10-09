<div align="center">
  <img src="../assets/logo-starbridge-platform.jpeg" alt="Starbridge Platform Logo" width="300"/>
</div>

# � File Bridge - Genesis Fleet Command

**"Enterprise File Bridge Automation for Kubernetes Workflows"**

## 🎯 Mission Statement

Seamlessly connecting workflows across the digital frontier - transform your local file systems into enterprise-grade SFTP services accessible from Workflow Nexus and other fleet services, with military-grade security, enterprise scalability, and fleet-level automation.

Part of **Admiral E.C. Copilot's Genesis Architecture v2.0.0** - the comprehensive Starbridge Platform fleet deployment system.

## 🚀 Features

### **🔐 Advanced Security**
- **Unique SSH keypairs** per bridge for maximum security
- **Custom SFTP ports** (auto-assigned 2200-2299 range)
- **Configurable access modes** (read-only, write-only, read-write, append-only)
- **Network isolation** and connection validation

### **📁 Flexible File Operations**
- **Multiple concurrent bridges** for different purposes
- **Remote folder mounting** via SSHFS with any host
- **Permission synchronization** and health monitoring
- **Bandwidth control** and transfer optimization

### **🎛️ Enterprise Management**
- **Automated SSH key deployment** 
- **Real-time connection monitoring**
- **Comprehensive logging** and status reporting
- **One-command deployment** and cleanup

## 🎯 Quick Start

```bash
# Deploy input bridge (write-only for n8n uploads)
make new-file-bridge NAME=n8n-input HOST=fileserver.local PATH=/data/input MODE=write-only

# Deploy output bridge (read-write for processing)  
make new-file-bridge NAME=n8n-output HOST=fileserver.local PATH=/data/output MODE=read-write

# Deploy read-only data source
make new-file-bridge NAME=source-data HOST=nas.local PATH=/archives MODE=read-only

# Monitor all bridges
make list-file-bridges

# Test connectivity
make test-file-bridge NAME=n8n-input
```

## 📊 Bridge Types & Use Cases

### **📤 Input Bridges (write-only)**
Perfect for:
- n8n workflow outputs
- File uploads from workflows  
- Data collection endpoints
- Log aggregation

### **📥 Output Bridges (read-only)**
Perfect for:
- Source data for workflows
- Configuration files
- Static assets and templates
- Archive access

### **🔄 Processing Bridges (read-write)**
Perfect for:
- Temporary processing space
- File transformation workflows
- Staging areas
- Working directories

### **📝 Audit Bridges (append-only)**
Perfect for:
- Audit logs
- Event streams
- Monitoring data
- Compliance records

## 🔗 n8n Integration

Each bridge exposes an SFTP service accessible via:
```
sftp://file-bridge-{NAME}.file-bridges.svc.cluster.local:{PORT}
```

### **Example n8n SFTP Node Configuration:**
```json
{
  "host": "file-bridge-input.file-bridges.svc.cluster.local",
  "port": 2201,
  "username": "bridge-user", 
  "authentication": "privateKey",
  "privateKey": "{{$credentials.bridgeSSHKey}}"
}
```

## 🎮 Management Commands

### **🚀 Deployment:**
```bash
make new-file-bridge NAME=<name> HOST=<host> PATH=<path> MODE=<mode> [PORT=<port>]
```

### **📋 Monitoring:**
```bash
make list-file-bridges              # List all bridges with status
make status-file-bridge NAME=<name> # Detailed bridge information  
make logs-file-bridge NAME=<name>   # View bridge logs
make test-file-bridge NAME=<name>   # Test connectivity
```

### **🔧 Maintenance:**
```bash
make show-ssh-config NAME=<name>    # Display SSH configuration
make regenerate-keys NAME=<name>    # Generate new SSH keypair
make sync-permissions NAME=<name>   # Re-sync folder permissions
```

### **🧹 Cleanup:**
```bash
make cleanup-file-bridge NAME=<name>  # Remove specific bridge
make cleanup-all-file-bridges         # Nuclear cleanup of all bridges
```

## 🔑 SSH Key Management

Each bridge automatically generates:
- **Private key** (stored in Kubernetes secret)
- **Public key** (for deployment to target host)
- **SSH config** (for manual connections)

Keys are stored in: `file_bridge_deployment/ssh-keys/{bridge-name}/`

## 📊 Configuration Options

| Parameter | Description | Options | Default |
|-----------|-------------|---------|---------|
| **NAME** | Unique bridge identifier | any-string | required |
| **HOST** | Target hostname/IP | hostname/IP | required |
| **PATH** | Remote folder path | /any/path | required |
| **MODE** | Access permissions | read-only, write-only, read-write, append-only | read-write |
| **PORT** | SFTP service port | 2200-2299 | auto-assigned |
| **USER** | SSH username | any-user | bridge-user |

## 🌟 Advanced Features

### **🔄 Real-time Monitoring**
- Connection health checks every 30 seconds
- Mount point validation and auto-recovery
- SFTP service availability monitoring
- Performance metrics collection

### **🛡️ Security Features**
- Isolated network namespaces per bridge
- Encrypted SSH connections with unique keys
- Permission validation and enforcement
- Audit logging of all file operations

### **⚡ Performance Optimization**
- Persistent SSH connections
- Intelligent caching strategies
- Bandwidth limiting and QoS
- Concurrent transfer optimization

## 🎯 Use Case Examples

### **📊 Data Pipeline Bridge**
```bash
# Input for raw data
make new-file-bridge NAME=raw-input HOST=data.local PATH=/raw MODE=write-only

# Processing workspace  
make new-file-bridge NAME=processing HOST=data.local PATH=/work MODE=read-write

# Output for results
make new-file-bridge NAME=results HOST=data.local PATH=/output MODE=read-only
```

### **🤖 AI Model Bridge**
```bash
# Model storage (read-only)
make new-file-bridge NAME=ai-models HOST=gpu.local PATH=/models MODE=read-only

# Inference input (write-only)
make new-file-bridge NAME=ai-input HOST=gpu.local PATH=/input MODE=write-only

# Results output (read-only)
make new-file-bridge NAME=ai-output HOST=gpu.local PATH=/results MODE=read-only
```

### **📋 Monitoring Bridge**
```bash
# Log aggregation (append-only)
make new-file-bridge NAME=logs HOST=monitor.local PATH=/logs MODE=append-only

# Metrics collection (read-write)
make new-file-bridge NAME=metrics HOST=monitor.local PATH=/metrics MODE=read-write
```

## 🎊 Integration with Existing Platform

File bridges seamlessly integrate with your existing infrastructure:
- **Cross-namespace access** from n8n workflows
- **Same beautiful Makefile interface** as AI models and databases
- **Consistent monitoring** and logging patterns
- **Nuclear cleanup** options for safe testing

---

**Ready to bridge the gap between your files and your workflows!** 🌉📁🚀