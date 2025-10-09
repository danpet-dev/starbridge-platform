#!/bin/bash
# Starbridge Platform - Configurable Web Server
# Simple HTTP server for the Starbridge Platform showcase page

# Configuration
DEFAULT_PORT=8000
DEFAULT_ROOT="."
PORT=${WEB_PORT:-$DEFAULT_PORT}
ROOT_DIR=${WEB_ROOT:-$DEFAULT_ROOT}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -r|--root)
            ROOT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "🌟 Starbridge Platform Web Server"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -p, --port PORT     Server port (default: $DEFAULT_PORT)"
            echo "  -r, --root DIR      Root directory (default: current directory)"
            echo "  -h, --help          Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  WEB_PORT           Override default port"
            echo "  WEB_ROOT           Override root directory"
            echo ""
            echo "Examples:"
            echo "  $0                  # Start on port $DEFAULT_PORT"
            echo "  $0 -p 9000          # Start on port 9000"
            echo "  $0 -r ..            # Serve from parent directory"
            echo "  WEB_PORT=3000 $0    # Use environment variable"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "💡 Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo "🌟 Starting Starbridge Platform Web Server..."
echo "🔗 Access at: http://localhost:$PORT"
echo "📁 Serving from: $(realpath "$ROOT_DIR")"
echo "🖖 Live long and prosper!"
echo ""
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Change to the specified root directory
cd "$ROOT_DIR" || {
    echo "❌ Error: Cannot access directory '$ROOT_DIR'"
    exit 1
}

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    echo "📡 Using Python 3 HTTP server..."
    python3 -m http.server "$PORT"
elif command -v python &> /dev/null; then
    echo "📡 Using Python 2 HTTP server..."
    python -m SimpleHTTPServer "$PORT"
else
    echo "❌ Python not found. Please install Python to serve the web page."
    echo "💡 Alternative: Open index.html directly in your browser"
    exit 1
fi