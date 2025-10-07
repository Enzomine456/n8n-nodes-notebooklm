// src/NotebookLm.node.ts
import { IExecuteFunctions } from 'n8n-workflow';
import {
  INodeExecutionData,
  INodeType,
  INodeTypeDescription,
  ICredentialDataDecryptedObject,
  IDataObject,
} from 'n8n-workflow';

import fetch from 'node-fetch';
import { getAccessTokenFromServiceAccount } from './auth/googleAuth';
import { uploadDocumentToNotebook } from './utils/upload';

export class NotebookLm implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'NotebookLM',
    name: 'notebookLm',
    icon: 'file:notebooklm.svg',
    group: ['transform'],
    version: 1,
    description: 'Interage com NotebookLM (Google / NotebookLM Enterprise).',
    defaults: {
      name: 'NotebookLM',
      color: '#1A73E8',
    },
    inputs: ['main'],
    outputs: ['main'],
    credentials: [
      {
        name: 'notebookLmApi',
        required: true,
      },
    ],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        options: [
          { name: 'Create Notebook', value: 'createNotebook' },
          { name: 'Get Notebook', value: 'getNotebook' },
          { name: 'Ask Notebook', value: 'ask' },
          { name: 'Upload Document', value: 'uploadDocument' },
          { name: 'List Notebooks', value: 'listNotebooks' },
          { name: 'Delete Notebook', value: 'deleteNotebook' },
        ],
        default: 'ask',
      },
      {
        displayName: 'Notebook ID',
        name: 'notebookId',
        type: 'string',
        default: '',
        displayOptions: { show: { operation: ['getNotebook','ask','uploadDocument','deleteNotebook'] } },
      },
      {
        displayName: 'Question / Prompt',
        name: 'prompt',
        type: 'string',
        default: '',
        displayOptions: { show: { operation: ['ask'] } },
      },
      {
        displayName: 'Notebook Title',
        name: 'title',
        type: 'string',
        default: '',
        displayOptions: { show: { operation: ['createNotebook'] } },
      },
      {
        displayName: 'File Property Name',
        name: 'fileProperty',
        type: 'string',
        default: 'data',
        description: 'Nome da propriedade do item que contém o arquivo (quando Upload Document).',
        displayOptions: { show: { operation: ['uploadDocument'] } },
      },
      {
        displayName: 'Filename (opcional)',
        name: 'filename',
        type: 'string',
        default: '',
        displayOptions: { show: { operation: ['uploadDocument'] } },
      }
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const returnData: INodeExecutionData[] = [];

    // Validar credenciais
    const credentials = (await this.getCredentials('notebookLmApi')) as unknown as ICredentialDataDecryptedObject;
    if (!credentials) {
      throw new Error('Credenciais do NotebookLM não encontradas. Configure as credenciais primeiro.');
    }

    const baseUrl = (credentials.baseUrl as string) || 'https://agents.googleapis.com/v1';

    // Preparar autenticação
    let accessToken: string | undefined;
    if (credentials.authMethod === 'serviceAccount' && credentials.serviceAccountJson) {
      try {
        accessToken = await getAccessTokenFromServiceAccount(credentials.serviceAccountJson as any);
      } catch (error) {
        throw new Error(`Falha na autenticação com Service Account: ${(error as Error).message}`);
      }
    } else if (credentials.authMethod === 'apiKey' && !credentials.apiKey) {
      throw new Error('API Key é obrigatória quando o método de autenticação é API Key.');
    }

    for (let i = 0; i < items.length; i++) {
      const operation = this.getNodeParameter('operation', i) as string;

      try {
        if (operation === 'createNotebook') {
          const title = this.getNodeParameter('title', i) as string;
          if (!title || title.trim() === '') {
            throw new Error('Título do notebook é obrigatório.');
          }

          const body = { displayName: title.trim() };
          const url = credentials.authMethod === 'apiKey' && credentials.apiKey 
            ? `${baseUrl}/notebooks?key=${encodeURIComponent(credentials.apiKey as string)}` 
            : `${baseUrl}/notebooks`;
          
          const res = await fetch(url, {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json', 
              ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) 
            },
            body: JSON.stringify(body),
          });
          
          if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`Erro ao criar notebook: ${res.status} ${errorText}`);
          }
          
          const json = await res.json();
          returnData.push({ json: json as IDataObject });
        } else if (operation === 'getNotebook') {
          const notebookId = this.getNodeParameter('notebookId', i) as string;
          if (!notebookId || notebookId.trim() === '') {
            throw new Error('ID do notebook é obrigatório.');
          }

          const url = credentials.authMethod === 'apiKey' && credentials.apiKey 
            ? `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}?key=${encodeURIComponent(credentials.apiKey as string)}` 
            : `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}`;
          
          const res = await fetch(url, { 
            headers: { ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) } 
          });
          
          if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`Erro ao buscar notebook: ${res.status} ${errorText}`);
          }
          
          returnData.push({ json: await res.json() as IDataObject });
        } else if (operation === 'ask') {
          const notebookId = this.getNodeParameter('notebookId', i) as string;
          const prompt = this.getNodeParameter('prompt', i) as string;

          if (!notebookId || notebookId.trim() === '') {
            throw new Error('ID do notebook é obrigatório.');
          }
          if (!prompt || prompt.trim() === '') {
            throw new Error('Pergunta/prompt é obrigatório.');
          }

          const endpoint = `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}:query`;
          const body = { query: prompt.trim() };

          const url = credentials.authMethod === 'apiKey' && credentials.apiKey 
            ? `${endpoint}?key=${encodeURIComponent(credentials.apiKey as string)}` 
            : endpoint;
          
          const res = await fetch(url, {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json', 
              ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) 
            },
            body: JSON.stringify(body),
          });
          
          if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`Erro ao fazer pergunta: ${res.status} ${errorText}`);
          }
          
          returnData.push({ json: await res.json() as IDataObject });
        } else if (operation === 'uploadDocument') {
          const notebookId = this.getNodeParameter('notebookId', i) as string;
          const fileProperty = this.getNodeParameter('fileProperty', i) as string;
          const filenameParam = this.getNodeParameter('filename', i) as string;

          if (!notebookId || notebookId.trim() === '') {
            throw new Error('ID do notebook é obrigatório.');
          }
          if (!fileProperty || fileProperty.trim() === '') {
            throw new Error('Nome da propriedade do arquivo é obrigatório.');
          }

          // Obter dados binários do item
          const binary = (this.helpers && (this.helpers as any).getBinaryDataBuffer) 
            ? (this.helpers as any).getBinaryDataBuffer(i, fileProperty) 
            : undefined;
          
          if (!binary) {
            throw new Error(`Arquivo não encontrado na propriedade binária '${fileProperty}'. Verifique se o arquivo foi enviado corretamente.`);
          }

          const mimeType = (this.helpers && (this.helpers as any).getBinaryDataMimeType) 
            ? (this.helpers as any).getBinaryDataMimeType(i, fileProperty) 
            : 'application/octet-stream';
          
          const filename = filenameParam || 
            ((this.helpers && (this.helpers as any).getBinaryDataOriginalName) 
              ? (this.helpers as any).getBinaryDataOriginalName(i, fileProperty) 
              : 'document');

          try {
            const res = await uploadDocumentToNotebook(
              baseUrl, 
              notebookId, 
              binary, 
              filename, 
              mimeType, 
              accessToken, 
              credentials.authMethod === 'apiKey' ? (credentials.apiKey as string) : undefined
            );
            returnData.push({ json: res as IDataObject });
          } catch (error) {
            throw new Error(`Erro ao fazer upload do documento: ${(error as Error).message}`);
          }
        } else if (operation === 'listNotebooks') {
          const endpoint = `${baseUrl}/notebooks`;
          const url = credentials.authMethod === 'apiKey' && credentials.apiKey 
            ? `${endpoint}?key=${encodeURIComponent(credentials.apiKey as string)}` 
            : endpoint;
          
          const res = await fetch(url, { 
            headers: { ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) } 
          });
          
          if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`Erro ao listar notebooks: ${res.status} ${errorText}`);
          }
          
          returnData.push({ json: await res.json() as IDataObject });
        } else if (operation === 'deleteNotebook') {
          const notebookId = this.getNodeParameter('notebookId', i) as string;
          
          if (!notebookId || notebookId.trim() === '') {
            throw new Error('ID do notebook é obrigatório.');
          }

          const url = credentials.authMethod === 'apiKey' && credentials.apiKey 
            ? `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}?key=${encodeURIComponent(credentials.apiKey as string)}` 
            : `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}`;
          
          const res = await fetch(url, { 
            method: 'DELETE', 
            headers: { ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) } 
          });
          
          if (!res.ok) {
            const errorText = await res.text();
            throw new Error(`Erro ao deletar notebook: ${res.status} ${errorText}`);
          }
          
          returnData.push({ json: { success: true, message: 'Notebook deletado com sucesso' } as IDataObject });
        } else {
          throw new Error(`Operação não reconhecida: ${operation}`);
        }
      } catch (error) {
        if (this.continueOnFail && this.continueOnFail()) {
          returnData.push({ json: { error: (error as Error).message } });
          continue;
        }
        throw error;
      }
    }

    return [returnData];
  }
}
