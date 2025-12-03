#!/bin/bash

# Script para commitar as correções dos workflows
# Execute este arquivo ou copie os comandos abaixo

echo "🔧 Commitando correções dos workflows..."
echo ""

# Adicionar todos os arquivos modificados
git add .github/workflows/cd-develop.yml
git add .github/workflows/cd-production.yml
git add .github/workflows/deploy.yml
git add .github/workflows/sync-develop-to-main.yml
git add HOTFIX_WORKFLOW_SYNTAX.md

echo "✅ Arquivos adicionados ao staging"
echo ""

# Commit com mensagem descritiva
git commit -m "fix(ci): corrigir sintaxe de condicionais em workflows

Corrige erro de validação do GitHub Actions onde expressões com
'secrets' e 'env' em condicionais 'if:' não estavam envolvidas
em \${{ }}.

Problemas corrigidos:
- cd-develop.yml (linha 255): adicionar \${{ }} em secrets
- cd-production.yml (linha 476): adicionar \${{ }} em secrets
- deploy.yml (linha 325): adicionar \${{ }} e mudar env para secrets
- sync-develop-to-main.yml (linha 110): mudar env para secrets

Todos os workflows agora seguem a sintaxe correta do GitHub Actions.

Fixes: #<issue-number> (se aplicável)
"

echo "✅ Commit criado"
echo ""

# Mostrar o status
git status

echo ""
echo "🚀 Pronto para push! Execute:"
echo "   git push origin $(git branch --show-current)"
echo ""
echo "Ou execute:"
echo "   git push"

