# 🔑 SSH Key Templates

## ⚠️ Important Notice

**These SSH keys are EXAMPLES and TEMPLATES only!**

- **DO NOT use these keys in production**
- **These are for demonstration and testing purposes**
- **Generate fresh SSH keys for each deployment**
- **Use Vault Nexus for production secret management**

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