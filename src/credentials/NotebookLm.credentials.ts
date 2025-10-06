// src/credentials/NotebookLm.credentials.ts
import type { ICredentialType, INodeProperties } from 'n8n-workflow';

export class NotebookLmApi implements ICredentialType {
  name = 'notebookLmApi';
  displayName = 'NotebookLM API';
  documentationUrl = 'https://cloud.google.com/agentspace/notebooklm-enterprise/docs';
  properties: INodeProperties[] = [
    {
      displayName: 'Auth Method',
      name: 'authMethod',
      type: 'options',
      options: [
        { name: 'API Key', value: 'apiKey' },
        { name: 'Service Account JSON', value: 'serviceAccount' },
      ],
      default: 'apiKey',
    },
    {
      displayName: 'API Key',
      name: 'apiKey',
      type: 'string',
      default: '',
      displayOptions: {
        show: {
          authMethod: ['apiKey'],
        },
      },
    },
    {
      displayName: 'Service Account JSON',
      name: 'serviceAccountJson',
      type: 'json',
      default: '',
      description: 'Cole aqui o JSON do service account (usado para troca por access token).',
      displayOptions: {
        show: {
          authMethod: ['serviceAccount'],
        },
      },
    },
    {
      displayName: 'Base URL (opcional)',
      name: 'baseUrl',
      type: 'string',
      default: 'https://agents.googleapis.com/v1',
      description: 'Use se tiver um endpoint alternativo.',
    },
  ];
}
