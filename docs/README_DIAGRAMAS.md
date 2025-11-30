# 📊 Índice de Diagramas - Sistema de Agendamento Médico

Este documento serve como índice para todos os diagramas do sistema de agendamento de consultas médicas.

## 🗂️ Diagramas Disponíveis

### 1. [Diagrama de Entidade-Relacionamento (ERD)](./DIAGRAMA_ERD.md)
**Descrição:** Diagrama completo das entidades do banco de dados e seus relacionamentos.

**Conteúdo:**
- Diagrama ER completo com todas as tabelas
- Descrição de campos e tipos de dados
- Relacionamentos e cardinalidades
- Índices e chaves (PK, FK, UK)
- Matriz de relacionamentos

**Quando usar:** Para entender a estrutura do banco de dados, relacionamentos entre entidades, e como os dados são organizados.

---

### 2. [Diagrama de Arquitetura](./DIAGRAMA_ARQUITETURA.md)
**Descrição:** Visão geral da arquitetura do sistema em camadas.

**Conteúdo:**
- Arquitetura em camadas (Apresentação, API, Negócio, Dados)
- Arquitetura MVC detalhada
- Componentes do sistema (módulos)
- Stack tecnológico
- Fluxo de dados

**Quando usar:** Para entender a organização geral do sistema, tecnologias utilizadas, e como os componentes se comunicam.

---

### 3. [Diagramas de Sequência](./DIAGRAMAS_SEQUENCIA.md)
**Descrição:** Fluxos principais do sistema mostrando a interação entre componentes ao longo do tempo.

**Conteúdo:**
- Fluxo de Agendamento de Consulta
- Fluxo de Atendimento de Consulta
- Fluxo de Criação de Agenda
- Fluxo de Envio de Lembretes
- Fluxo de Cancelamento de Consulta
- Fluxo de Bloqueio de Agenda
- Fluxo de Autenticação com MFA

**Quando usar:** Para entender como diferentes partes do sistema interagem para realizar uma tarefa específica.

---

### 4. [Diagrama de Casos de Uso](./DIAGRAMA_CASOS_USO.md)
**Descrição:** Casos de uso do sistema organizados por tipo de usuário.

**Conteúdo:**
- Diagrama geral de casos de uso
- Casos de uso por ator (Paciente, Médico, Atendente, Admin)
- Descrições detalhadas dos principais casos de uso
- Relacionamentos entre casos de uso (include, extend)
- Matriz de permissões

**Quando usar:** Para entender o que cada tipo de usuário pode fazer no sistema e quais são as funcionalidades disponíveis.

---

### 5. [Diagramas de Estado](./DIAGRAMAS_ESTADO.md)
**Descrição:** Diagramas de estados das principais entidades do sistema.

**Conteúdo:**
- Diagrama de estados da Consulta
- Diagrama de estados do Horário
- Diagrama de estados do Pagamento
- Diagrama de estados do Lembrete
- Diagrama de estados do Usuário
- Diagrama de estados da Agenda
- Diagrama de estados cadastrais (Paciente/Médico)
- Regras de transição de estados

**Quando usar:** Para entender o ciclo de vida de uma entidade e as transições possíveis entre estados.

---

### 6. [Diagrama de Implantação](./DIAGRAMA_IMPLANTACAO.md)
**Descrição:** Arquitetura de infraestrutura e deployment do sistema.

**Conteúdo:**
- Diagrama de implantação em produção
- Arquitetura de containers (Docker)
- Pipeline de CI/CD com Kamal
- Infraestrutura de rede
- Configuração de ambientes (Dev, Staging, Prod)
- Estratégia de backup e disaster recovery
- Segurança e firewall
- Escalabilidade horizontal

**Quando usar:** Para entender como o sistema é implantado, escalado e mantido em produção.

---

## 📚 Documentação Adicional

Além dos diagramas, o sistema possui documentação complementar:

- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Documentação detalhada do schema do banco de dados
- **[EXEMPLOS_USO.md](./EXEMPLOS_USO.md)** - Exemplos práticos de uso via console Rails
- **[README_SISTEMA.md](../README_SISTEMA.md)** - Documentação geral do sistema

## 🎯 Guia de Navegação

### Para Desenvolvedores Novos no Projeto

1. Comece com o **[README_SISTEMA.md](../README_SISTEMA.md)** para entender o objetivo do sistema
2. Leia o **[Diagrama de Arquitetura](./DIAGRAMA_ARQUITETURA.md)** para entender a estrutura geral
3. Consulte o **[Diagrama ERD](./DIAGRAMA_ERD.md)** para entender o modelo de dados
4. Use os **[Diagramas de Sequência](./DIAGRAMAS_SEQUENCIA.md)** para entender fluxos específicos
5. Consulte os **[Exemplos de Uso](./EXEMPLOS_USO.md)** para ver código em ação

### Para Analistas de Negócio

1. Leia o **[README_SISTEMA.md](../README_SISTEMA.md)** para visão geral
2. Consulte o **[Diagrama de Casos de Uso](./DIAGRAMA_CASOS_USO.md)** para entender funcionalidades
3. Use os **[Diagramas de Sequência](./DIAGRAMAS_SEQUENCIA.md)** para entender processos de negócio
4. Consulte os **[Diagramas de Estado](./DIAGRAMAS_ESTADO.md)** para entender ciclos de vida

### Para Arquitetos de Software

1. Comece com o **[Diagrama de Arquitetura](./DIAGRAMA_ARQUITETURA.md)**
2. Revise o **[Diagrama de Implantação](./DIAGRAMA_IMPLANTACAO.md)** para entender infraestrutura
3. Analise o **[Diagrama ERD](./DIAGRAMA_ERD.md)** para validar modelo de dados
4. Use os **[Diagramas de Sequência](./DIAGRAMAS_SEQUENCIA.md)** para entender interações

### Para DevOps

1. Foque no **[Diagrama de Implantação](./DIAGRAMA_IMPLANTACAO.md)**
2. Revise a seção de CI/CD e Kamal
3. Consulte a estratégia de backup e disaster recovery
4. Verifique requisitos de infraestrutura e escalabilidade

## 🔍 Visão Geral Rápida

### Tecnologias Principais
- **Backend:** Ruby on Rails 8.0.3
- **Database:** SQLite3
- **Web Server:** Puma
- **Background Jobs:** Sidekiq + Redis
- **Deploy:** Docker + Kamal
- **Security:** BCrypt, MFA

### Módulos Principais
1. **Autenticação e Usuários** - Gestão de acesso com MFA
2. **Cadastros** - Pacientes, Médicos, Especialidades
3. **Agendamento** - Criação e gestão de agendas
4. **Consultas** - Agendamento, confirmação, atendimento
5. **Financeiro** - Pagamentos e relatórios
6. **Notificações** - Lembretes por Email, SMS, WhatsApp
7. **Convênios** - Gestão de convênios e planos
8. **Auditoria** - Log completo de ações

### Entidades Principais

```
Usuario → Paciente / Médico
           ↓
        Consulta ← Agenda ← Horário
           ↓
    Lembrete + Pagamento
```

### Fluxo Principal (Agendamento)

```
1. Paciente faz login
2. Busca médico/especialidade
3. Visualiza horários disponíveis
4. Seleciona horário
5. Confirma agendamento
6. Sistema cria consulta
7. Sistema agenda lembretes
8. Sistema envia confirmação
```

## 📝 Convenções dos Diagramas

### Cores nos Diagramas

- 🔵 **Azul claro** - Interface do usuário / Cliente
- 🟡 **Amarelo** - Controladores / API
- 🟢 **Verde** - Models / Lógica de negócio
- 🟣 **Roxo** - Banco de dados
- 🔴 **Vermelho** - Serviços externos / Integrações
- ⚪ **Cinza** - Monitoramento / Infraestrutura

### Tipos de Linhas

- `-->` Fluxo normal / Chamada síncrona
- `-.->` Fluxo assíncrono / Opcional
- `==>` Fluxo de dados
- `~~~` Associação

### Símbolos Especiais

- `[Actor]` Ator / Usuário
- `(Component)` Componente
- `[(Database)]` Banco de dados
- `{{Service}}` Serviço externo
- `[[Module]]` Módulo

## 🔄 Manutenção dos Diagramas

Os diagramas devem ser atualizados sempre que houver mudanças significativas em:

- Estrutura do banco de dados
- Arquitetura do sistema
- Novos fluxos de negócio
- Mudanças na infraestrutura
- Novos casos de uso

**Última atualização:** 15/11/2025

---

## 📞 Contato

Para dúvidas sobre os diagramas ou sugestões de melhorias, abra uma issue no repositório.

**Desenvolvido com ❤️ usando Mermaid.js**
