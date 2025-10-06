// src/utils/upload.ts
import FormData from 'form-data';
import fetch from 'node-fetch';

export async function uploadDocumentToNotebook(baseUrl: string, notebookId: string, fileBuffer: Buffer, filename: string, mimeType: string, accessToken?: string, apiKey?: string) {
  // Endpoint hipotético: POST {baseUrl}/notebooks/{notebookId}:uploadDocument
  const endpoint = `${baseUrl}/notebooks/${encodeURIComponent(notebookId)}:uploadDocument`;

  const form = new FormData();
  form.append('file', fileBuffer, { filename, contentType: mimeType });

  const headers: any = form.getHeaders();
  if (accessToken) headers.Authorization = `Bearer ${accessToken}`;

  const url = apiKey ? `${endpoint}?key=${encodeURIComponent(apiKey)}` : endpoint;

  const res = await fetch(url, { method: 'POST', body: form as any, headers });
  if (!res.ok) throw new Error(`Upload falhou: ${res.status} ${await res.text()}`);
  return res.json();
}
