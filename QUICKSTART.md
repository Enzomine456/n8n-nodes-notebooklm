# 🚀 Quick Start - n8n-nodes-notebooklm

## Instalação em 30 segundos

### 1. Execute o comando Docker
```bash
docker run -p 5678:5678 enzomine456/n8n-notebooklm:latest
```

### 2. Acesse o n8n
- **URL**: http://localhost:5678
- **Usuário**: admin
- **Senha**: admin123

### 3. Configure as credenciais do NotebookLM
1. Vá em **Settings** > **Credentials**
2. Clique em **Add Credential**
3. Selecione **NotebookLM API**
4. Configure sua API Key ou Service Account JSON

### 4. Teste o node
1. Crie um novo workflow
2. Adicione o node **NotebookLM**
3. Configure a operação desejada
4. Execute o workflow

## Usando Docker Compose (Recomendado)

### 1. Baixe o arquivo de configuração
```bash
curl -O https://raw.githubusercontent.com/Enzomine456/n8n-nodes-notebooklm/main/docker-compose.public.yml
```

### 2. Execute o ambiente
```bash
docker-compose -f docker-compose.public.yml up -d
```

### 3. Acesse o n8n
- **URL**: http://localhost:5678
- **Usuário**: admin
- **Senha**: admin123

## Exemplo de Workflow

### Criar Notebook e Fazer Upload
```json
{
  "nodes": [
    {
      "name": "Create Notebook",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "createNotebook",
        "title": "Meu Notebook"
      }
    },
    {
      "name": "Upload Document",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "uploadDocument",
        "notebookId": "={{$json.name}}",
        "fileProperty": "data"
      }
    },
    {
      "name": "Ask Question",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "ask",
        "notebookId": "={{$json.name}}",
        "prompt": "Faça um resumo deste documento"
      }
    }
  ]
}
```

## Operações Disponíveis

- **Create Notebook** - Criar um novo notebook
- **Get Notebook** - Obter informações de um notebook
- **Ask Notebook** - Fazer perguntas ao notebook
- **Upload Document** - Fazer upload de documentos
- **List Notebooks** - Listar todos os notebooks
- **Delete Notebook** - Deletar um notebook

## Configuração de Credenciais

### Método 1: API Key (Mais Simples)
1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Ative a API do NotebookLM
3. Crie uma API Key
4. Configure no n8n

### Método 2: Service Account (Recomendado)
1. No Google Cloud Console, crie um Service Account
2. Baixe o arquivo JSON
3. Configure no n8n

## Troubleshooting

### Problema: Container não inicia
```bash
# Verificar logs
docker logs n8n-notebooklm

# Verificar se a porta está em uso
netstat -tulpn | grep 5678
```

### Problema: Node não aparece
1. Verifique se as credenciais estão configuradas
2. Reinicie o container
3. Verifique os logs do n8n

### Problema: Erro de autenticação
1. Verifique se a API Key está correta
2. Confirme se o Service Account tem as permissões necessárias
3. Teste as credenciais no Google Cloud Console

## Comandos Úteis

```bash
# Parar o container
docker stop n8n-notebooklm

# Remover o container
docker rm n8n-notebooklm

# Ver logs em tempo real
docker logs -f n8n-notebooklm

# Acessar o container
docker exec -it n8n-notebooklm sh
```

## Próximos Passos

1. **Configure suas credenciais** do NotebookLM
2. **Importe um workflow de exemplo** da pasta `workflows/examples/`
3. **Teste as operações** do node
4. **Crie seus próprios workflows**

## Suporte

- **Documentação completa**: [README.md](README.md)
- **Guia detalhado**: [USAGE.md](USAGE.md)
- **Issues**: [GitHub Issues](https://github.com/Enzomine456/n8n-nodes-notebooklm/issues)
- **Exemplos**: [workflows/examples/](workflows/examples/)

---

**Autor**: Enzo Luis (Enzomine456)  
**Licença**: MIT  
**Versão**: 0.2.0
