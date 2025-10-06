// src/auth/googleAuth.ts
import { JWT } from 'google-auth-library';

export async function getAccessTokenFromServiceAccount(saJson: any, scopes: string[] = ['https://www.googleapis.com/auth/cloud-platform']) {
  if (!saJson || !saJson.client_email || !saJson.private_key) {
    throw new Error('Service Account JSON inválido');
  }

  const client = new JWT({
    email: saJson.client_email,
    key: saJson.private_key,
    scopes,
  });

  const res = await client.authorize() as any;
  if (!res || !res.access_token) throw new Error('Falha ao obter access token via Service Account');
  return res.access_token;
}
