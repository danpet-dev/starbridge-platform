# 🤝 Contributing to Starbridge Platform

Thank you for your interest in contributing to the Starbridge Platform! We welcome contributions from the community and are excited to see what you'll bring to this project.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. Create a **feature branch** from `main`
4. Make your changes
5. **Test** your changes (see Testing section below)
6. **Submit** a Pull Request

## 🎯 How to Contribute

### 🐛 Bug Reports
- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Include your Kubernetes version and environment details
- Provide clear reproduction steps
- Include relevant Makefile commands and output

### ✨ Feature Requests
- Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Explain the use case and business value
- Consider how it fits with the Star Trek-inspired architecture

### 🔧 Code Contributions

#### **Areas where contributions are welcome:**
- **New deployment modules** (following the "Nexus" naming pattern)
- **Makefile improvements** and new commands
- **Documentation** enhancements
- **Configuration templates** for different environments
- **Troubleshooting guides** and examples

#### **Architecture Guidelines:**
- Follow the **Genesis Architecture v2.0.0** patterns
- Use Star Trek-inspired naming (Nexus, Bridge, Beacon, etc.)
- Support both **Developer** and **Production** modes
- Maintain **cross-namespace** compatibility
- Use consistent emoji conventions in documentation

## 🧪 Testing Your Changes

Since this is an infrastructure project, testing means:

### **Local Testing:**
```bash
# Test Makefile syntax
make help

# Test specific deployments in development mode
make deploy-postgres MODE=dev
make test-file-bridge BRIDGE_NAME=test

# Verify YAML manifests
kubectl apply --dry-run=client -f your-changes.yaml
```

### **Documentation Testing:**
- Ensure all links work
- Verify code examples are correct
- Test Makefile commands mentioned in documentation

### **Integration Testing:**
- Test with a local Kubernetes cluster (Rancher Desktop, minikube, etc.)
- Verify services can communicate across namespaces
- Test both dev and production configurations

## 📝 Pull Request Guidelines

### **Before Submitting:**
- [ ] Test your changes locally
- [ ] Update documentation if needed
- [ ] Add/update relevant README sections
- [ ] Ensure consistent formatting and style
- [ ] Verify no breaking changes to existing deployments

### **PR Title Format:**
```
<type>(<scope>): <description>

Examples:
feat(neural-nexus): add GPU support for Ollama models
fix(makefile): correct namespace handling in dev mode
docs(readme): update quick start guide
```

### **PR Description:**
- Explain **what** you changed and **why**
- Reference any related issues
- Include testing steps
- Note any breaking changes

## 🎖️ Coding Standards

### **Makefile:**
- Use consistent target naming: `<service>-<action>`
- Include help text: `target: ## 📋 Description`
- Use emoji prefixes for visual organization
- Support both `MODE=dev` and `MODE=prod`

### **YAML Manifests:**
- Use consistent indentation (2 spaces)
- Include meaningful labels and annotations
- Follow Kubernetes naming conventions
- Use namespace prefixes for cross-namespace services

### **Documentation:**
- Use clear, concise language
- Include practical examples
- Maintain the Star Trek theme appropriately
- Use emoji for visual hierarchy (but don't overdo it)

## 🛡️ Security Considerations

- **Never commit secrets** or real credentials
- Use placeholder values in examples
- Follow Kubernetes security best practices
- Consider RBAC implications of new features

## 🌟 Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- README.md contributors section (if we add one)
- Project documentation for major features

## 📞 Getting Help

- **GitHub Issues** for bugs and feature requests
- **GitHub Discussions** for questions and ideas
- **README.md** for architecture overview
- **Individual module READMEs** for specific deployment help

## 🖖 Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

---

**Live long and prosper!** 🚀

*Thank you for helping make the Starbridge Platform even better!*