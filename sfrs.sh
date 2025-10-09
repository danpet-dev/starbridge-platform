#!/bin/bash

# =============================================================================
# 🌟 Starbridge Fleet Relay System (SFRS)
# =============================================================================
# Multi-Session Port-Forward Manager for Enterprise Operations
# 
# Enables parallel port-forwarding sessions with session management,
# automatic port allocation, and enterprise-grade monitoring.
#
# Author: Starbridge Platform Development Team
# Version: 1.0.0
# =============================================================================

set -e

# Configuration
SFRS_DIR="${HOME}/.starbridge/sfrs"
SESSION_DIR="${SFRS_DIR}/sessions"
LOG_DIR="${SFRS_DIR}/logs"
PID_DIR="${SFRS_DIR}/pids"
CONFIG_FILE="${SFRS_DIR}/config.yaml"

# Port allocation range
PORT_RANGE_START=8080
PORT_RANGE_END=8099

# Emoji definitions
ROCKET="🚀"
NETWORK="🔗"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="💡"
SHIELD="🛡️"

# Initialize SFRS infrastructure
init_sfrs() {
    echo "${ROCKET} Initializing Starbridge Fleet Relay System..."
    
    # Create directory structure
    mkdir -p "${SESSION_DIR}" "${LOG_DIR}" "${PID_DIR}"
    
    # Create default configuration if not exists
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        cat > "${CONFIG_FILE}" << EOF
# Starbridge Fleet Relay System Configuration
port_range:
  start: ${PORT_RANGE_START}
  end: ${PORT_RANGE_END}

security:
  validate_namespaces: true
  require_service_verification: true
  max_concurrent_sessions: 10

logging:
  level: info
  rotate_size: 100MB
  retain_days: 30
EOF
        echo "${CHECK} Configuration created at ${CONFIG_FILE}"
    fi
    
    echo "${CHECK} SFRS infrastructure ready"
}

# Find available port in range
find_available_port() {
    local start_port=${1:-$PORT_RANGE_START}
    local end_port=${2:-$PORT_RANGE_END}
    
    for ((port=start_port; port<=end_port; port++)); do
        if ! netstat -tuln 2>/dev/null | grep -q ":${port} "; then
            echo "${port}"
            return 0
        fi
    done
    
    echo "${ERROR} No available ports in range ${start_port}-${end_port}" >&2
    return 1
}

# Validate Kubernetes service
validate_service() {
    local service="$1"
    local namespace="$2"
    
    echo "${INFO} Validating service ${service} in namespace ${namespace}..."
    
    if ! kubectl get service "${service}" -n "${namespace}" >/dev/null 2>&1; then
        echo "${ERROR} Service ${service} not found in namespace ${namespace}" >&2
        return 1
    fi
    
    echo "${CHECK} Service validation successful"
    return 0
}

# Start port-forward session
start_session() {
    local session_name="$1"
    local service="$2"
    local namespace="$3"
    local target_port="$4"
    local local_port="$5"
    
    # Auto-allocate port if not specified
    if [[ -z "${local_port}" ]]; then
        local_port=$(find_available_port)
        if [[ $? -ne 0 ]]; then
            echo "${ERROR} Cannot allocate port for session ${session_name}"
            return 1
        fi
    fi
    
    # Validate service exists
    if ! validate_service "${service}" "${namespace}"; then
        return 1
    fi
    
    # Check if session already exists
    if [[ -f "${SESSION_DIR}/${session_name}.yaml" ]]; then
        echo "${WARNING} Session ${session_name} already exists"
        return 1
    fi
    
    # Create session metadata
    cat > "${SESSION_DIR}/${session_name}.yaml" << EOF
name: ${session_name}
service: ${service}
namespace: ${namespace}
target_port: ${target_port}
local_port: ${local_port}
started: $(date -Iseconds)
status: starting
access_url: http://localhost:${local_port}
EOF
    
    # Start port-forward in background
    local log_file="${LOG_DIR}/${session_name}.log"
    local pid_file="${PID_DIR}/${session_name}.pid"
    
    echo "${ROCKET} Starting session: ${session_name}"
    echo "${NETWORK} Mapping: localhost:${local_port} → ${service}:${target_port} (${namespace})"
    
    # Start kubectl port-forward
    kubectl port-forward -n "${namespace}" "service/${service}" "${local_port}:${target_port}" \
        > "${log_file}" 2>&1 &
    
    local pid=$!
    echo "${pid}" > "${pid_file}"
    
    # Update session status
    sed -i "s/status: starting/status: active/" "${SESSION_DIR}/${session_name}.yaml"
    echo "pid: ${pid}" >> "${SESSION_DIR}/${session_name}.yaml"
    
    # Verify connection
    sleep 2
    if ! kill -0 "${pid}" 2>/dev/null; then
        echo "${ERROR} Failed to start port-forward for ${session_name}"
        cleanup_session "${session_name}"
        return 1
    fi
    
    echo "${CHECK} Session ${session_name} active on port ${local_port}"
    echo "${INFO} Access: http://localhost:${local_port}"
    
    return 0
}

# Stop port-forward session
stop_session() {
    local session_name="$1"
    
    if [[ ! -f "${SESSION_DIR}/${session_name}.yaml" ]]; then
        echo "${ERROR} Session ${session_name} not found"
        return 1
    fi
    
    local pid_file="${PID_DIR}/${session_name}.pid"
    
    if [[ -f "${pid_file}" ]]; then
        local pid=$(cat "${pid_file}")
        if kill -0 "${pid}" 2>/dev/null; then
            echo "${INFO} Stopping session: ${session_name}"
            kill "${pid}"
            sleep 1
            # Force kill if still running
            if kill -0 "${pid}" 2>/dev/null; then
                kill -9 "${pid}" 2>/dev/null || true
            fi
        fi
    fi
    
    cleanup_session "${session_name}"
    echo "${CHECK} Session ${session_name} stopped"
}

# Cleanup session files
cleanup_session() {
    local session_name="$1"
    
    rm -f "${SESSION_DIR}/${session_name}.yaml"
    rm -f "${PID_DIR}/${session_name}.pid"
    # Keep logs for troubleshooting
}

# List active sessions
list_sessions() {
    echo "${ROCKET} Starbridge Fleet Relay System - Active Sessions"
    echo "═══════════════════════════════════════════════════════════"
    
    if [[ ! -d "${SESSION_DIR}" ]] || [[ -z "$(ls -A "${SESSION_DIR}" 2>/dev/null)" ]]; then
        echo "${INFO} No active sessions"
        return 0
    fi
    
    printf "%-15s %-20s %-15s %-6s %-25s\n" "SESSION" "SERVICE" "NAMESPACE" "PORT" "STATUS"
    echo "───────────────────────────────────────────────────────────"
    
    for session_file in "${SESSION_DIR}"/*.yaml; do
        if [[ -f "${session_file}" ]]; then
            local session_name=$(basename "${session_file}" .yaml)
            local service=$(grep "^service:" "${session_file}" | cut -d' ' -f2)
            local namespace=$(grep "^namespace:" "${session_file}" | cut -d' ' -f2)
            local local_port=$(grep "^local_port:" "${session_file}" | cut -d' ' -f2)
            local pid=$(grep "^pid:" "${session_file}" | cut -d' ' -f2 2>/dev/null)
            
            local status="INACTIVE"
            if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
                status="${CHECK} ACTIVE"
            else
                status="${ERROR} INACTIVE"
            fi
            
            printf "%-15s %-20s %-15s %-6s %-25s\n" \
                "${session_name}" "${service}" "${namespace}" "${local_port}" "${status}"
        fi
    done
    
    echo "═══════════════════════════════════════════════════════════"
}

# Stop all sessions
stop_all() {
    echo "${WARNING} Stopping all SFRS sessions..."
    
    for session_file in "${SESSION_DIR}"/*.yaml; do
        if [[ -f "${session_file}" ]]; then
            local session_name=$(basename "${session_file}" .yaml)
            stop_session "${session_name}"
        fi
    done
    
    echo "${CHECK} All sessions stopped"
}

# Show session details
show_session() {
    local session_name="$1"
    
    if [[ ! -f "${SESSION_DIR}/${session_name}.yaml" ]]; then
        echo "${ERROR} Session ${session_name} not found"
        return 1
    fi
    
    echo "${ROCKET} Session Details: ${session_name}"
    echo "═══════════════════════════════════════════════════════════"
    cat "${SESSION_DIR}/${session_name}.yaml"
    echo "═══════════════════════════════════════════════════════════"
    
    # Show recent logs
    local log_file="${LOG_DIR}/${session_name}.log"
    if [[ -f "${log_file}" ]]; then
        echo ""
        echo "${INFO} Recent logs:"
        tail -10 "${log_file}"
    fi
}

# Main command dispatcher
main() {
    local command="$1"
    shift
    
    # Initialize on first run
    if [[ ! -d "${SFRS_DIR}" ]]; then
        init_sfrs
    fi
    
    case "${command}" in
        "start")
            if [[ $# -lt 4 ]]; then
                echo "Usage: sfrs start <session_name> <service> <namespace> <target_port> [local_port]"
                exit 1
            fi
            start_session "$@"
            ;;
        "stop")
            if [[ $# -lt 1 ]]; then
                echo "Usage: sfrs stop <session_name>"
                exit 1
            fi
            stop_session "$1"
            ;;
        "list"|"ls")
            list_sessions
            ;;
        "show")
            if [[ $# -lt 1 ]]; then
                echo "Usage: sfrs show <session_name>"
                exit 1
            fi
            show_session "$1"
            ;;
        "stop-all")
            stop_all
            ;;
        "init")
            init_sfrs
            ;;
        *)
            echo "${ROCKET} Starbridge Fleet Relay System (SFRS) v1.0.0"
            echo ""
            echo "Commands:"
            echo "  start <name> <service> <namespace> <target_port> [local_port]  - Start session"
            echo "  stop <name>                                                     - Stop session"
            echo "  list                                                           - List sessions"
            echo "  show <name>                                                    - Show session details"
            echo "  stop-all                                                       - Stop all sessions"
            echo "  init                                                           - Initialize SFRS"
            echo ""
            echo "Examples:"
            echo "  sfrs start n8n n8n-service n8n-prod 5678"
            echo "  sfrs start webserver starbridge-webserver-service starbridge-platform 80"
            echo "  sfrs list"
            echo "  sfrs stop n8n"
            ;;
    esac
}

# Execute main function
main "$@"