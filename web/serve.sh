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