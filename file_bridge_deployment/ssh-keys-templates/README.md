# 🔑 SSH Key Templates

## ⚠️ SECURITY WARNING

**SSH keys have been REMOVED from Git repository for security reasons!**

- **NEVER commit real SSH keys to Git!**
- **Use templates and generate fresh keys for each environment**
- **Integrate with HashiCorp Vault for production deployments**

## 📁 Directory Structure Template
```
environment-name/
├── id_rsa.template      # Private key template (EXAMPLE ONLY)
├── id_rsa.pub.template  # Public key template (EXAMPLE ONLY)  
├── ssh_config           # SSH client configuration
└── deployment_instructions.txt
```

## 🔧 Setup Instructions

1. **Copy template directory:**
   ```bash
   cp -r examples/template-name/ your-environment/
   ```

2. **Generate fresh SSH keys:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f your-environment/id_rsa -C "your-email@domain.com"
   ```

3. **Never commit real keys:**
   ```bash
   # Keys are automatically ignored by .gitignore
   echo "id_rsa*" >> .gitignore
   ```

## 🛡️ Security Best Practices

- ✅ Use unique keys per environment
- ✅ Rotate keys regularly  
- ✅ Use SSH agent forwarding when possible
- ✅ Implement proper key management with Vault
- ❌ Never commit private keys to version control
- ❌ Never share keys via insecure channels

## 🔐 Integration with HashiCorp Vault

For production deployments:

```bash
# Store SSH key in Vault
vault kv put secret/ssh-keys/environment-name private_key=@id_rsa public_key=@id_rsa.pub

# Retrieve in deployment
vault kv get -field=private_key secret/ssh-keys/environment-name > /tmp/id_rsa
chmod 600 /tmp/id_rsa
```

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