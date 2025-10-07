@echo off
echo Publicando n8n-nodes-notebooklm...
npm publish
echo.
echo Verificando se foi publicado...
npm view n8n-nodes-notebooklm
pause
