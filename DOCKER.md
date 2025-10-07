# 🐳 Guia Docker - n8n-nodes-notebooklm

Este guia explica como usar o node NotebookLM para n8n via Docker.

## 🚀 Início Rápido

### Opção 1: Desenvolvimento com Docker Compose (Recomendado)

```bash
# Clone o repositório
git clone https://github.com/Enzomine456/n8n-nodes-notebooklm.git
cd n8n-nodes-notebooklm

# Instale as dependências
npm install

# Execute o ambiente completo
npm run dev
# ou
docker-compose up -d

# Acesse: http://localhost:5678
# Usuário: admin / Senha: admin123
```

### Opção 2: Build Manual

```bash
# Build do node
npm run build

# Build da imagem n8n com o node
npm run build:n8n

# Execute
npm run deploy
```

## 📁 Estrutura de Arquivos Docker

```
├── Dockerfile              # Para o node isolado
├── n8n.dockerfile         # Para n8n + node customizado
├── docker-compose.yml     # Ambiente de desenvolvimento
├── .dockerignore          # Arquivos ignorados no build
├── build-docker.sh        # Script de build (Linux/Mac)
├── build-docker.bat       # Script de build (Windows)
└── n8n-config.json        # Configuração do n8n
```

## 🔧 Comandos Disponíveis

### Scripts NPM
```bash
npm run docker:build        # Build da imagem do node
npm run docker:run          # Executar container do node
npm run docker:compose:up   # Subir ambiente completo
npm run docker:compose:down # Parar ambiente
npm run docker:compose:logs # Ver logs
npm run build:n8n           # Build n8n + node
npm run deploy              # Build e executar n8n + node
npm run dev                 # Desenvolvimento completo
```

### Comandos Docker Diretos
```bash
# Build da imagem n8n com node
docker build -f n8n.dockerfile -t n8n-notebooklm:latest .

# Executar n8n com node
docker run -p 5678:5678 n8n-notebooklm:latest

# Build do node isolado
docker build -t n8n-nodes-notebooklm .

# Executar node isolado
docker run -p 3000:3000 n8n-nodes-notebooklm
```

## 🏗️ Configuração de Produção

### Docker Compose para Produção

Crie um `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  n8n:
    build:
      context: .
      dockerfile: n8n.dockerfile
    container_name: n8n-notebooklm-prod
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password
      - N8N_HOST=your-domain.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://your-domain.com/
      - GENERIC_TIMEZONE=America/Sao_Paulo
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n-network

volumes:
  n8n_data:

networks:
  n8n-network:
    driver: bridge
```

### Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `N8N_BASIC_AUTH_ACTIVE` | Ativar autenticação básica | `true` |
| `N8N_BASIC_AUTH_USER` | Usuário de autenticação | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Senha de autenticação | `admin123` |
| `N8N_HOST` | Host do n8n | `localhost` |
| `N8N_PORT` | Porta do n8n | `5678` |
| `N8N_PROTOCOL` | Protocolo (http/https) | `http` |
| `WEBHOOK_URL` | URL base para webhooks | `http://localhost:5678/` |
| `GENERIC_TIMEZONE` | Fuso horário | `America/Sao_Paulo` |

## 🔍 Troubleshooting

### Node não aparece no n8n
1. Verifique se o build foi executado: `npm run build`
2. Verifique os logs: `docker-compose logs -f`
3. Verifique se o volume está montado corretamente

### Erro de permissão
```bash
# No Linux/Mac
sudo chown -R $USER:$USER .

# No Windows (PowerShell como Admin)
icacls . /grant Everyone:F /T
```

### Limpar containers e volumes
```bash
# Parar e remover containers
docker-compose down

# Remover volumes (CUIDADO: apaga dados)
docker-compose down -v

# Limpar sistema Docker
docker system prune -a
```

## 📝 Logs e Debug

```bash
# Ver logs do n8n
docker-compose logs -f n8n

# Ver logs do node
docker-compose logs -f node-dev

# Entrar no container
docker exec -it n8n-notebooklm bash

# Verificar se o node está instalado
docker exec -it n8n-notebooklm ls -la /home/node/.n8n/custom/
```

## 🚀 Deploy em Produção

### 1. Build da Imagem
```bash
npm run build:n8n
```

### 2. Tag para Registry
```bash
docker tag n8n-notebooklm:latest your-registry/n8n-notebooklm:latest
```

### 3. Push para Registry
```bash
docker push your-registry/n8n-notebooklm:latest
```

### 4. Deploy
```bash
docker run -d \
  --name n8n-notebooklm \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_PASSWORD=your_secure_password \
  -v n8n_data:/home/node/.n8n \
  your-registry/n8n-notebooklm:latest
```

## 🔐 Segurança

- **NUNCA** use senhas padrão em produção
- Configure HTTPS em produção
- Use secrets do Docker para credenciais
- Configure firewall adequadamente
- Mantenha as imagens atualizadas

## 📞 Suporte

- Issues: [GitHub Issues](https://github.com/Enzomine456/n8n-nodes-notebooklm/issues)
- Documentação: [README.md](README.md)
- Exemplos: [workflows/examples/](workflows/examples/)
