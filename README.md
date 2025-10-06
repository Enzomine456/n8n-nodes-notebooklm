# n8n-nodes-notebooklm 🧠

**Bilingual README — Português / English**

---

## Português (PT-BR)

Extensão (community node) para integrar **NotebookLM** com automações no n8n.

Funcionalidades incluídas:
- Criar notebook
- Fazer upload de documentos (PDF/DOCX)
- Fazer perguntas (“ask”)
- Listar notebooks
- Deletar notebooks

### Instalação
```bash
npm install n8n-nodes-notebooklm
```

### Desenvolvimento / Teste local
```bash
npm install
npm run build
npm link
# na pasta do n8n:
npm link n8n-nodes-notebooklm
```

### Credenciais
Suporta:
- API Key
- Service Account JSON (recomendado) — o node troca o JSON por um access token via google-auth-library

### Exemplo de workflow
Importe `workflows/examples/create-and-ask.workflow.json` no n8n.

---

## English (EN)

Community node to integrate **NotebookLM** with n8n automations.

Included features:
- Create notebooks
- Upload documents (PDF/DOCX)
- Ask questions (query)
- List notebooks
- Delete notebooks

### Install
```bash
npm install n8n-nodes-notebooklm
```

### Local development / Testing
```bash
npm install
npm run build
npm link
# in n8n folder:
npm link n8n-nodes-notebooklm
```

### Credentials
Supports:
- API Key
- Service Account JSON (recommended) — exchanged for an access token using google-auth-library

### Example workflow
Import `workflows/examples/create-and-ask.workflow.json` into n8n.

---

Author: Enzo Luis (Enzomine456) — https://github.com/Enzomine456
License: MIT
