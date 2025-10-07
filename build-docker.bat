@echo off
echo 🔨 Building n8n-nodes-notebooklm...

REM Build do node
call npm run build

echo 🐳 Building Docker image with n8n and custom node...

REM Build da imagem n8n com o node customizado
docker build -f n8n.dockerfile -t n8n-notebooklm:latest .

echo ✅ Build completed!
echo.
echo Para executar:
echo   docker run -p 5678:5678 n8n-notebooklm:latest
echo.
echo Para desenvolvimento:
echo   docker-compose up -d
echo.
echo Acesse: http://localhost:5678
echo Usuário: admin / Senha: admin123

pause
