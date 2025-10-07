# Guia de Uso - n8n-nodes-notebooklm

## Visão Geral

Este node permite integrar o **NotebookLM** (Google's AI-powered notebook) com automações no n8n. O NotebookLM é uma ferramenta que permite criar notebooks inteligentes a partir de documentos, fazendo perguntas e obtendo respostas baseadas no conteúdo dos documentos.

## Funcionalidades Disponíveis

### 1. **Create Notebook** (Criar Notebook)
- Cria um novo notebook no NotebookLM
- **Parâmetros obrigatórios:**
  - `title`: Nome/título do notebook
- **Retorna:** Informações do notebook criado, incluindo ID

### 2. **Get Notebook** (Obter Notebook)
- Busca informações de um notebook específico
- **Parâmetros obrigatórios:**
  - `notebookId`: ID do notebook
- **Retorna:** Dados completos do notebook

### 3. **Ask Notebook** (Perguntar ao Notebook)
- Faz uma pergunta ao notebook e recebe uma resposta baseada no conteúdo
- **Parâmetros obrigatórios:**
  - `notebookId`: ID do notebook
  - `prompt`: Pergunta ou prompt para o notebook
- **Retorna:** Resposta gerada pelo AI baseada no conteúdo

### 4. **Upload Document** (Upload de Documento)
- Faz upload de um documento (PDF, DOCX, etc.) para o notebook
- **Parâmetros obrigatórios:**
  - `notebookId`: ID do notebook
  - `fileProperty`: Nome da propriedade que contém o arquivo binário
- **Parâmetros opcionais:**
  - `filename`: Nome personalizado para o arquivo
- **Retorna:** Confirmação do upload

### 5. **List Notebooks** (Listar Notebooks)
- Lista todos os notebooks disponíveis
- **Retorna:** Array com todos os notebooks

### 6. **Delete Notebook** (Deletar Notebook)
- Remove um notebook permanentemente
- **Parâmetros obrigatórios:**
  - `notebookId`: ID do notebook
- **Retorna:** Confirmação da exclusão

## Configuração de Credenciais

### Método 1: API Key (Mais Simples)
1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Ative a API do NotebookLM
3. Crie uma API Key
4. Configure no n8n:
   - **Auth Method**: API Key
   - **API Key**: Sua chave da API

### Método 2: Service Account (Recomendado para Produção)
1. No Google Cloud Console, crie um Service Account
2. Baixe o arquivo JSON do Service Account
3. Configure no n8n:
   - **Auth Method**: Service Account JSON
   - **Service Account JSON**: Cole o conteúdo do arquivo JSON

## Exemplos de Workflows

### Exemplo 1: Criar Notebook e Fazer Upload de Documento

```json
{
  "nodes": [
    {
      "name": "Create Notebook",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "createNotebook",
        "title": "Meu Documento de Estudo"
      }
    },
    {
      "name": "Upload PDF",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "uploadDocument",
        "notebookId": "={{$json.name}}",
        "fileProperty": "data"
      }
    }
  ]
}
```

### Exemplo 2: Perguntar ao Notebook

```json
{
  "nodes": [
    {
      "name": "Ask Question",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "ask",
        "notebookId": "projects/your-project/notebooks/your-notebook",
        "prompt": "Qual é o resumo dos pontos principais deste documento?"
      }
    }
  ]
}
```

### Exemplo 3: Workflow Completo - Criar, Upload, Perguntar

```json
{
  "nodes": [
    {
      "name": "Create Notebook",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "createNotebook",
        "title": "Análise de Documento"
      }
    },
    {
      "name": "Upload Document",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "uploadDocument",
        "notebookId": "={{$json.name}}",
        "fileProperty": "data",
        "filename": "documento.pdf"
      }
    },
    {
      "name": "Ask Questions",
      "type": "n8n-nodes-notebooklm.notebookLm",
      "parameters": {
        "operation": "ask",
        "notebookId": "={{$json.name}}",
        "prompt": "Faça um resumo executivo deste documento"
      }
    }
  ]
}
```

## Casos de Uso Práticos

### 1. **Análise Automática de Documentos**
- Upload automático de relatórios
- Geração de resumos executivos
- Extração de insights principais

### 2. **Sistema de Q&A Inteligente**
- Base de conhecimento automatizada
- Suporte ao cliente com IA
- FAQ inteligente baseado em documentos

### 3. **Processamento de Conteúdo**
- Análise de contratos
- Revisão de propostas
- Extração de informações específicas

## Dicas e Melhores Práticas

### 1. **Preparação de Documentos**
- Use formatos suportados: PDF, DOCX, TXT
- Documentos bem estruturados geram melhores respostas
- Evite documentos com muito ruído visual

### 2. **Formulação de Perguntas**
- Seja específico nas perguntas
- Use contexto quando necessário
- Faça perguntas abertas para insights gerais

### 3. **Gerenciamento de Notebooks**
- Use nomes descritivos para notebooks
- Organize por projeto ou tema
- Limpe notebooks antigos regularmente

### 4. **Tratamento de Erros**
- Configure `continueOnFail` para workflows robustos
- Valide IDs de notebooks antes de usar
- Monitore limites de API

## Limitações e Considerações

### 1. **Limites da API**
- Rate limits do Google Cloud
- Tamanho máximo de documentos
- Número de notebooks por projeto

### 2. **Qualidade das Respostas**
- Depende da qualidade dos documentos
- Funciona melhor com texto estruturado
- Pode ter limitações com idiomas não-inglês

### 3. **Custos**
- NotebookLM Enterprise tem custos associados
- Monitore uso para controle de gastos
- Configure alertas de billing

## Troubleshooting

### Problemas Comuns

1. **Erro de Autenticação**
   - Verifique se a API Key está correta
   - Confirme se o Service Account tem as permissões necessárias
   - Teste as credenciais no Google Cloud Console

2. **Erro de Upload**
   - Verifique se o arquivo está na propriedade binária correta
   - Confirme o formato do arquivo
   - Teste com arquivos menores primeiro

3. **Erro de Pergunta**
   - Verifique se o notebook existe
   - Confirme se há documentos no notebook
   - Teste com perguntas mais simples

### Logs e Debugging

- Ative logs detalhados no n8n
- Use o modo debug para verificar dados
- Monitore respostas da API

## Suporte e Contribuição

- **Issues**: [GitHub Issues](https://github.com/Enzomine456/n8n-nodes-notebooklm/issues)
- **Documentação**: [README.md](README.md)
- **Exemplos**: [workflows/examples/](workflows/examples/)

---

**Autor**: Enzo Luis (Enzomine456)  
**Licença**: MIT  
**Versão**: 0.2.0