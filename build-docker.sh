#!/bin/bash

# Script para build e deploy do n8n com node NotebookLM customizado

echo "🔨 Building n8n-nodes-notebooklm..."

# Build do node
npm run build

echo "🐳 Building Docker image with n8n and custom node..."

# Build da imagem n8n com o node customizado
docker build -f n8n.dockerfile -t n8n-notebooklm:latest .

echo "✅ Build completed!"
echo ""
echo "Para executar:"
echo "  docker run -p 5678:5678 n8n-notebooklm:latest"
echo ""
echo "Para desenvolvimento:"
echo "  docker-compose up -d"
echo ""
echo "Acesse: http://localhost:5678"
echo "Usuário: admin / Senha: admin123"
