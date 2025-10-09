# � Neural Nexus - AI Fleet Command

This directory contains the Kubernetes manifests and configuration for deploying **Neural Nexus** (Ollama) AI models as part of Admiral E.C. Copilot's Genesis Architecture v2.0.0.

## 🎯 Fleet AI Capabilities

- **🧠 Multiple Model Support**: Deploy various AI models as separate pods
- **📦 Persistent Storage**: Models persist across pod restarts
- **🔗 Cross-Namespace Access**: Accessible from Workflow Nexus and other fleet services
- **⚡ GPU Support**: Optional GPU acceleration for compatible models
- **📊 Resource Management**: Automatic resource allocation based on model size
- **🖼️ Vision Models**: Support for image and video interpretation models

## 🚀 Quick Start

```bash
# Deploy a basic text model
make new-ollama-pod MODEL=llama3.1

# Deploy a vision model for images
make new-ollama-pod MODEL=llava

# Deploy with GPU support
make new-ollama-pod MODEL=codellama GPU=true

# Scale existing model
make scale-ollama MODEL=llama3.1 REPLICAS=3

# List all deployed models
make list-ollama-pods

# Cleanup specific model
make cleanup-ollama MODEL=llama3.1
```

## 📚 Supported Models

### 🗣️ Text Models
- **llama3.1** - Latest Llama model for general tasks
- **codellama** - Specialized for code generation
- **mistral** - Efficient general-purpose model
- **phi3** - Microsoft's compact model
- **gemma** - Google's lightweight model

### 🖼️ Vision Models
- **llava** - Image understanding and description
- **bakllava** - Enhanced vision model
- **moondream** - Lightweight vision model

### 🔬 Specialized Models
- **dolphin-mixtral** - Fine-tuned for instructions
- **neural-chat** - Optimized for conversations
- **starling-lm** - Advanced reasoning model

## 🔗 n8n Integration

Each deployed model is accessible via service discovery:

```
http://ollama-{MODEL_NAME}.ollama-models.svc.cluster.local:11434
```

Example n8n HTTP node configuration:
- **URL**: `http://ollama-llama3-1.ollama-models.svc.cluster.local:11434/api/generate`
- **Method**: POST
- **Body**: JSON with your prompt

## 📊 Resource Allocation

Models are automatically assigned resources based on size:

| Model Size | CPU Request | Memory Request | CPU Limit | Memory Limit |
|------------|-------------|----------------|-----------|--------------|
| Small (3B) | 1 core      | 4Gi           | 2 cores   | 6Gi          |
| Medium (7B)| 2 cores     | 8Gi           | 4 cores   | 12Gi         |
| Large (13B)| 4 cores     | 16Gi          | 6 cores   | 24Gi         |
| XL (70B+)  | 8 cores     | 32Gi          | 12 cores  | 48Gi         |

## 🎮 GPU Support

When GPU=true is specified:
- Adds NVIDIA GPU resource requests
- Includes GPU-optimized environment variables
- Enables CUDA support in the container

## 📁 Directory Structure

```
ollama_deployment/
├── README.md                 # This file
├── ollama-configmap.yaml     # Base configuration
├── ollama-pvc.yaml          # Persistent volume for models
├── ollama-deployment.yaml    # Base deployment template
└── ollama-service.yaml      # Service template
```