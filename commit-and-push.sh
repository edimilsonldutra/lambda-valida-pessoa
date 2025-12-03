#!/bin/bash

# ============================================================================
# SCRIPT DE DEPLOY - CORREÇÃO FINAL DOS WORKFLOWS
# ============================================================================
# Este script vai commitar e fazer push das correções dos workflows
# Execute com: bash commit-and-push.sh
# ============================================================================

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🔧 COMMITANDO CORREÇÕES DOS WORKFLOWS                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Verificar se estamos no repositório correto
if [ ! -d ".git" ]; then
    echo "❌ ERRO: Este script deve ser executado na raiz do repositório"
    exit 1
fi

echo "📂 Repositório: $(basename $(pwd))"
echo "🌿 Branch atual: $(git branch --show-current)"
echo ""

# Mostrar arquivos que serão commitados
echo "📝 Arquivos modificados:"
git status --short .github/workflows/
echo ""

# Adicionar arquivos
echo "➕ Adicionando arquivos ao staging..."
git add .github/workflows/cd-develop.yml
git add .github/workflows/cd-production.yml
git add .github/workflows/deploy.yml
git add .github/workflows/sync-develop-to-main.yml

# Adicionar documentação
git add HOTFIX_WORKFLOW_SYNTAX.md 2>/dev/null || true
git add CHECKLIST_DEPLOY.md 2>/dev/null || true

echo "✅ Arquivos adicionados"
echo ""

# Criar commit
echo "💾 Criando commit..."
git commit -m "fix(ci): corrigir sintaxe de condicionais if com secrets

Corrige erro de validação do GitHub Actions onde expressões com
'secrets' em condicionais 'if:' não estavam envolvidas em \${{ }}.

Arquivos corrigidos:
- cd-develop.yml (linha 255): if: \${{ secrets.SLACK_WEBHOOK_URL }}
- cd-production.yml (linha 476): if: \${{ secrets.SLACK_WEBHOOK_URL }}
- deploy.yml (linha 325): if: \${{ secrets.SLACK_WEBHOOK_URL }}
- sync-develop-to-main.yml (linha 110): if: \${{ secrets.SLACK_WEBHOOK_URL }}

Todos os workflows agora seguem a sintaxe correta do GitHub Actions.
Testado e validado - 0 erros de sintaxe.

Resolves: Invalid workflow file error
"

if [ $? -eq 0 ]; then
    echo "✅ Commit criado com sucesso"
    echo ""

    # Perguntar antes de fazer push
    echo "🚀 Pronto para fazer PUSH?"
    echo "   Branch: $(git branch --show-current)"
    echo "   Remote: $(git remote get-url origin 2>/dev/null || echo 'N/A')"
    echo ""
    read -p "Fazer push agora? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📤 Fazendo push..."
        git push origin $(git branch --show-current)

        if [ $? -eq 0 ]; then
            echo ""
            echo "╔══════════════════════════════════════════════════════════╗"
            echo "║  ✅ PUSH REALIZADO COM SUCESSO!                          ║"
            echo "╚══════════════════════════════════════════════════════════╝"
            echo ""
            echo "🎯 Próximos passos:"
            echo "  1. Vá para GitHub Actions no seu repositório"
            echo "  2. Verifique que os workflows estão sendo executados"
            echo "  3. Confirme que não há mais erros de validação"
            echo ""
            echo "🔗 Link direto:"
            echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
            echo ""
        else
            echo "❌ ERRO ao fazer push"
            echo "   Verifique suas credenciais e conexão"
            exit 1
        fi
    else
        echo ""
        echo "⏸️  Push cancelado"
        echo "   Para fazer push manualmente execute:"
        echo "   git push origin $(git branch --show-current)"
        echo ""
    fi
else
    echo "❌ ERRO ao criar commit"
    echo "   Verifique se há conflitos ou arquivos não rastreados"
    exit 1
fi

echo "✅ Processo concluído!"

