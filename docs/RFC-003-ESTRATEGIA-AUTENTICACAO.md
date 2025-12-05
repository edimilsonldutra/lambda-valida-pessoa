# RFC-003: Estratégia de Autenticação

**Status**: ✅ APROVADO  
**Data**: 2025-11-16  
**Autor**: Equipe FIAP - Fase 3  
**Decisão**: JWT (JSON Web Tokens) com HS256

---

## 📋 Sumário Executivo

Decisão sobre o mecanismo de autenticação para o sistema Lambda Valida Pessoa. Escolhido **JWT (JSON Web Tokens)** com algoritmo **HS256** para geração de tokens após validação de CPF.

---

## 🎯 Requisitos

1. **Stateless**: Sem armazenamento de sessão no servidor
2. **Escalável**: Suportar múltiplas instâncias Lambda
3. **Seguro**: Proteção contra replay attacks e falsificação
4. **Simples**: Fácil implementação e manutenção
5. **Interoperável**: Padrão da indústria, suportado em múltiplas linguagens

---

## 🔍 Opções Avaliadas

### Opção 1: JWT (JSON Web Tokens) ✅ ESCOLHIDA

#### Implementação
```java
// Geração
String token = Jwts.builder()
    .subject(customer.getCpf())
    .claim("cpf", customer.getCpf())
    .claim("name", customer.getName())
    .issuedAt(Date.from(now))
    .expiration(Date.from(now.plus(1, HOURS)))
    .signWith(secretKey) // HS256
    .compact();

// Validação (outro serviço)
Claims claims = Jwts.parser()
    .verifyWith(secretKey)
    .build()
    .parseSignedClaims(token)
    .getPayload();
```

#### Vantagens ✅
- ✅ **Stateless**: Token contém todas as informações
- ✅ **Padrão**: RFC 7519, suportado em todas as linguagens
- ✅ **Simples**: Biblioteca madura (jjwt)
- ✅ **Sem Banco**: Não requer armazenamento de sessões
- ✅ **Performance**: Validação rápida (~1ms)

#### Desvantagens ❌
- ❌ **Sem Revogação**: Não pode invalidar token antes da expiração
- ❌ **Tamanho**: Tokens são maiores que session IDs (~200-500 bytes)
- ❌ **Secret Management**: Requer rotação periódica do secret

#### Custo
- **$0**: Apenas computação (já incluída no Lambda)

---

### Opção 2: AWS Cognito

#### Implementação
- Cognito User Pool para gerenciar usuários
- Lambda integrado com Cognito
- Tokens OAuth2/OpenID Connect

#### Vantagens ✅
- ✅ **Gerenciado**: AWS gerencia autenticação completa
- ✅ **Features**: MFA, password recovery, federação
- ✅ **OAuth2**: Padrão enterprise
- ✅ **Revogação**: Suporte nativo

#### Desvantagens ❌
- ❌ **Custo**: $0.0055/MAU (monthly active user)
- ❌ **Complexidade**: Overkill para caso de uso simples
- ❌ **CPF Custom**: Requer customização (CPF não é username padrão)
- ❌ **Lock-in**: Totalmente AWS-specific

#### Custo
- **Setup**: 1.000 MAU = $5.50/mês
- **Escala**: 10.000 MAU = $55/mês

---

### Opção 3: Session-Based (Redis)

#### Implementação
- Gerar session ID após autenticação
- Armazenar em ElastiCache Redis
- Validar session ID em requisições subsequentes

#### Vantagens ✅
- ✅ **Revogação**: Fácil invalidar sessões
- ✅ **Controle**: Total controle sobre sessões
- ✅ **Stateful**: Pode armazenar estado adicional

#### Desvantagens ❌
- ❌ **Custo**: ElastiCache ~$15-30/mês (cache.t3.micro)
- ❌ **Latência**: Lookup em Redis adiciona 5-10ms
- ❌ **Complexidade**: Mais componentes para gerenciar
- ❌ **Single Point of Failure**: Redis down = auth down

#### Custo
- **ElastiCache**: $15/mês (cache.t3.micro)

---

## 📊 Matriz de Decisão

| Critério | Peso | JWT | Cognito | Session/Redis |
|----------|------|-----|---------|---------------|
| **Custo** | 25% | 10 | 5 | 6 |
| **Simplicidade** | 25% | 10 | 5 | 6 |
| **Escalabilidade** | 20% | 10 | 10 | 7 |
| **Segurança** | 15% | 8 | 10 | 9 |
| **Manutenção** | 10% | 9 | 8 | 6 |
| **Flexibilidade** | 5% | 8 | 6 | 10 |
| **TOTAL** | 100% | **9.35** | **6.95** | **6.95** |

---

## ✅ Decisão Final

### Escolha: **JWT com HS256**

**Configuração**:
- **Algoritmo**: HS256 (HMAC SHA-256)
- **Secret**: 256-bit key armazenado em variável de ambiente
- **Expiração**: 1 hora (3600 segundos)
- **Claims**: cpf, name, email, status, iat, exp

**Justificativa**:
1. **Custo Zero**: Sem custos adicionais de infraestrutura
2. **Simplicidade**: Implementação direta, sem dependências externas
3. **Stateless**: Perfeito para arquitetura serverless
4. **Padrão**: RFC 7519, amplamente adotado

### Trade-offs Aceitos
- ❌ **Sem revogação**: Aceitável (tokens de curta duração)
- ❌ **Secret rotation manual**: Planejado para fase 2

---

## 🔐 Especificação Técnica

### Token Structure
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "11144477735",
    "cpf": "11144477735",
    "name": "João Silva",
    "email": "joao@example.com",
    "status": "ACTIVE",
    "iat": 1701684000,
    "exp": 1701687600
  },
  "signature": "..."
}
```

### Secret Management
```bash
# Geração do secret (256-bit)
openssl rand -base64 32

# Armazenamento
export JWT_SECRET="your-generated-secret-key-here"

# Rotação (planejado para fase 2)
# - Manter 2 secrets ativos (current + previous)
# - Grace period de 24h durante rotação
```

### Validação em Outros Serviços
```java
// Qualquer serviço pode validar JWT
public Customer validateToken(String token) {
    try {
        Claims claims = Jwts.parser()
            .verifyWith(secretKey)
            .build()
            .parseSignedClaims(token)
            .getPayload();
        
        return new Customer(
            claims.get("cpf", String.class),
            claims.get("name", String.class),
            claims.get("email", String.class),
            claims.get("status", String.class)
        );
    } catch (JwtException e) {
        throw new UnauthorizedException("Invalid token");
    }
}
```

---

## 🛡️ Considerações de Segurança

### Mitigações Implementadas

1. **HTTPS Obrigatório**: API Gateway apenas HTTPS
2. **Expiração Curta**: 1 hora (reduz janela de ataque)
3. **Secret Seguro**: 256-bit, armazenado em variável de ambiente
4. **Validação Estrita**: Biblioteca jjwt valida assinatura, expiração

### Vulnerabilidades Conhecidas e Mitigações Futuras

| Vulnerabilidade | Risco | Mitigação Atual | Mitigação Futura |
|-----------------|-------|-----------------|------------------|
| **Token Theft** | Médio | HTTPS | Implementar refresh tokens |
| **Secret Leak** | Alto | Env vars | AWS Secrets Manager + rotação |
| **Replay Attack** | Baixo | Expiração curta | Adicionar nonce/jti |
| **XSS** | N/A | Backend-only | N/A |

---

## 🎯 Roadmap

### Fase 1 (Atual) ✅
- [x] Implementação básica JWT
- [x] HS256 com secret em env var
- [x] Expiração 1 hora

### Fase 2 (Q1 2026)
- [ ] Migrar secret para AWS Secrets Manager
- [ ] Implementar rotação automática de secrets
- [ ] Adicionar refresh tokens (expiração 7 dias)
- [ ] Implementar JTI (JWT ID) para rastreamento

### Fase 3 (Q2 2026)
- [ ] Avaliar migração para RS256 (assimétrico)
- [ ] Implementar revogação via blacklist (Redis/DynamoDB)
- [ ] Adicionar rate limiting por usuário

---

## 📚 Referências

- [JWT RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)
- [JJWT Library](https://github.com/jwtk/jjwt)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)
- [AWS Best Practices for JWT](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-with-identity-providers.html)

---

**Status**: ✅ IMPLEMENTADO  
**Aprovado por**: Equipe FIAP - Fase 3  
**Data de Aprovação**: 2025-11-20

