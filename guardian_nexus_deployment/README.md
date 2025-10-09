# 🛡️ Guardian Nexus - Central Security Command

## 🌟 Overview

Guardian Nexus is the central security command center for Starbridge Platform, providing enterprise-grade authentication and authorization services through Keycloak integration.

## 🎯 Features

- **🔐 Enterprise Authentication** - Keycloak-based SSO with OIDC/SAML support
- **🛡️ Role-Based Access Control** - Platform Administrator, Technical Admin, Workflow Operator roles  
- **🏢 Multi-Client Support** - Workflow Nexus (n8n) and Starbridge Beacon integration
- **📊 High Availability** - PostgreSQL backend with persistent storage
- **🔍 Security Monitoring** - Comprehensive logging and audit trails
- **⚙️ Zero-Trust Architecture** - All platform access requires authentication

## 📁 Components

```
security_nexus_deployment/
├── security-nexus-namespace.yaml      # Dedicated security namespace
├── guardian-nexus-secrets.yaml        # Encrypted credentials
├── guardian-nexus-pvc.yaml           # Persistent storage claims
├── guardian-nexus-postgres-config.yaml # Database configuration
├── guardian-nexus-postgres.yaml       # PostgreSQL deployment
├── guardian-nexus-keycloak-config.yaml # Keycloak realm configuration
├── guardian-nexus-keycloak.yaml       # Keycloak deployment
├── guardian-nexus-ingress.yaml        # External access configuration
└── README.md                          # This file
```

## 🚀 Quick Deployment

### Deploy Guardian Nexus:
```bash
# Deploy complete security infrastructure
make deploy-guardian-nexus

# Check deployment status
make status-guardian-nexus

# Access admin console
make port-forward-guardian-nexus
```

### SFRS Integration:
```bash
# Start with Fleet Relay System
make sfrs-start-guardian-nexus

# Include in fleet deployment
make sfrs-start-fleet
```

## 🔐 Access & Credentials

### Admin Console Access
```bash
# Port-forward method
make port-forward-guardian-nexus
# Access: http://localhost:8080/admin

# SFRS method
make sfrs-start-guardian-nexus
# Access: http://localhost:8080/admin (auto-allocated port)

# Ingress method (if configured)
# Access: http://guardian.starbridge.local/admin
```

### Default Credentials
```
Admin Console:
  Username: admin
  Password: starbridge-admin-2025

Platform Administrator Account:
  Username: admin
  Password: starbridge-admin-2025

Technical Admin Account:
  Username: admin-tech
  Password: technical-admin-2025
```

## 🎖️ User Roles & Permissions

### Role Hierarchy
1. **🎖️ Platform Administrator** - Complete platform administration
   - Full Keycloak admin access
   - All service management
   - User and role administration

2. **⚙️ Technical Admin** - Technical system administration
   - Infrastructure management
   - Service deployment and monitoring
   - Security configuration

3. **🤖 Workflow Operator** - n8n workflow management
   - Workflow creation and execution
   - Credential management
   - Data processing operations

4. **👤 Platform User** - Basic platform access
   - Read-only dashboard access
   - Limited workflow viewing

## 🌐 Client Applications

### Configured Clients
1. **Workflow Nexus** (`workflow-nexus`)
   - n8n authentication integration
   - OIDC protocol
   - Service account enabled

2. **Starbridge Beacon** (`starbridge-beacon`)
   - Web interface authentication
   - OIDC protocol
   - User interface access

## 📊 Monitoring & Management

### Health Checks
```bash
# Component status
make status-guardian-nexus

# View logs
make logs-guardian-nexus

# Restart services
make restart-guardian-nexus
```

### Keycloak Health Endpoints
```bash
# Direct health checks
curl http://localhost:8080/health/live
curl http://localhost:8080/health/ready
curl http://localhost:8080/health/started
```

## 🔧 Configuration

### Realm Configuration
- **Realm Name**: `starbridge-platform`
- **Login Theme**: Starbridge branded
- **Security**: Brute force protection enabled
- **Sessions**: Optimized for workflow operations

### Database Configuration
- **Engine**: PostgreSQL 15
- **Storage**: Persistent volumes
- **Backup**: Automated with platform backup strategy
- **Performance**: Optimized for authentication workloads

## 🛡️ Security Features

### Enterprise Security
- **Password Policies**: Complex password requirements
- **Session Management**: Secure session handling
- **Brute Force Protection**: Failed login lockout
- **Audit Logging**: Comprehensive security event logging

### Network Security
- **Namespace Isolation**: Dedicated security-nexus namespace
- **Service Mesh Ready**: Istio/Linkerd compatible
- **TLS Termination**: Ingress-level SSL/TLS
- **Internal Communication**: Encrypted service-to-service

## 🚨 Troubleshooting

### Common Issues

**Keycloak not starting:**
```bash
# Check PostgreSQL first
kubectl get pods -n security-nexus -l component=database
kubectl logs -n security-nexus -l component=database

# Check Keycloak startup
kubectl describe pod -n security-nexus -l component=keycloak
```

**Database connection issues:**
```bash
# Verify PostgreSQL service
kubectl get service guardian-nexus-postgres-service -n security-nexus

# Test connection from Keycloak pod
kubectl exec -it -n security-nexus deployment/guardian-nexus-keycloak -- /bin/bash
```

**Authentication not working:**
```bash
# Check realm configuration
kubectl get configmap guardian-nexus-keycloak-config -n security-nexus -o yaml

# Verify client configuration in Keycloak admin console
```

## 🔄 Integration Phases

### Phase 1: Guardian Nexus Deployment ✅
- Keycloak and PostgreSQL deployed
- Basic realm configuration
- Admin access established

### Phase 2: Workflow Nexus Integration (Next)
- n8n OIDC configuration
- Role-based workflow access
- Credential store integration

### Phase 3: Fleet-Wide Security (Future)
- Starbridge Beacon authentication
- Neural Nexus access controls
- Data Vault connection security

## 🎯 Next Steps

1. **Verify Guardian Nexus Status**: `make status-guardian-nexus`
2. **Access Admin Console**: `make port-forward-guardian-nexus`
3. **Configure Additional Users**: Add team members via admin console
4. **Proceed to Phase 2**: Workflow Nexus integration

## 🖖 Enterprise Compliance

Guardian Nexus provides enterprise-grade security features:
- **GDPR Compliance**: User data protection and privacy controls
- **SOC 2 Ready**: Security monitoring and audit capabilities
- **LDAP Integration**: Enterprise directory service connectivity
- **SAML/OIDC**: Industry standard authentication protocols

---

**🛡️ "Protecting the digital frontier with enterprise-grade security" 🖖**