# 📚 Documentação do Schema do Banco de Dados

Este documento descreve a estrutura completa do banco de dados do Sistema de Agendamento de Consultas Médicas.

## 🗄️ Tabelas

### usuarios
Controle de acesso e autenticação dos usuários do sistema.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| username | VARCHAR(50) | Nome de usuário único |
| password_digest | VARCHAR(255) | Senha criptografada (BCrypt) gerenciada por has_secure_password |
| papel | VARCHAR | Papel do usuário (paciente, medico, atendente, admin) |
| mfa_enabled | BOOLEAN | Autenticação de dois fatores habilitada |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- UNIQUE: username

**Validações:**
- username: obrigatório, único, máximo 50 caracteres
 - password_digest: obrigatório
- papel: obrigatório, valores permitidos: paciente, medico, atendente, admin

---

### pacientes
Dados pessoais dos pacientes.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| nome | VARCHAR(150) | Nome completo do paciente |
| cpf | VARCHAR(11) | CPF único do paciente |
| data_nascimento | DATE | Data de nascimento |
| telefone | VARCHAR(20) | Telefone de contato |
| email | VARCHAR(100) | Email de contato |
| sexo | VARCHAR(1) | Sexo (M, F, O) |
| endereco | VARCHAR(255) | Endereço completo |
| usuario_id | INTEGER | Referência ao usuário |
| ativo | BOOLEAN | Status ativo/inativo |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- UNIQUE: cpf
- INDEX: usuario_id

**Relacionamentos:**
- belongs_to :usuario
- has_many :consultas
- has_many :paciente_planos
- has_many :planos (through paciente_planos)

---

### medicos
Dados profissionais dos médicos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| nome | VARCHAR(150) | Nome completo do médico |
| crm | VARCHAR(20) | Número do CRM |
| uf_crm | VARCHAR(2) | UF do CRM |
| telefone | VARCHAR(20) | Telefone de contato |
| email | VARCHAR(100) | Email de contato |
| usuario_id | INTEGER | Referência ao usuário |
| ativo | BOOLEAN | Status ativo/inativo |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- UNIQUE: (crm, uf_crm)
- INDEX: usuario_id

**Relacionamentos:**
- belongs_to :usuario
- has_many :medico_especialidades
- has_many :especialidades (through medico_especialidades)
- has_many :agendas
- has_many :consultas

---

### especialidades
Especialidades médicas disponíveis.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| nome | VARCHAR(100) | Nome da especialidade |
| descricao | VARCHAR(255) | Descrição detalhada |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- has_many :medico_especialidades
- has_many :medicos (through medico_especialidades)
- has_many :consultas

---

### medico_especialidades
Tabela de associação entre médicos e especialidades.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| medico_id | INTEGER | Referência ao médico |
| especialidade_id | INTEGER | Referência à especialidade |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- UNIQUE: (medico_id, especialidade_id)

---

### unidades
Unidades de atendimento.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| nome | VARCHAR(150) | Nome da unidade |
| cnpj | VARCHAR(14) | CNPJ único da unidade |
| endereco | VARCHAR(255) | Endereço completo |
| telefone | VARCHAR(20) | Telefone de contato |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- UNIQUE: cnpj

**Relacionamentos:**
- has_many :salas
- has_many :agendas
- has_many :consultas

---

### salas
Salas de atendimento nas unidades.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| unidade_id | INTEGER | Referência à unidade |
| nome | VARCHAR(100) | Nome da sala |
| recursos | VARCHAR(255) | Recursos disponíveis |
| ativa | BOOLEAN | Status ativa/inativa |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- belongs_to :unidade
- has_many :consultas

---

### agendas
Configuração de agenda dos médicos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| medico_id | INTEGER | Referência ao médico |
| unidade_id | INTEGER | Referência à unidade |
| duracao_slot_min | INTEGER | Duração de cada slot em minutos |
| data_inicio | DATE | Data de início da agenda |
| data_fim | DATE | Data de fim da agenda |
| dias_semana | VARCHAR(20) | Dias da semana (MON,TUE,WED...) |
| hora_inicio | TIME | Horário de início |
| hora_fim | TIME | Horário de fim |
| politica_intervalo | INTEGER | Intervalo entre consultas (minutos) |
| permite_teleconsulta | BOOLEAN | Permite teleconsultas |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- belongs_to :medico
- belongs_to :unidade
- has_many :bloqueio_agendas
- has_many :horarios

**Métodos:**
- `gerar_horarios` - Gera slots de horários baseado na configuração

---

### bloqueio_agendas
Bloqueios temporários de agenda.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| agenda_id | INTEGER | Referência à agenda |
| inicio | DATETIME | Início do bloqueio |
| fim | DATETIME | Fim do bloqueio |
| motivo | VARCHAR(255) | Motivo do bloqueio |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- belongs_to :agenda

---

### horarios
Slots de horários disponíveis nas agendas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| agenda_id | INTEGER | Referência à agenda |
| inicio | DATETIME | Início do horário |
| fim | DATETIME | Fim do horário |
| status | VARCHAR | Status (disponivel, reservado, bloqueado) |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- belongs_to :agenda

**Scopes:**
- `disponiveis` - Horários disponíveis
- `reservados` - Horários reservados
- `bloqueados` - Horários bloqueados
- `por_data(data)` - Horários de uma data específica

---

### consultas
Consultas agendadas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| paciente_id | INTEGER | Referência ao paciente |
| medico_id | INTEGER | Referência ao médico |
| unidade_id | INTEGER | Referência à unidade |
| sala_id | INTEGER | Referência à sala (opcional) |
| especialidade_id | INTEGER | Referência à especialidade (opcional) |
| inicio | DATETIME | Início da consulta |
| fim | DATETIME | Fim da consulta |
| tipo | VARCHAR | Tipo (presencial, teleconsulta) |
| status | VARCHAR | Status da consulta |
| origem | VARCHAR | Origem (app, recepcao) |
| observacoes | TEXT | Observações adicionais |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- INDEX: inicio
- INDEX: status

**Relacionamentos:**
- belongs_to :paciente
- belongs_to :medico
- belongs_to :unidade
- belongs_to :sala (optional)
- belongs_to :especialidade (optional)
- has_many :lembretes
- has_many :pagamentos

**Valores de Status:**
- `marcada` - Consulta agendada
- `confirmada` - Confirmada pelo paciente
- `em_atendimento` - Em andamento
- `concluida` - Finalizada
- `cancelada` - Cancelada
- `no_show` - Paciente não compareceu

---

### lembretes
Lembretes de consultas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| consulta_id | INTEGER | Referência à consulta |
| canal | VARCHAR | Canal (email, sms, whatsapp) |
| enviado_em | DATETIME | Data/hora de envio |
| status | VARCHAR | Status (pendente, enviado, erro) |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- INDEX: status

**Relacionamentos:**
- belongs_to :consulta

---

### convenios
Convênios médicos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| nome | VARCHAR(100) | Nome do convênio |
| ans | VARCHAR(20) | Registro ANS |
| ativo | BOOLEAN | Status ativo/inativo |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- has_many :planos

---

### planos
Planos de saúde dos convênios.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| convenio_id | INTEGER | Referência ao convênio |
| nome | VARCHAR(100) | Nome do plano |
| regras | TEXT (JSON) | Regras do plano em JSON |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Relacionamentos:**
- belongs_to :convenio
- has_many :paciente_planos
- has_many :pacientes (through paciente_planos)

---

### paciente_planos
Associação entre pacientes e planos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| paciente_id | INTEGER | Referência ao paciente |
| plano_id | INTEGER | Referência ao plano |
| numero_carteira | VARCHAR(50) | Número da carteirinha |
| validade | DATE | Data de validade |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Scopes:**
- `validos` - Planos válidos
- `vencidos` - Planos vencidos

---

### pagamentos
Controle de pagamentos das consultas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| consulta_id | INTEGER | Referência à consulta |
| valor | DECIMAL(10,2) | Valor do pagamento |
| forma | VARCHAR | Forma (pix, cartao, dinheiro) |
| status | VARCHAR | Status (pendente, aprovado, estornado) |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- INDEX: status

**Relacionamentos:**
- belongs_to :consulta

---

### auditorias
Log de auditoria do sistema.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INTEGER | Chave primária |
| entidade | VARCHAR(50) | Nome da entidade |
| id_registro | INTEGER | ID do registro afetado |
| acao | VARCHAR(50) | Ação realizada |
| realizado_por | INTEGER | Referência ao usuário |
| realizado_em | DATETIME | Data/hora da ação |
| diffs | TEXT (JSON) | Diferenças em JSON |
| created_at | DATETIME | Data de criação |
| updated_at | DATETIME | Data de atualização |

**Índices:**
- INDEX: realizado_por
- INDEX: entidade

**Relacionamentos:**
- belongs_to :usuario (foreign_key: realizado_por)

---

## 🔗 Diagrama de Relacionamentos Detalhado

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │
       ├──────────────────────┐
       │                      │
       ▼                      ▼
┌─────────────┐        ┌─────────────┐
│  Paciente   │        │   Medico    │
└──────┬──────┘        └──────┬──────┘
       │                      │
       ├───────┐              ├──────────────────┐
       │       │              │                  │
       ▼       ▼              ▼                  ▼
┌──────────┐ ┌────────┐  ┌────────┐      ┌────────────┐
│Consultas │ │Planos  │  │Agendas │      │Especialid. │
└──────────┘ └────────┘  └────────┘      └────────────┘
       │                      │
       │                      ├───────┐
       ▼                      ▼       ▼
┌──────────┐          ┌──────────┐ ┌──────────┐
│Lembretes │          │Horarios  │ │Bloqueios │
└──────────┘          └──────────┘ └──────────┘
       │
       ▼
┌──────────┐
│Pagamentos│
└──────────┘
```

## 📝 Observações

1. **Timestamps**: Todas as tabelas incluem `created_at` e `updated_at`
2. **Soft Delete**: Pacientes, Médicos e Salas possuem campo `ativo` para soft delete
3. **Validações**: Implementadas no nível da aplicação (models)
4. **Índices**: Criados para otimizar buscas frequentes
5. **Foreign Keys**: Todas as relações possuem constraints de integridade referencial
6. **JSON Fields**: `regras` (Plano) e `diffs` (Auditoria) armazenam dados em JSON

---

**Última atualização:** 02/10/2025
