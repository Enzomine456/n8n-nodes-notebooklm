@echo off
REM Script para publicar n8n-nodes-notebooklm no Docker Hub (Windows)
REM Autor: Enzo Luis (Enzomine456)

setlocal enabledelayedexpansion

echo 🐳 Publicando n8n-nodes-notebooklm no Docker Hub...

REM Verificar se estamos no diretório correto
if not exist "package.json" (
    echo [ERROR] package.json não encontrado. Execute este script no diretório raiz do projeto.
    exit /b 1
)

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker não está instalado. Instale o Docker primeiro.
    exit /b 1
)

REM Verificar se está logado no Docker Hub
docker info | findstr "Username" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Você não está logado no Docker Hub. Faça login primeiro:
    echo docker login
    echo Depois execute este script novamente.
    exit /b 1
)

REM Obter informações do projeto
set PROJECT_NAME=n8n-nodes-notebooklm
for /f "tokens=2 delims=: " %%i in ('node -p "require('./package.json').version"') do set VERSION=%%i
set DOCKER_USERNAME=enzoluis275

echo [INFO] Projeto: %PROJECT_NAME%
echo [INFO] Versão: %VERSION%
echo [INFO] Docker Hub Username: %DOCKER_USERNAME%

REM Build da imagem do node
echo 🔨 Construindo imagem do node...
docker build -t %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION% .
if errorlevel 1 (
    echo [ERROR] Falha ao construir imagem do node
    exit /b 1
)

docker build -t %DOCKER_USERNAME%/%PROJECT_NAME%:latest .
if errorlevel 1 (
    echo [ERROR] Falha ao construir imagem do node (latest)
    exit /b 1
)

echo [SUCCESS] Imagem do node construída

REM Build da imagem n8n customizada
echo 🔨 Construindo imagem n8n customizada...
docker build -f n8n.dockerfile -t %DOCKER_USERNAME%/n8n-notebooklm:%VERSION% .
if errorlevel 1 (
    echo [ERROR] Falha ao construir imagem n8n customizada
    exit /b 1
)

docker build -f n8n.dockerfile -t %DOCKER_USERNAME%/n8n-notebooklm:latest .
if errorlevel 1 (
    echo [ERROR] Falha ao construir imagem n8n customizada (latest)
    exit /b 1
)

echo [SUCCESS] Imagem n8n customizada construída

REM Testar as imagens localmente
echo 🧪 Testando imagens localmente...

REM Testar imagem do node
docker run --rm %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION% node --version
if errorlevel 1 (
    echo [WARNING] Falha ao testar imagem do node
) else (
    echo [SUCCESS] Imagem do node testada com sucesso
)

REM Publicar no Docker Hub
echo 📤 Publicando no Docker Hub...

REM Publicar imagem do node
echo Publicando %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION%...
docker push %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION%
if errorlevel 1 (
    echo [ERROR] Falha ao publicar %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION%
    exit /b 1
)

echo Publicando %DOCKER_USERNAME%/%PROJECT_NAME%:latest...
docker push %DOCKER_USERNAME%/%PROJECT_NAME%:latest
if errorlevel 1 (
    echo [ERROR] Falha ao publicar %DOCKER_USERNAME%/%PROJECT_NAME%:latest
    exit /b 1
)

REM Publicar imagem n8n customizada
echo Publicando %DOCKER_USERNAME%/n8n-notebooklm:%VERSION%...
docker push %DOCKER_USERNAME%/n8n-notebooklm:%VERSION%
if errorlevel 1 (
    echo [ERROR] Falha ao publicar %DOCKER_USERNAME%/n8n-notebooklm:%VERSION%
    exit /b 1
)

echo Publicando %DOCKER_USERNAME%/n8n-notebooklm:latest...
docker push %DOCKER_USERNAME%/n8n-notebooklm:latest
if errorlevel 1 (
    echo [ERROR] Falha ao publicar %DOCKER_USERNAME%/n8n-notebooklm:latest
    exit /b 1
)

echo [SUCCESS] Todas as imagens foram publicadas no Docker Hub!

REM Criar arquivo docker-compose para uso público
echo 📝 Criando docker-compose.yml para uso público...

(
echo version: '3.8'
echo.
echo services:
echo   n8n-notebooklm:
echo     image: %DOCKER_USERNAME%/n8n-notebooklm:latest
echo     container_name: n8n-notebooklm
echo     restart: unless-stopped
echo     ports:
echo       - "5678:5678"
echo     environment:
echo       - N8N_BASIC_AUTH_ACTIVE=true
echo       - N8N_BASIC_AUTH_USER=admin
echo       - N8N_BASIC_AUTH_PASSWORD=admin123
echo       - N8N_HOST=localhost
echo       - N8N_PORT=5678
echo       - N8N_PROTOCOL=http
echo       - WEBHOOK_URL=http://localhost:5678/
echo       - GENERIC_TIMEZONE=America/Sao_Paulo
echo     volumes:
echo       - n8n_data:/home/node/.n8n
echo.
echo volumes:
echo   n8n_data:
) > docker-compose.public.yml

echo [SUCCESS] docker-compose.public.yml criado

REM Resumo final
echo.
echo 🎉 Publicação concluída com sucesso!
echo.
echo 📋 Imagens publicadas:
echo   🐳 %DOCKER_USERNAME%/%PROJECT_NAME%:%VERSION%
echo   🐳 %DOCKER_USERNAME%/%PROJECT_NAME%:latest
echo   🐳 %DOCKER_USERNAME%/n8n-notebooklm:%VERSION%
echo   🐳 %DOCKER_USERNAME%/n8n-notebooklm:latest
echo.
echo 🚀 Como usar:
echo.
echo 1. Para usar apenas o node:
echo    docker pull %DOCKER_USERNAME%/%PROJECT_NAME%:latest
echo.
echo 2. Para usar n8n completo com o node:
echo    docker pull %DOCKER_USERNAME%/n8n-notebooklm:latest
echo    docker run -p 5678:5678 %DOCKER_USERNAME%/n8n-notebooklm:latest
echo.
echo 3. Para usar com docker-compose:
echo    curl -O https://raw.githubusercontent.com/Enzomine456/n8n-nodes-notebooklm/main/docker-compose.public.yml
echo    docker-compose -f docker-compose.public.yml up -d
echo.
echo 🌐 Acesse: http://localhost:5678
echo 👤 Usuário: admin
echo 🔑 Senha: admin123
echo.
echo 📚 Documentação completa:
echo    https://github.com/Enzomine456/n8n-nodes-notebooklm
echo.
echo 🐛 Problemas? Abra uma issue:
echo    https://github.com/Enzomine456/n8n-nodes-notebooklm/issues

pause
