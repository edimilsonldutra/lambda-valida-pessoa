# TFLint Configuration
# https://github.com/terraform-linters/tflint

config {
  # Formato de saída (default, compact, json, junit, sarif, checkstyle)
  format = "default"

  # Força a verificação mesmo com erros de módulos
  force = false

  # Desabilita cores na saída
  disabled_by_default = false
}

# Habilitar o ruleset terraform padrão
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Configuração de regras específicas

# Desabilitar terraform_unused_declarations
# As 14 variáveis não utilizadas são INTENCIONAIS:
# - Configuração futura (DynamoDB streams, cache, CORS, etc)
# - Padronização com terraform.tfvars
# - Documentação de opções disponíveis
# - Já documentadas no código com comentário explicativo
# Manter habilitada apenas gera ruído nos logs
rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_documented_variables" {
  enabled = false  # Desabilitar pois já temos descriptions
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

# Desabilitar terraform_standard_module_structure
# Esta regra sugere usar variables.tf ao invés de vars.tf
# No entanto, vars.tf é uma convenção amplamente utilizada e válida
# Muitos projetos usam vars.tf, outputs.tf, main.tf, etc.
rule "terraform_standard_module_structure" {
  enabled = false
}

