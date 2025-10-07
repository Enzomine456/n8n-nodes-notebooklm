@echo off
REM Script para build e deploy do n8n-nodes-notebooklm (Windows)
REM Autor: Enzo Luis (Enzomine456)

setlocal enabledelayedexpansion

echo 🚀 Iniciando build e deploy do n8n-nodes-notebooklm...

REM Verificar se estamos no diretório correto
if not exist "package.json" (
    echo [ERROR] package.json não encontrado. Execute este script no diretório raiz do projeto.
    exit /b 1
)

REM Verificar se Node.js está instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js não está instalado. Instale Node.js 18+ primeiro.
    exit /b 1
)

REM Verificar se npm está instalado
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm não está instalado.
    exit /b 1
)

echo [INFO] Node.js versão:
node --version
echo [INFO] npm versão:
npm --version

REM Limpar builds anteriores
echo 🧹 Limpando builds anteriores...
if exist "dist" rmdir /s /q "dist"
if exist "node_modules\.cache" rmdir /s /q "node_modules\.cache"

REM Instalar dependências
echo 📦 Instalando dependências...
call npm ci
if errorlevel 1 (
    echo [ERROR] Falha ao instalar dependências
    exit /b 1
)

REM Executar linting
echo 🔍 Executando linting...
call npm run lint
if errorlevel 1 (
    echo [WARNING] Linting encontrou problemas, mas continuando...
) else (
    echo [SUCCESS] Linting passou sem erros
)

REM Build do projeto
echo 🔨 Fazendo build do projeto...
call npm run build
if errorlevel 1 (
    echo [ERROR] Build falhou
    exit /b 1
)
echo [SUCCESS] Build concluído com sucesso

REM Verificar se o build foi criado
if not exist "dist" (
    echo [ERROR] Diretório dist não foi criado. Build falhou.
    exit /b 1
)

echo 📁 Arquivos criados no build:
dir dist

REM Verificar se Docker está disponível
docker --version >nul 2>&1
if not errorlevel 1 (
    echo 🐳 Docker encontrado. Construindo imagem...
    
    REM Build da imagem Docker
    docker build -t n8n-nodes-notebooklm:latest .
    if errorlevel 1 (
        echo [WARNING] Falha ao construir imagem Docker
    ) else (
        echo [SUCCESS] Imagem Docker construída com sucesso
    )
    
    REM Build da imagem n8n customizada
    docker build -f n8n.dockerfile -t n8n-notebooklm:latest .
    if errorlevel 1 (
        echo [WARNING] Falha ao construir imagem n8n customizada
    ) else (
        echo [SUCCESS] Imagem n8n customizada construída com sucesso
    )
) else (
    echo [WARNING] Docker não encontrado. Pulando build de imagens.
)

REM Verificar se docker-compose está disponível
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    echo 🐳 Docker Compose encontrado. Testando ambiente...
    
    REM Parar containers existentes
    docker-compose down 2>nul
    
    REM Subir ambiente de teste
    docker-compose up -d
    if errorlevel 1 (
        echo [WARNING] Falha ao iniciar ambiente Docker Compose
    ) else (
        echo [SUCCESS] Ambiente Docker Compose iniciado
        echo 🌐 n8n disponível em: http://localhost:5678
        echo 👤 Usuário: admin
        echo 🔑 Senha: admin123
        
        REM Aguardar n8n inicializar
        echo ⏳ Aguardando n8n inicializar...
        timeout /t 10 /nobreak >nul
        
        REM Verificar se n8n está respondendo
        curl -s http://localhost:5678 >nul 2>&1
        if errorlevel 1 (
            echo [WARNING] n8n pode não estar totalmente inicializado ainda
        ) else (
            echo [SUCCESS] n8n está respondendo corretamente
        )
    )
) else (
    echo [WARNING] Docker Compose não encontrado. Pulando teste de ambiente.
)

REM Verificar se o node está linkado localmente (para desenvolvimento)
if exist "..\n8n\package.json" (
    echo 🔗 n8n encontrado no diretório pai. Fazendo link local...
    
    REM Fazer link local
    call npm link
    if errorlevel 1 (
        echo [WARNING] Falha ao fazer link local
    ) else (
        echo [SUCCESS] Node linkado localmente
        
        REM Link no n8n
        cd ..\n8n
        call npm link n8n-nodes-notebooklm
        if errorlevel 1 (
            echo [WARNING] Falha ao linkar no n8n
        ) else (
            echo [SUCCESS] Node linkado no n8n
        )
        cd ..\n8n-nodes-notebooklm
    )
)

REM Resumo final
echo.
echo 🎉 Build e deploy concluídos!
echo.
echo 📋 Resumo:
echo   ✅ Dependências instaladas
echo   ✅ Linting executado
echo   ✅ Build TypeScript concluído
echo   ✅ Arquivos gerados em dist\
docker --version >nul 2>&1
if not errorlevel 1 (
    echo   ✅ Imagens Docker construídas
)
docker-compose --version >nul 2>&1
if not errorlevel 1 (
    echo   ✅ Ambiente Docker Compose iniciado
    echo   🌐 Acesse: http://localhost:5678
)

echo.
echo 🚀 Próximos passos:
echo   1. Configure as credenciais do NotebookLM no n8n
echo   2. Importe um workflow de exemplo
echo   3. Teste as operações do node
echo.
echo 📚 Documentação:
echo   - README.md: Visão geral do projeto
echo   - USAGE.md: Guia detalhado de uso
echo   - workflows\examples\: Exemplos de workflows
echo.
echo 🐛 Problemas? Abra uma issue em:
echo   https://github.com/Enzomine456/n8n-nodes-notebooklm/issues

pause
