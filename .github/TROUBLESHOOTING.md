# 🔧 GitHub Actions Troubleshooting

## 🚨 Common Issues & Solutions

### **CodeQL Upload Errors**

#### **Issue 1: "Resource not accessible by integration"**
```
Error: Resource not accessible by integration
Warning: Caught an exception while gathering information for telemetry
```

**Solution:**
```yaml
# Add permissions to workflow or job level
permissions:
  contents: read
  security-events: write  # Required for SARIF upload
  actions: read
```

#### **Issue 2: "CodeQL Action v1/v2 deprecated"**
```
Error: CodeQL Action major versions v1 and v2 have been deprecated
```

**Solution:**
```yaml
# Update to v3
- uses: github/codeql-action/upload-sarif@v3
```

### **Trivy Scanner Issues**

#### **Issue 1: SARIF file not found**
```
Error: SARIF file not found: trivy-results.sarif
```

**Solution:**
```yaml
# Ensure Trivy generates SARIF correctly
- name: 🔍 Run Trivy Vulnerability Scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
    format: 'sarif'  # Must be sarif
    output: 'trivy-results.sarif'  # Explicit output file
```

#### **Issue 2: Too many findings**
```
Error: SARIF file too large
```

**Solution:**
```yaml
# Filter severity levels
severity: 'CRITICAL,HIGH'  # Remove MEDIUM/LOW
ignore-unfixed: true       # Ignore unfixed vulnerabilities
trivyignores: '.trivyignore'  # Use ignore file
```

### **Permission Requirements**

#### **Repository Settings:**
1. **Settings** → **Actions** → **General**
2. **Workflow permissions**: "Read and write permissions"
3. **Allow GitHub Actions to create and approve pull requests**: ✅

#### **Required Permissions:**
```yaml
permissions:
  contents: read          # Read repository content
  security-events: write  # Upload SARIF to Security tab
  actions: read          # Read workflow status
  pull-requests: write   # Comment on PRs (optional)
```

## 🛠️ Debugging Steps

### **1. Check Repository Settings**
```bash
# Verify repository has security features enabled
# Settings → Security & analysis → Code scanning alerts: Enabled
```

### **2. Validate SARIF File**
```yaml
# Add validation step before upload
- name: 🧪 Validate SARIF
  run: |
    if [ -f "trivy-results.sarif" ]; then
      echo "✅ SARIF file exists"
      echo "📊 File size: $(du -h trivy-results.sarif)"
      echo "📋 First 10 lines:"
      head -10 trivy-results.sarif
    else
      echo "❌ SARIF file missing"
      exit 1
    fi
```

### **3. Test Local Trivy Scan**
```bash
# Test locally first
trivy fs . --format sarif --output trivy-results.sarif
cat trivy-results.sarif | jq '.runs[0].results | length'
```

## 🎯 Best Practices

### **Workflow Organization:**
```yaml
# Separate security job for clarity
jobs:
  security-scan:
    name: 🛡️ Security Scan
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      # ... security-specific steps
```

### **Error Handling:**
```yaml
# Always upload results, even on failure
- name: 📊 Upload Results
  if: always()  # Upload even if scan fails
  uses: github/codeql-action/upload-sarif@v3
```

### **Performance Optimization:**
```yaml
# Cache Trivy DB for faster scans
- name: 📦 Cache Trivy DB
  uses: actions/cache@v4
  with:
    path: ~/.cache/trivy
    key: trivy-db
```

## 📚 Additional Resources

- [GitHub Code Scanning Documentation](https://docs.github.com/en/code-security/code-scanning)
- [SARIF Support for Code Scanning](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning)
- [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
- [CodeQL Action Documentation](https://github.com/github/codeql-action)

---

**🖖 Keep your workflows running smoothly!**