# 📊 Diagrama de Entidade-Relacionamento (ERD)

Este diagrama mostra todas as entidades do banco de dados e seus relacionamentos.

## Diagrama ER Completo

```mermaid
erDiagram
    USUARIOS ||--o{ PACIENTES : "possui"
    USUARIOS ||--o{ MEDICOS : "possui"
    USUARIOS ||--o{ AUDITORIAS : "realiza"
    
    PACIENTES ||--o{ CONSULTAS : "agenda"
    PACIENTES ||--o{ PACIENTE_PLANOS : "possui"
    
    MEDICOS ||--o{ CONSULTAS : "atende"
    MEDICOS ||--o{ MEDICO_ESPECIALIDADES : "possui"
    MEDICOS ||--o{ AGENDAS : "tem"
    
    ESPECIALIDADES ||--o{ MEDICO_ESPECIALIDADES : "pertence"
    ESPECIALIDADES ||--o{ CONSULTAS : "classifica"
    
    UNIDADES ||--o{ SALAS : "contém"
    UNIDADES ||--o{ AGENDAS : "hospeda"
    UNIDADES ||--o{ CONSULTAS : "realiza"
    
    SALAS ||--o{ CONSULTAS : "acomoda"
    
    AGENDAS ||--o{ HORARIOS : "gera"
    AGENDAS ||--o{ BLOQUEIO_AGENDAS : "possui"
    
    CONSULTAS ||--o{ LEMBRETES : "dispara"
    CONSULTAS ||--o{ PAGAMENTOS : "requer"
    
    CONVENIOS ||--o{ PLANOS : "oferece"
    PLANOS ||--o{ PACIENTE_PLANOS : "cobre"
    
    USUARIOS {
        int id PK
        varchar username UK
        varchar password_digest
        varchar papel
        boolean mfa_enabled
        datetime created_at
        datetime updated_at
    }
    
    PACIENTES {
        int id PK
        varchar nome
        varchar cpf UK
        date data_nascimento
        varchar telefone
        varchar email
        varchar sexo
        varchar endereco
        int usuario_id FK
        boolean ativo
        datetime created_at
        datetime updated_at
    }
    
    MEDICOS {
        int id PK
        varchar nome
        varchar crm
        varchar uf_crm
        varchar telefone
        varchar email
        int usuario_id FK
        boolean ativo
        datetime created_at
        datetime updated_at
    }
    
    ESPECIALIDADES {
        int id PK
        varchar nome
        varchar descricao
        datetime created_at
        datetime updated_at
    }
    
    MEDICO_ESPECIALIDADES {
        int id PK
        int medico_id FK
        int especialidade_id FK
        datetime created_at
        datetime updated_at
    }
    
    UNIDADES {
        int id PK
        varchar nome
        varchar cnpj UK
        varchar endereco
        varchar telefone
        datetime created_at
        datetime updated_at
    }
    
    SALAS {
        int id PK
        int unidade_id FK
        varchar nome
        varchar recursos
        boolean ativa
        datetime created_at
        datetime updated_at
    }
    
    AGENDAS {
        int id PK
        int medico_id FK
        int unidade_id FK
        int duracao_slot_min
        date data_inicio
        date data_fim
        varchar dias_semana
        time hora_inicio
        time hora_fim
        int politica_intervalo
        boolean permite_teleconsulta
        datetime created_at
        datetime updated_at
    }
    
    BLOQUEIO_AGENDAS {
        int id PK
        int agenda_id FK
        datetime inicio
        datetime fim
        varchar motivo
        datetime created_at
        datetime updated_at
    }
    
    HORARIOS {
        int id PK
        int agenda_id FK
        datetime inicio
        datetime fim
        varchar status
        datetime created_at
        datetime updated_at
    }
    
    CONSULTAS {
        int id PK
        int paciente_id FK
        int medico_id FK
        int unidade_id FK
        int sala_id FK
        int especialidade_id FK
        datetime inicio
        datetime fim
        varchar tipo
        varchar status
        varchar origem
        text observacoes
        datetime created_at
        datetime updated_at
    }
    
    LEMBRETES {
        int id PK
        int consulta_id FK
        varchar canal
        datetime enviado_em
        varchar status
        datetime created_at
        datetime updated_at
    }
    
    CONVENIOS {
        int id PK
        varchar nome
        varchar ans
        boolean ativo
        datetime created_at
        datetime updated_at
    }
    
    PLANOS {
        int id PK
        int convenio_id FK
        varchar nome
        json regras
        datetime created_at
        datetime updated_at
    }
    
    PACIENTE_PLANOS {
        int id PK
        int paciente_id FK
        int plano_id FK
        varchar numero_carteira
        date validade
        datetime created_at
        datetime updated_at
    }
    
    PAGAMENTOS {
        int id PK
        int consulta_id FK
        decimal valor
        varchar forma
        varchar status
        datetime created_at
        datetime updated_at
    }
    
    AUDITORIAS {
        int id PK
        varchar entidade
        int id_registro
        varchar acao
        int realizado_por FK
        datetime realizado_em
        json diffs
        datetime created_at
        datetime updated_at
    }
```

## Legenda

- **PK**: Primary Key (Chave Primária)
- **FK**: Foreign Key (Chave Estrangeira)
- **UK**: Unique Key (Chave Única)
- **||--o{**: Relacionamento Um-para-Muitos
- **||--||**: Relacionamento Um-para-Um

## Cardinalidades

| Relacionamento | Descrição |
|----------------|-----------|
| Usuario → Paciente | Um usuário pode ter um paciente (1:1) |
| Usuario → Medico | Um usuário pode ter um médico (1:1) |
| Paciente → Consultas | Um paciente pode ter várias consultas (1:N) |
| Medico → Consultas | Um médico pode atender várias consultas (1:N) |
| Medico → Especialidades | Um médico pode ter várias especialidades (N:M) |
| Medico → Agendas | Um médico pode ter várias agendas (1:N) |
| Unidade → Salas | Uma unidade pode ter várias salas (1:N) |
| Agenda → Horarios | Uma agenda pode gerar vários horários (1:N) |
| Consulta → Lembretes | Uma consulta pode ter vários lembretes (1:N) |
| Consulta → Pagamentos | Uma consulta pode ter vários pagamentos (1:N) |
| Paciente → Planos | Um paciente pode ter vários planos (N:M) |
| Convenio → Planos | Um convênio oferece vários planos (1:N) |

---

**Última atualização:** 15/11/2025
