# 🔑 SSH Key Templates

## ⚠️ SECURITY NOTICE

**SSH keys have been REMOVED from Git repository for security reasons!**

- **NEVER commit real SSH keys to Git!**
- **SSH keys are generated dynamically by the File Bridge system**
- **Use HashiCorp Vault for production secret management**

## � How File Bridge SSH Keys Work

File Bridge uses **automated SSH key generation** - no templates needed!

### 1. Key Generation
```bash
# Generate keys for a new bridge
./ssh-key-manager.sh generate my-bridge

# Keys are created in: ssh-keys/my-bridge/
├── id_rsa              # Private key (auto-generated)
├── id_rsa.pub          # Public key (auto-generated)
├── ssh_config          # SSH client config
└── deployment_instructions.txt
```

### 2. Kubernetes Integration
```bash
# Create secret from generated keys
kubectl create secret generic ssh-keys-my-bridge \
    --from-file=id_rsa=./ssh-keys/my-bridge/id_rsa \
    --from-file=id_rsa.pub=./ssh-keys/my-bridge/id_rsa.pub \
    --from-file=ssh_config=./ssh-keys/my-bridge/ssh_config
```

### 3. Deployment
The File Bridge deployment automatically:
- Mounts SSH keys from Kubernetes secrets
- Sets proper permissions (600 for private, 644 for public)
- Generates SSH host keys for SFTP server
- Configures SSH client for remote connections

## 🔧 Key Management Commands

```bash
# Generate new bridge keys
./ssh-key-manager.sh generate bridge-name

# List all bridges
./ssh-key-manager.sh list

# Show bridge details
./ssh-key-manager.sh show bridge-name

# Rotate keys (regenerate)
./ssh-key-manager.sh regenerate bridge-name

# Clean up bridge
./ssh-key-manager.sh cleanup bridge-name
```

## 🛡️ Security Best Practices

- ✅ Keys are generated per bridge (unique isolation)
- ✅ Keys are managed by dedicated script
- ✅ Keys are stored as Kubernetes secrets
- ✅ Keys are automatically ignored by .gitignore
- ✅ Integration with HashiCorp Vault available

## 🔐 HashiCorp Vault Integration

For production deployments, integrate with Vault:

```bash
# Store generated keys in Vault
vault kv put secret/ssh-keys/my-bridge \
    private_key=@ssh-keys/my-bridge/id_rsa \
    public_key=@ssh-keys/my-bridge/id_rsa.pub

# Retrieve keys for deployment
vault kv get -field=private_key secret/ssh-keys/my-bridge > /tmp/id_rsa
```

## 📋 Conclusion

**No templates needed!** 
- File Bridge generates keys automatically
- Each bridge gets unique SSH keys
- Vault integration for enterprise deployments
- Git repository stays clean and secure

## 🔐 Production Key Management

### **With Vault Nexus (Recommended):**
```bash
# Generate and store in Vault
ssh-keygen -t ed25519 -f /tmp/bridge_key -N ""
vault kv put starbridge/ssh-keys/your-bridge \
    private_key=@/tmp/bridge_key \
    public_key=@/tmp/bridge_key.pub
rm /tmp/bridge_key*
```

### **Manual Generation:**
```bash
# Generate fresh key pair
ssh-keygen -t ed25519 -f ~/.ssh/starbridge_bridge -N ""

# Use in Kubernetes Secret
kubectl create secret generic bridge-ssh-key \
    --from-file=id_rsa=~/.ssh/starbridge_bridge \
    --from-file=id_rsa.pub=~/.ssh/starbridge_bridge.pub
```

## 📁 Template Structure

Each bridge template contains:
- `id_rsa` - Private key (EXAMPLE ONLY)
- `id_rsa.pub` - Public key (EXAMPLE ONLY)
- `ssh_config` - SSH client configuration
- `deployment_instructions.txt` - Setup guide

## 🛡️ Security Best Practices

1. **Always generate fresh keys**
2. **Use strong passphrases in production**
3. **Rotate keys regularly**
4. **Use Vault for secret management**
5. **Never commit real keys to Git**

---

**🖖 Remember: These are templates, not production keys!**