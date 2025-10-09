#!/bin/bash
# Starbridge Platform - File Bridge SSH Key Manager
# Seamlessly connecting workflows across the digital frontier
# Enterprise-grade SSH key management for file bridge services
# Part of the Starbridge Platform ecosystem

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="$SCRIPT_DIR/ssh-keys"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "\n${PURPLE}🔑 $1${NC}"
    echo -e "${PURPLE}$(printf '=%.0s' $(seq 1 ${#1}))${NC}"
}

# Help function
show_help() {
    cat << EOF
${WHITE}🔑 File Bridge SSH Key Manager${NC}

${YELLOW}USAGE:${NC}
    $0 <command> [options]

${YELLOW}COMMANDS:${NC}
    ${GREEN}generate${NC} <bridge-name>     Generate new SSH keypair for bridge
    ${GREEN}deploy${NC} <bridge-name>       Deploy public key to target host  
    ${GREEN}show${NC} <bridge-name>         Show SSH configuration for bridge
    ${GREEN}list${NC}                       List all generated keypairs
    ${GREEN}test${NC} <bridge-name>         Test SSH connection
    ${GREEN}cleanup${NC} <bridge-name>      Remove keypair for bridge
    ${GREEN}help${NC}                       Show this help message

${YELLOW}EXAMPLES:${NC}
    $0 generate n8n-input
    $0 deploy n8n-input user@fileserver.local
    $0 test n8n-input
    $0 show n8n-input
    $0 list
    $0 cleanup n8n-input

${YELLOW}KEY LOCATIONS:${NC}
    Private keys: ${KEYS_DIR}/{bridge-name}/id_rsa
    Public keys:  ${KEYS_DIR}/{bridge-name}/id_rsa.pub
    SSH config:   ${KEYS_DIR}/{bridge-name}/ssh_config
EOF
}

# Generate SSH keypair for a bridge
generate_keypair() {
    local bridge_name="$1"
    local key_dir="$KEYS_DIR/$bridge_name"
    
    log_header "Generating SSH keypair for bridge: $bridge_name"
    
    # Create key directory
    mkdir -p "$key_dir"
    
    # Generate keypair
    log_info "Generating RSA keypair..."
    ssh-keygen -t rsa -b 4096 -f "$key_dir/id_rsa" -N "" -C "file-bridge-$bridge_name@rancher-deployment-test"
    
    # Set proper permissions
    chmod 600 "$key_dir/id_rsa"
    chmod 644 "$key_dir/id_rsa.pub"
    
    # Generate SSH config template
    cat > "$key_dir/ssh_config" << EOF
Host file-bridge-$bridge_name
    HostName %HOST%
    User %USER%
    Port 22
    IdentityFile $key_dir/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 30
EOF
    
    # Create deployment instructions
    cat > "$key_dir/deployment_instructions.txt" << EOF
🔑 SSH Key Deployment Instructions for Bridge: $bridge_name

1. Copy the public key to your target host:
   scp $key_dir/id_rsa.pub user@target-host:/tmp/

2. On the target host, add the key to authorized_keys:
   mkdir -p ~/.ssh
   cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   chmod 700 ~/.ssh
   rm /tmp/id_rsa.pub

3. Test the connection:
   ssh -i $key_dir/id_rsa user@target-host

4. Update your Makefile deployment with:
   HOST=target-host
   USER=username
   PATH=/path/to/mount

EOF
    
    log_success "SSH keypair generated successfully!"
    log_info "Private key: $key_dir/id_rsa"
    log_info "Public key: $key_dir/id_rsa.pub"
    log_info "SSH config: $key_dir/ssh_config"
    log_info "Instructions: $key_dir/deployment_instructions.txt"
    
    echo -e "\n${YELLOW}📋 Next steps:${NC}"
    echo "1. Deploy public key: $0 deploy $bridge_name user@host"
    echo "2. Test connection: $0 test $bridge_name"
    echo "3. Deploy bridge: make new-file-bridge NAME=$bridge_name HOST=hostname PATH=/path"
}

# Deploy public key to target host
deploy_key() {
    local bridge_name="$1"
    local target="$2"
    local key_dir="$KEYS_DIR/$bridge_name"
    
    if [[ ! -f "$key_dir/id_rsa.pub" ]]; then
        log_error "Public key not found for bridge: $bridge_name"
        log_info "Generate keypair first: $0 generate $bridge_name"
        exit 1
    fi
    
    log_header "Deploying public key for bridge: $bridge_name"
    log_info "Target: $target"
    
    # Extract user and host
    if [[ "$target" =~ ^(.+)@(.+)$ ]]; then
        local user="${BASH_REMATCH[1]}"
        local host="${BASH_REMATCH[2]}"
    else
        log_error "Invalid target format. Use: user@hostname"
        exit 1
    fi
    
    log_info "Copying public key to $target..."
    scp "$key_dir/id_rsa.pub" "$target:/tmp/bridge-key-$bridge_name.pub"
    
    log_info "Installing public key on remote host..."
    ssh "$target" << EOF
        mkdir -p ~/.ssh
        cat /tmp/bridge-key-$bridge_name.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        chmod 700 ~/.ssh
        rm /tmp/bridge-key-$bridge_name.pub
        echo "✅ Public key installed successfully"
EOF
    
    # Update SSH config with actual host and user
    sed -i "s/%HOST%/$host/g; s/%USER%/$user/g" "$key_dir/ssh_config"
    
    log_success "Public key deployed successfully!"
    log_info "Updated SSH config: $key_dir/ssh_config"
    
    echo -e "\n${YELLOW}🧪 Test the connection:${NC}"
    echo "$0 test $bridge_name"
}

# Test SSH connection
test_connection() {
    local bridge_name="$1"
    local key_dir="$KEYS_DIR/$bridge_name"
    
    if [[ ! -f "$key_dir/ssh_config" ]]; then
        log_error "SSH config not found for bridge: $bridge_name"
        exit 1
    fi
    
    log_header "Testing SSH connection for bridge: $bridge_name"
    
    # Extract host and user from SSH config
    local host=$(grep "HostName" "$key_dir/ssh_config" | awk '{print $2}')
    local user=$(grep "User" "$key_dir/ssh_config" | awk '{print $2}')
    
    if [[ "$host" == "%HOST%" ]] || [[ "$user" == "%USER%" ]]; then
        log_error "SSH config not updated. Deploy the key first:"
        log_info "$0 deploy $bridge_name user@hostname"
        exit 1
    fi
    
    log_info "Testing connection to $user@$host..."
    
    if ssh -F "$key_dir/ssh_config" "file-bridge-$bridge_name" "echo 'SSH connection successful!'" 2>/dev/null; then
        log_success "SSH connection test passed!"
        
        # Test basic filesystem operations
        log_info "Testing filesystem access..."
        ssh -F "$key_dir/ssh_config" "file-bridge-$bridge_name" << 'EOF'
            echo "Current directory: $(pwd)"
            echo "Available space: $(df -h . | tail -1 | awk '{print $4}')"
            if touch /tmp/bridge-test-$(date +%s) 2>/dev/null; then
                echo "✅ Write access confirmed"
                rm -f /tmp/bridge-test-* 2>/dev/null
            else
                echo "⚠️  Limited write access"
            fi
EOF
        
        log_success "Bridge connectivity verified!"
        echo -e "\n${YELLOW}🚀 Ready to deploy bridge:${NC}"
        echo "make new-file-bridge NAME=$bridge_name HOST=$host USER=$user PATH=/path/to/mount"
    else
        log_error "SSH connection failed!"
        log_info "Check the following:"
        echo "  • Host is reachable: ping $host"
        echo "  • SSH service is running on target host"
        echo "  • Public key is properly installed"
        echo "  • Firewall allows SSH connections"
        exit 1
    fi
}

# Show SSH configuration
show_config() {
    local bridge_name="$1"
    local key_dir="$KEYS_DIR/$bridge_name"
    
    if [[ ! -d "$key_dir" ]]; then
        log_error "No SSH keys found for bridge: $bridge_name"
        exit 1
    fi
    
    log_header "SSH Configuration for bridge: $bridge_name"
    
    if [[ -f "$key_dir/ssh_config" ]]; then
        echo -e "${CYAN}📄 SSH Config:${NC}"
        cat "$key_dir/ssh_config"
        echo
    fi
    
    if [[ -f "$key_dir/id_rsa.pub" ]]; then
        echo -e "${CYAN}🔑 Public Key:${NC}"
        cat "$key_dir/id_rsa.pub"
        echo
    fi
    
    echo -e "${CYAN}📁 Key Files:${NC}"
    ls -la "$key_dir/"
    
    echo -e "\n${CYAN}📊 Key Fingerprint:${NC}"
    ssh-keygen -lf "$key_dir/id_rsa.pub"
}

# List all keypairs
list_keys() {
    log_header "Available SSH Keypairs"
    
    if [[ ! -d "$KEYS_DIR" ]] || [[ -z "$(ls -A "$KEYS_DIR" 2>/dev/null)" ]]; then
        log_warning "No SSH keypairs found"
        echo -e "\n${YELLOW}💡 Generate your first keypair:${NC}"
        echo "$0 generate <bridge-name>"
        return
    fi
    
    echo -e "${CYAN}📋 Bridge Name${NC}          ${CYAN}Status${NC}      ${CYAN}Host${NC}              ${CYAN}User${NC}"
    echo "────────────────────────────────────────────────────────────────────"
    
    for bridge_dir in "$KEYS_DIR"/*; do
        if [[ -d "$bridge_dir" ]]; then
            local bridge_name=$(basename "$bridge_dir")
            local status="❓ Unknown"
            local host="Not configured"
            local user="Not configured"
            
            if [[ -f "$bridge_dir/id_rsa" ]] && [[ -f "$bridge_dir/id_rsa.pub" ]]; then
                if [[ -f "$bridge_dir/ssh_config" ]]; then
                    local config_host=$(grep "HostName" "$bridge_dir/ssh_config" | awk '{print $2}')
                    local config_user=$(grep "User" "$bridge_dir/ssh_config" | awk '{print $2}')
                    
                    if [[ "$config_host" != "%HOST%" ]] && [[ "$config_user" != "%USER%" ]]; then
                        status="${GREEN}✅ Ready${NC}"
                        host="$config_host"
                        user="$config_user"
                    else
                        status="${YELLOW}⚠️  Needs Deploy${NC}"
                    fi
                else
                    status="${YELLOW}⚠️  Partial${NC}"
                fi
            else
                status="${RED}❌ Incomplete${NC}"
            fi
            
            printf "%-20s %s  %-15s %s\n" "$bridge_name" "$status" "$host" "$user"
        fi
    done
    
    echo
    log_info "Use '$0 show <bridge-name>' for detailed information"
}

# Cleanup keypair
cleanup_keys() {
    local bridge_name="$1"
    local key_dir="$KEYS_DIR/$bridge_name"
    
    if [[ ! -d "$key_dir" ]]; then
        log_warning "No keys found for bridge: $bridge_name"
        return
    fi
    
    log_header "Cleaning up SSH keys for bridge: $bridge_name"
    
    echo -e "${YELLOW}⚠️  This will permanently delete:${NC}"
    echo "  • Private key: $key_dir/id_rsa"
    echo "  • Public key: $key_dir/id_rsa.pub" 
    echo "  • SSH config: $key_dir/ssh_config"
    echo "  • All related files"
    echo
    
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$key_dir"
        log_success "SSH keys cleaned up successfully!"
    else
        log_info "Cleanup cancelled"
    fi
}

# Main script logic
main() {
    case "${1:-}" in
        "generate")
            if [[ -z "${2:-}" ]]; then
                log_error "Bridge name required"
                echo "Usage: $0 generate <bridge-name>"
                exit 1
            fi
            generate_keypair "$2"
            ;;
        "deploy")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                log_error "Bridge name and target required"
                echo "Usage: $0 deploy <bridge-name> <user@hostname>"
                exit 1
            fi
            deploy_key "$2" "$3"
            ;;
        "show")
            if [[ -z "${2:-}" ]]; then
                log_error "Bridge name required"
                echo "Usage: $0 show <bridge-name>"
                exit 1
            fi
            show_config "$2"
            ;;
        "list")
            list_keys
            ;;
        "test")
            if [[ -z "${2:-}" ]]; then
                log_error "Bridge name required"
                echo "Usage: $0 test <bridge-name>"
                exit 1
            fi
            test_connection "$2"
            ;;
        "cleanup")
            if [[ -z "${2:-}" ]]; then
                log_error "Bridge name required"
                echo "Usage: $0 cleanup <bridge-name>"
                exit 1
            fi
            cleanup_keys "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: ${1:-}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Create keys directory if it doesn't exist
mkdir -p "$KEYS_DIR"

# Run main function
main "$@"