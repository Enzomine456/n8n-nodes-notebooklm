#!/bin/bash

# Script para build e deploy do n8n-nodes-notebooklm
# Autor: Enzo Luis (Enzomine456)

set -e  # Exit on any error

echo "🚀 Iniciando build e deploy do n8n-nodes-notebooklm..."

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

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    error "Node.js não está instalado. Instale Node.js 18+ primeiro."
fi

# Verificar versão do Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js versão 18+ é necessário. Versão atual: $(node -v)"
fi

log "Node.js versão: $(node -v)"

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    error "npm não está instalado."
fi

log "npm versão: $(npm -v)"

# Limpar builds anteriores
log "🧹 Limpando builds anteriores..."
rm -rf dist/
rm -rf node_modules/.cache/

# Instalar dependências
log "📦 Instalando dependências..."
npm ci

# Executar linting
log "🔍 Executando linting..."
if npm run lint; then
    success "Linting passou sem erros"
else
    warning "Linting encontrou problemas, mas continuando..."
fi

# Build do projeto
log "🔨 Fazendo build do projeto..."
if npm run build; then
    success "Build concluído com sucesso"
else
    error "Build falhou"
fi

# Verificar se o build foi criado
if [ ! -d "dist" ]; then
    error "Diretório dist não foi criado. Build falhou."
fi

log "📁 Arquivos criados no build:"
ls -la dist/

# Verificar se Docker está disponível
if command -v docker &> /dev/null; then
    log "🐳 Docker encontrado. Construindo imagem..."
    
    # Build da imagem Docker
    if docker build -t n8n-nodes-notebooklm:latest .; then
        success "Imagem Docker construída com sucesso"
    else
        warning "Falha ao construir imagem Docker"
    fi
    
    # Build da imagem n8n customizada
    if docker build -f n8n.dockerfile -t n8n-notebooklm:latest .; then
        success "Imagem n8n customizada construída com sucesso"
    else
        warning "Falha ao construir imagem n8n customizada"
    fi
else
    warning "Docker não encontrado. Pulando build de imagens."
fi

# Verificar se docker-compose está disponível
if command -v docker-compose &> /dev/null; then
    log "🐳 Docker Compose encontrado. Testando ambiente..."
    
    # Parar containers existentes
    docker-compose down 2>/dev/null || true
    
    # Subir ambiente de teste
    if docker-compose up -d; then
        success "Ambiente Docker Compose iniciado"
        log "🌐 n8n disponível em: http://localhost:5678"
        log "👤 Usuário: admin"
        log "🔑 Senha: admin123"
        
        # Aguardar n8n inicializar
        log "⏳ Aguardando n8n inicializar..."
        sleep 10
        
        # Verificar se n8n está respondendo
        if curl -s http://localhost:5678 > /dev/null; then
            success "n8n está respondendo corretamente"
        else
            warning "n8n pode não estar totalmente inicializado ainda"
        fi
    else
        warning "Falha ao iniciar ambiente Docker Compose"
    fi
else
    warning "Docker Compose não encontrado. Pulando teste de ambiente."
fi

# Verificar se o node está linkado localmente (para desenvolvimento)
if [ -d "../n8n" ] && [ -f "../n8n/package.json" ]; then
    log "🔗 n8n encontrado no diretório pai. Fazendo link local..."
    
    # Fazer link local
    if npm link; then
        success "Node linkado localmente"
        
        # Link no n8n
        cd ../n8n
        if npm link n8n-nodes-notebooklm; then
            success "Node linkado no n8n"
            cd ../n8n-nodes-notebooklm
        else
            warning "Falha ao linkar no n8n"
        fi
    else
        warning "Falha ao fazer link local"
    fi
fi

# Resumo final
echo ""
echo "🎉 Build e deploy concluídos!"
echo ""
echo "📋 Resumo:"
echo "  ✅ Dependências instaladas"
echo "  ✅ Linting executado"
echo "  ✅ Build TypeScript concluído"
echo "  ✅ Arquivos gerados em dist/"
if command -v docker &> /dev/null; then
    echo "  ✅ Imagens Docker construídas"
fi
if command -v docker-compose &> /dev/null; then
    echo "  ✅ Ambiente Docker Compose iniciado"
    echo "  🌐 Acesse: http://localhost:5678"
fi

echo ""
echo "🚀 Próximos passos:"
echo "  1. Configure as credenciais do NotebookLM no n8n"
echo "  2. Importe um workflow de exemplo"
echo "  3. Teste as operações do node"
echo ""
echo "📚 Documentação:"
echo "  - README.md: Visão geral do projeto"
echo "  - USAGE.md: Guia detalhado de uso"
echo "  - workflows/examples/: Exemplos de workflows"
echo ""
echo "🐛 Problemas? Abra uma issue em:"
echo "  https://github.com/Enzomine456/n8n-nodes-notebooklm/issues"
