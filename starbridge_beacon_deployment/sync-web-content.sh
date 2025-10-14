#!/bin/bash
#
# MIT License
#
# Copyright (c) 2025 Starbridge Platform
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Starbridge Platform - Web Content Sync Script
# Synchronizes web content to production webserver PVC

set -e

NAMESPACE="starbridge-platform"
PVC_NAME="starbridge-webserver-pvc"
WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../web" && pwd)"

echo "🌟 Starbridge Platform - Web Content Sync"
echo "📁 Source: $WEB_DIR"
echo "🎯 Target: $NAMESPACE/$PVC_NAME"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "❌ Namespace '$NAMESPACE' not found. Creating..."
    kubectl create namespace "$NAMESPACE"
fi

# Check if PVC exists
if ! kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "❌ PVC '$PVC_NAME' not found. Deploy webserver first with 'make deploy-webserver'"
    exit 1
fi

# Create temporary pod for content sync
echo "🚀 Creating temporary sync pod..."
kubectl run starbridge-sync-pod \
    --namespace="$NAMESPACE" \
    --image=alpine:latest \
    --restart=Never \
    --overrides='{
        "spec": {
            "containers": [{
                "name": "sync",
                "image": "alpine:latest",
                "command": ["sleep", "300"],
                "volumeMounts": [{
                    "name": "webserver-content",
                    "mountPath": "/usr/share/nginx/html"
                }]
            }],
            "volumes": [{
                "name": "webserver-content",
                "persistentVolumeClaim": {
                    "claimName": "'$PVC_NAME'"
                }
            }]
        }
    }' \
    --wait=false

# Wait for pod to be ready
echo "⏳ Waiting for sync pod to be ready..."
kubectl wait --for=condition=Ready pod/starbridge-sync-pod -n "$NAMESPACE" --timeout=60s

# Clear existing content and sync new content
echo "🧹 Clearing existing content..."
kubectl exec starbridge-sync-pod -n "$NAMESPACE" -- sh -c "rm -rf /usr/share/nginx/html/*"

echo "📁 Syncing web content..."
for file in "$WEB_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "  📄 Copying $filename..."
        kubectl cp "$file" "$NAMESPACE/starbridge-sync-pod:/usr/share/nginx/html/$filename"
    fi
done

# Create 404 error page
echo "📄 Creating 404 error page..."
kubectl exec starbridge-sync-pod -n "$NAMESPACE" -- sh -c 'cat > /usr/share/nginx/html/404.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>404 - Page Not Found | Starbridge Platform</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #1B365D; }
        .logo { max-width: 200px; margin: 20px auto; }
    </style>
</head>
<body>
    <img src="/logo-starbridge-platform.jpeg" alt="Starbridge Platform" class="logo">
    <h1>404 - Page Not Found</h1>
    <p>The requested resource was not found on this server.</p>
    <p><a href="/">Return to Starbridge Platform</a></p>
</body>
</html>
EOF'

# Verify content
echo "✅ Verifying content sync..."
kubectl exec starbridge-sync-pod -n "$NAMESPACE" -- ls -la /usr/share/nginx/html/

# Cleanup sync pod
echo "🧹 Cleaning up sync pod..."
kubectl delete pod starbridge-sync-pod -n "$NAMESPACE"

echo "🎉 Web content sync complete!"
echo "🌐 Access via: kubectl port-forward -n $NAMESPACE service/starbridge-webserver-service 8080:80"