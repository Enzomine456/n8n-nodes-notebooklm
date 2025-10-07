// src/index.ts
import { NotebookLm } from './NotebookLm.node';
import { NotebookLmApi } from './credentials/NotebookLm.credentials';

export { NotebookLm };
export { NotebookLmApi };

// n8n requires community packages to export arrays named `nodes` and `credentials`
// containing the classes to register.
export const nodes = [NotebookLm];
export const credentials = [NotebookLmApi];