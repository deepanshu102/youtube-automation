#!/bin/bash

# macOS Podman + ComfyUI Diagnostic & Fix Script
# Run this on your MacBook Pro

echo "=== DIAGNOSTIC: Ollama & ComfyUI Status ==="
echo ""

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    echo "❌ PODMAN NOT FOUND"
    echo "Install with: brew install podman"
    exit 1
fi

echo "✅ Podman found: $(podman --version)"
echo ""

# Check if podman machine is running
echo "=== Checking Podman Machine ==="
if podman machine inspect podman-machine-default &> /dev/null; then
    MACHINE_STATE=$(podman machine inspect podman-machine-default | grep '"State"' | head -1)
    if [[ $MACHINE_STATE == *"running"* ]]; then
        echo "✅ Podman machine is RUNNING"
    else
        echo "❌ Podman machine is NOT running"
        echo "Starting it now..."
        podman machine start
        sleep 10
    fi
else
    echo "⚠️  Podman machine doesn't exist. Creating..."
    podman machine init
    podman machine start
    sleep 10
fi

echo ""
echo "=== Checking Running Containers ==="
podman ps -a --filter "name=ollama|name=comfyui"

echo ""
echo "=== Status Check ==="

# Check Ollama
if podman ps --filter "name=ollama" --format "{{.Names}}" | grep -q ollama; then
    if podman ps --filter "name=ollama" -q | xargs podman inspect --format '{{.State.Running}}' | grep -q true; then
        echo "✅ Ollama container is RUNNING"
        echo "   Testing: curl http://localhost:11434/api/tags"
        curl -s http://localhost:11434/api/tags | head -20 || echo "   (API response pending)"
    else
        echo "❌ Ollama container exists but is STOPPED"
        echo "   Starting it..."
        podman start ollama
        sleep 5
        echo "   Checking status..."
        curl -s http://localhost:11434/api/tags | head -10
    fi
else
    echo "❌ Ollama container NOT FOUND"
    echo "   You need to run this first:"
    echo ""
    echo "podman run -d \\\\"
    echo "  --name ollama \\\\"
    echo "  -p 11434:11434 \\\\"
    echo "  -v \\\"/Volumes/New Volume/YOUTUBE/y-automation/ollama_data:/root/.ollama\\\" \\\\"
    echo "  --restart unless-stopped \\\\"
    echo "  ollama/ollama"
    echo ""
fi

echo ""

# Check ComfyUI
if podman ps --filter "name=comfyui" --format "{{.Names}}" | grep -q comfyui; then
    if podman ps --filter "name=comfyui" -q | xargs podman inspect --format '{{.State.Running}}' | grep -q true; then
        echo "✅ ComfyUI container is RUNNING"
        echo "   Testing: curl http://localhost:8188/api/models"
        curl -s http://localhost:8188/api/models || echo "   (API response pending)"
        echo ""
        echo "   Web UI: http://localhost:8188"
    else
        echo "❌ ComfyUI container exists but is STOPPED"
        echo "   Starting it..."
        podman start comfyui
        sleep 10
        echo "   Checking status..."
        curl -s http://localhost:8188/api/models || echo "   (Still starting...)"
    fi
else
    echo "❌ ComfyUI container NOT FOUND"
    echo "   You need to run this first:"
    echo ""
    echo "podman run -d \\\\"
    echo "  --name comfyui \\\\"
    echo "  -p 8188:8188 -p 1111:1111 \\\\"
    echo "  -e WEB_PASSWORD=password123 \\\\"
    echo "  -v \\\"/Volumes/New Volume/YOUTUBE/y-automation/comfyui_data:/workspace\\\" \\\\"
    echo "  --restart unless-stopped \\\\"
    echo "  ghcr.io/ai-dock/comfyui:latest-cpu"
    echo ""
fi

echo ""
echo "=== Container Logs (Last 10 lines) ==="
echo ""

if podman ps -a --filter "name=comfyui" --format "{{.Names}}" | grep -q comfyui; then
    echo "--- ComfyUI Log ---"
    podman logs --tail=10 comfyui 2>&1 | tail -10
    echo ""
fi

if podman ps -a --filter "name=ollama" --format "{{.Names}}" | grep -q ollama; then
    echo "--- Ollama Log ---"
    podman logs --tail=10 ollama 2>&1 | tail -10
    echo ""
fi

echo "=== Summary ==="
echo ""
echo "To start fresh, run these commands:"
echo ""
echo "# Stop and remove old containers (if needed)"
echo "podman stop ollama comfyui"
echo "podman rm ollama comfyui"
echo ""
echo "# Start Ollama"
echo "podman run -d --name ollama -p 11434:11434 -v \\\"/Volumes/New Volume/YOUTUBE/y-automation/ollama_data:/root/.ollama\\\" --restart unless-stopped ollama/ollama"
echo ""
echo "# Start ComfyUI"
echo "podman run -d --name comfyui -p 8188:8188 -p 1111:1111 -e WEB_PASSWORD=password123 -v \\\"/Volumes/New Volume/YOUTUBE/y-automation/comfyui_data:/workspace\\\" --restart unless-stopped ghcr.io/ai-dock/comfyui:latest-cpu"
echo ""
echo "# Wait 30 seconds, then test:"
echo "sleep 30"
echo "curl http://localhost:11434/api/tags"
echo "curl http://localhost:8188/api/models"
echo ""
