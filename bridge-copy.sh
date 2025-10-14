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

# 🌉 Starbridge Platform - File Bridge Copy Helper
# Ultra-praktische Datei-Copy-Funktionen für File Bridges

set -e

# Configuration
NAMESPACE="file-bridges"
DATA_PATH="/data"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}🌉 File Bridge Copy Helper${NC}"
    echo "─════════════════════════════════════════════════════════════════════════════════"
}

get_pod_name() {
    local bridge_name="$1"
    # Try multiple label selectors
    kubectl get pods -n "$NAMESPACE" -l "bridge-name=$bridge_name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || \
    kubectl get pods -n "$NAMESPACE" -l "app=file-bridge-$bridge_name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || \
    kubectl get pods -n "$NAMESPACE" | grep "$bridge_name" | head -1 | awk '{print $1}' || \
    echo ""
}

list_bridges() {
    echo -e "${YELLOW}📋 Available File Bridges:${NC}"
    kubectl get pods -n "$NAMESPACE" --no-headers | while read pod ready status restarts age; do
        if [[ "$pod" == *"bridge"* ]]; then
            bridge_name=$(echo "$pod" | sed 's/.*bridge-\([^-]*\).*/\1/' | sed 's/-[a-z0-9]*-[a-z0-9]*$//')
            echo "  • $bridge_name ($pod)"
        fi
    done
}

copy_to_bridge() {
    local bridge_name="$1"
    local source="$2"
    local dest="$3"
    
    if [[ -z "$bridge_name" || -z "$source" ]]; then
        echo -e "${RED}❌ Usage: $0 to <bridge-name> <source-path> [destination-path]${NC}"
        list_bridges
        return 1
    fi
    
    # Expand source path
    source="${source/#\~/$HOME}"
    
    if [[ ! -e "$source" ]]; then
        echo -e "${RED}❌ Source path does not exist: $source${NC}"
        return 1  
    fi
    
    # Get pod name
    local pod_name=$(get_pod_name "$bridge_name")
    if [[ -z "$pod_name" ]]; then
        echo -e "${RED}❌ Bridge '$bridge_name' not found${NC}"
        list_bridges
        return 1
    fi
    
    # Set destination
    if [[ -z "$dest" ]]; then
        if [[ -d "$source" ]]; then
            dest="$DATA_PATH/$(basename "$source")/"
        else
            dest="$DATA_PATH/"
        fi
    fi
    
    echo -e "${GREEN}📂➡️  Copying to File Bridge: $bridge_name${NC}"
    echo "📂 Source: $source"  
    echo "🎯 Destination: $dest"
    echo "📦 Target Pod: $pod_name"
    echo ""
    
    # Copy the file/folder
    echo "⚙️ Copying..."
    if kubectl cp "$source" "$NAMESPACE/$pod_name:$dest"; then
        echo -e "${GREEN}✅ Copy completed successfully!${NC}"
        echo ""
        echo "📋 Files now in bridge:"
        kubectl exec -n "$NAMESPACE" "$pod_name" -- find "$DATA_PATH" -name "$(basename "$source")" -ls 2>/dev/null || \
        kubectl exec -n "$NAMESPACE" "$pod_name" -- ls -la "$DATA_PATH/" 2>/dev/null
    else
        echo -e "${RED}❌ Copy failed${NC}"
        return 1
    fi
}

copy_from_bridge() {
    local bridge_name="$1"
    local source="$2"
    local dest="$3"
    
    if [[ -z "$bridge_name" || -z "$source" ]]; then
        echo -e "${RED}❌ Usage: $0 from <bridge-name> <source-path> [destination-path]${NC}"
        list_bridges  
        return 1
    fi
    
    # Get pod name
    local pod_name=$(get_pod_name "$bridge_name")
    if [[ -z "$pod_name" ]]; then
        echo -e "${RED}❌ Bridge '$bridge_name' not found${NC}"
        list_bridges
        return 1
    fi
    
    # Set destination
    if [[ -z "$dest" ]]; then
        dest="./"
    else
        dest="${dest/#\~/$HOME}"
    fi
    
    echo -e "${GREEN}📂⬅️  Copying from File Bridge: $bridge_name${NC}"
    echo "📂 Source: $source"
    echo "🎯 Destination: $dest"  
    echo "📦 Source Pod: $pod_name"
    echo ""
    
    # Copy the file/folder
    echo "⚙️ Copying..."
    if kubectl cp "$NAMESPACE/$pod_name:$source" "$dest"; then
        echo -e "${GREEN}✅ Copy completed successfully!${NC}"
        echo "📋 Files copied to: $dest"
    else
        echo -e "${RED}❌ Copy failed${NC}"
        return 1
    fi
}

list_files() {
    local bridge_name="$1"
    local path="$2"
    
    if [[ -z "$bridge_name" ]]; then
        echo -e "${RED}❌ Usage: $0 ls <bridge-name> [path]${NC}"
        list_bridges
        return 1
    fi
    
    # Get pod name
    local pod_name=$(get_pod_name "$bridge_name")
    if [[ -z "$pod_name" ]]; then
        echo -e "${RED}❌ Bridge '$bridge_name' not found${NC}"
        list_bridges
        return 1
    fi
    
    # Set path
    if [[ -z "$path" ]]; then
        path="$DATA_PATH/"
    fi
    
    echo -e "${GREEN}📂📋 Listing File Bridge Contents: $bridge_name${NC}"
    echo "📂 Path: $path"
    echo "📦 Pod: $pod_name"
    echo ""
    
    kubectl exec -n "$NAMESPACE" "$pod_name" -- ls -la "$path" 2>/dev/null || \
    echo -e "${RED}❌ Path not found or not accessible${NC}"
}

# Main command dispatcher
print_header

case "$1" in
    "to")
        copy_to_bridge "$2" "$3" "$4"
        ;;
    "from")
        copy_from_bridge "$2" "$3" "$4"
        ;;
    "ls")
        list_files "$2" "$3"
        ;;
    "list")
        list_bridges
        ;;
    *)
        echo -e "${YELLOW}📋 Usage:${NC}"
        echo "  $0 to <bridge-name> <source-path> [destination-path]     # Copy TO bridge"
        echo "  $0 from <bridge-name> <source-path> [destination-path]   # Copy FROM bridge"  
        echo "  $0 ls <bridge-name> [path]                               # List files"
        echo "  $0 list                                                  # List all bridges"
        echo ""
        echo -e "${YELLOW}📚 Examples:${NC}"
        echo "  $0 to starbridge-transfer ~/myfile.txt"
        echo "  $0 to starbridge-transfer ~/myfolder/ /data/input/"
        echo "  $0 from starbridge-transfer /data/output.txt ~/downloads/"
        echo "  $0 ls starbridge-transfer"
        echo "  $0 ls starbridge-transfer /data/input/"
        ;;
esac