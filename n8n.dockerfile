# Dockerfile para n8n com o node NotebookLM customizado
FROM n8nio/n8n:latest

# Instalar o node customizado
USER root

# Copiar o node customizado
COPY dist/ /home/node/.n8n/custom/n8n-nodes-notebooklm/
COPY package.json /home/node/.n8n/custom/n8n-nodes-notebooklm/package.json

# Instalar dependências do node
WORKDIR /home/node/.n8n/custom/n8n-nodes-notebooklm
RUN npm install --production --ignore-scripts

# Voltar para o diretório do n8n
WORKDIR /home/node

# Configurações do n8n
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://localhost:5678/
ENV GENERIC_TIMEZONE=America/Sao_Paulo
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_ENCRYPTION_KEY=changemechangemechangemechangeme
ENV N8N_USER_FOLDER=/home/node/.n8n

# Voltar para o usuário node
USER node

# Expor a porta
EXPOSE 5678

# Comando padrão do n8n
CMD ["n8n", "start"]
