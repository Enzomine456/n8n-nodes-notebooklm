#!/bin/bash

# Script para publicar n8n-nodes-notebooklm no Docker Hub
# Autor: Enzo Luis (Enzomine456)

set -e  # Exit on any error

echo "🐳 Publicando n8n-nodes-notebooklm no Docker Hub..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    error "package.json não encontrado. Execute este script no diretório raiz do projeto."
fi

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    error "Docker não está instalado. Instale o Docker primeiro."
fi

# Verificar se está logado no Docker Hub
if ! docker info | grep -q "Username"; then
    warning "Você não está logado no Docker Hub. Faça login primeiro:"
    echo "docker login"
    echo "Depois execute este script novamente."
    exit 1
fi

# Obter informações do projeto
PROJECT_NAME="n8n-nodes-notebooklm"
VERSION=$(node -p "require('./package.json').version")
DOCKER_USERNAME=${DOCKER_USERNAME:-"enzoluis275"}  # Substitua pelo seu username do Docker Hub

log "Projeto: $PROJECT_NAME"
log "Versão: $VERSION"
log "Docker Hub Username: $DOCKER_USERNAME"

# Build da imagem do node
log "🔨 Construindo imagem do node..."
docker build -t $DOCKER_USERNAME/$PROJECT_NAME:$VERSION .
docker build -t $DOCKER_USERNAME/$PROJECT_NAME:latest .

success "Imagem do node construída"

# Build da imagem n8n customizada
log "🔨 Construindo imagem n8n customizada..."
docker build -f n8n.dockerfile -t $DOCKER_USERNAME/n8n-notebooklm:$VERSION .
docker build -f n8n.dockerfile -t $DOCKER_USERNAME/n8n-notebooklm:latest .

success "Imagem n8n customizada construída"

# Testar as imagens localmente
log "🧪 Testando imagens localmente..."

# Testar imagem do node
if docker run --rm $DOCKER_USERNAME/$PROJECT_NAME:$VERSION node --version; then
    success "Imagem do node testada com sucesso"
else
    warning "Falha ao testar imagem do node"
fi

# Publicar no Docker Hub
log "📤 Publicando no Docker Hub..."

# Publicar imagem do node
log "Publicando $DOCKER_USERNAME/$PROJECT_NAME:$VERSION..."
docker push $DOCKER_USERNAME/$PROJECT_NAME:$VERSION

log "Publicando $DOCKER_USERNAME/$PROJECT_NAME:latest..."
docker push $DOCKER_USERNAME/$PROJECT_NAME:latest

# Publicar imagem n8n customizada
log "Publicando $DOCKER_USERNAME/n8n-notebooklm:$VERSION..."
docker push $DOCKER_USERNAME/n8n-notebooklm:$VERSION

log "Publicando $DOCKER_USERNAME/n8n-notebooklm:latest..."
docker push $DOCKER_USERNAME/n8n-notebooklm:latest

success "Todas as imagens foram publicadas no Docker Hub!"

# Criar arquivo docker-compose para uso público
log "📝 Criando docker-compose.yml para uso público..."

cat > docker-compose.public.yml << EOF
version: '3.8'

services:
  n8n-notebooklm:
    image: $DOCKER_USERNAME/n8n-notebooklm:latest
    container_name: n8n-notebooklm
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin123
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=America/Sao_Paulo
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
EOF

success "docker-compose.public.yml criado"

# Resumo final
echo ""
echo "🎉 Publicação concluída com sucesso!"
echo ""
echo "📋 Imagens publicadas:"
echo "  🐳 $DOCKER_USERNAME/$PROJECT_NAME:$VERSION"
echo "  🐳 $DOCKER_USERNAME/$PROJECT_NAME:latest"
echo "  🐳 $DOCKER_USERNAME/n8n-notebooklm:$VERSION"
echo "  🐳 $DOCKER_USERNAME/n8n-notebooklm:latest"
echo ""
echo "🚀 Como usar:"
echo ""
echo "1. Para usar apenas o node:"
echo "   docker pull $DOCKER_USERNAME/$PROJECT_NAME:latest"
echo ""
echo "2. Para usar n8n completo com o node:"
echo "   docker pull $DOCKER_USERNAME/n8n-notebooklm:latest"
echo "   docker run -p 5678:5678 $DOCKER_USERNAME/n8n-notebooklm:latest"
echo ""
echo "3. Para usar com docker-compose:"
echo "   curl -O https://raw.githubusercontent.com/Enzomine456/n8n-nodes-notebooklm/main/docker-compose.public.yml"
echo "   docker-compose -f docker-compose.public.yml up -d"
echo ""
echo "🌐 Acesse: http://localhost:5678"
echo "👤 Usuário: admin"
echo "🔑 Senha: admin123"
echo ""
echo "📚 Documentação completa:"
echo "   https://github.com/Enzomine456/n8n-nodes-notebooklm"
echo ""
echo "🐛 Problemas? Abra uma issue:"
echo "   https://github.com/Enzomine456/n8n-nodes-notebooklm/issues"
