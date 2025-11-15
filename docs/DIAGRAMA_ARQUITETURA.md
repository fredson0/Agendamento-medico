# 🏗️ Diagrama de Arquitetura do Sistema

Este diagrama mostra a arquitetura completa do sistema de agendamento médico.

## Arquitetura em Camadas

```mermaid
graph TB
    subgraph "Camada de Apresentação"
        WEB[Web Browser]
        MOBILE[Mobile App]
        PWA[Progressive Web App]
    end
    
    subgraph "Camada de API/Controladores"
        AUTH[Authentication Controller]
        DASHBOARD[Dashboard Controller]
        AGEND[Agendamentos Controller]
        CONSULT[Consultas Controller]
        PAC[Pacientes Controller]
        USER[Usuarios Controller]
        AJUDA[Ajuda Controller]
    end
    
    subgraph "Camada de Negócio/Models"
        USER_M[Usuario Model]
        PAC_M[Paciente Model]
        MED_M[Medico Model]
        CONS_M[Consulta Model]
        AGENDA_M[Agenda Model]
        HOR_M[Horario Model]
        PAG_M[Pagamento Model]
        LEM_M[Lembrete Model]
        AUD_M[Auditoria Model]
        CONV_M[Convenio Model]
        PLAN_M[Plano Model]
    end
    
    subgraph "Camada de Dados"
        DB[(SQLite Database)]
    end
    
    subgraph "Serviços Externos"
        EMAIL[Email Service]
        SMS[SMS Gateway]
        WHATS[WhatsApp API]
        PIX[PIX Payment Gateway]
    end
    
    WEB --> AUTH
    WEB --> DASHBOARD
    WEB --> AGEND
    WEB --> CONSULT
    WEB --> PAC
    
    MOBILE --> AUTH
    MOBILE --> AGEND
    MOBILE --> CONSULT
    
    PWA --> AUTH
    PWA --> DASHBOARD
    
    AUTH --> USER_M
    DASHBOARD --> CONS_M
    DASHBOARD --> PAC_M
    DASHBOARD --> MED_M
    
    AGEND --> AGENDA_M
    AGEND --> HOR_M
    AGEND --> CONS_M
    
    CONSULT --> CONS_M
    CONSULT --> PAG_M
    CONSULT --> LEM_M
    
    PAC --> PAC_M
    PAC --> PLAN_M
    
    USER --> USER_M
    USER --> AUD_M
    
    USER_M --> DB
    PAC_M --> DB
    MED_M --> DB
    CONS_M --> DB
    AGENDA_M --> DB
    HOR_M --> DB
    PAG_M --> DB
    LEM_M --> DB
    AUD_M --> DB
    CONV_M --> DB
    PLAN_M --> DB
    
    LEM_M -.-> EMAIL
    LEM_M -.-> SMS
    LEM_M -.-> WHATS
    
    PAG_M -.-> PIX
    
    style WEB fill:#e1f5ff
    style MOBILE fill:#e1f5ff
    style PWA fill:#e1f5ff
    
    style AUTH fill:#fff4e6
    style DASHBOARD fill:#fff4e6
    style AGEND fill:#fff4e6
    style CONSULT fill:#fff4e6
    style PAC fill:#fff4e6
    style USER fill:#fff4e6
    
    style USER_M fill:#e8f5e9
    style PAC_M fill:#e8f5e9
    style MED_M fill:#e8f5e9
    style CONS_M fill:#e8f5e9
    style AGENDA_M fill:#e8f5e9
    
    style DB fill:#f3e5f5
    
    style EMAIL fill:#ffebee
    style SMS fill:#ffebee
    style WHATS fill:#ffebee
    style PIX fill:#ffebee
```

## Arquitetura MVC Detalhada

```mermaid
graph LR
    subgraph "View Layer"
        V1[app/views/dashboard]
        V2[app/views/consultas]
        V3[app/views/pacientes]
        V4[app/views/agendamentos]
        V5[app/views/layouts]
    end
    
    subgraph "Controller Layer"
        C1[DashboardController]
        C2[ConsultasController]
        C3[PacientesController]
        C4[AgendamentosController]
        C5[AuthController]
    end
    
    subgraph "Model Layer"
        M1[Usuario]
        M2[Paciente]
        M3[Medico]
        M4[Consulta]
        M5[Agenda]
        M6[Horario]
        M7[Pagamento]
        M8[Lembrete]
    end
    
    subgraph "Database"
        DB[(SQLite3)]
    end
    
    V1 --> C1
    V2 --> C2
    V3 --> C3
    V4 --> C4
    
    C1 --> M1
    C1 --> M4
    
    C2 --> M4
    C2 --> M7
    C2 --> M8
    
    C3 --> M2
    
    C4 --> M5
    C4 --> M6
    
    C5 --> M1
    
    M1 --> DB
    M2 --> DB
    M3 --> DB
    M4 --> DB
    M5 --> DB
    M6 --> DB
    M7 --> DB
    M8 --> DB
```

## Componentes do Sistema

```mermaid
graph TB
    subgraph "Sistema de Agendamento Médico"
        subgraph "Módulo de Autenticação"
            A1[Gerenciamento de Usuários]
            A2[Autenticação BCrypt]
            A3[MFA - Dois Fatores]
            A4[Controle de Sessão]
        end
        
        subgraph "Módulo de Agendamento"
            B1[Gestão de Agendas]
            B2[Geração de Horários]
            B3[Bloqueio de Agendas]
            B4[Disponibilidade]
        end
        
        subgraph "Módulo de Consultas"
            C1[Agendamento de Consultas]
            C2[Status de Consultas]
            C3[Consultas Presenciais]
            C4[Teleconsultas]
        end
        
        subgraph "Módulo de Cadastro"
            D1[Cadastro de Pacientes]
            D2[Cadastro de Médicos]
            D3[Especialidades]
            D4[Unidades e Salas]
        end
        
        subgraph "Módulo Financeiro"
            E1[Registro de Pagamentos]
            E2[Formas de Pagamento]
            E3[Relatórios Financeiros]
            E4[Integração PIX]
        end
        
        subgraph "Módulo de Notificações"
            F1[Lembretes Email]
            F2[Lembretes SMS]
            F3[Lembretes WhatsApp]
            F4[Agendamento de Envios]
        end
        
        subgraph "Módulo de Convênios"
            G1[Gestão de Convênios]
            G2[Planos de Saúde]
            G3[Vínculo Paciente-Plano]
            G4[Validação de Cobertura]
        end
        
        subgraph "Módulo de Auditoria"
            H1[Log de Ações]
            H2[Rastreamento de Mudanças]
            H3[Histórico de Registros]
            H4[Relatórios de Auditoria]
        end
    end
    
    style A1 fill:#bbdefb
    style B1 fill:#c8e6c9
    style C1 fill:#fff9c4
    style D1 fill:#ffccbc
    style E1 fill:#f8bbd0
    style F1 fill:#e1bee7
    style G1 fill:#b2dfdb
    style H1 fill:#d7ccc8
```

## Stack Tecnológico

```mermaid
graph TB
    subgraph "Frontend"
        HTML[HTML5]
        CSS[CSS3]
        JS[JavaScript]
        PWA_TECH[Service Workers]
    end
    
    subgraph "Backend - Ruby on Rails 8.0"
        RAILS[Rails Framework]
        ACTIVERECORD[ActiveRecord ORM]
        ACTIONCONTROLLER[Action Controller]
        ACTIONVIEW[Action View]
        ACTIVEJOB[Active Job]
    end
    
    subgraph "Segurança"
        BCRYPT[BCrypt]
        MFA_LIB[MFA Libraries]
        CSRF[CSRF Protection]
    end
    
    subgraph "Banco de Dados"
        SQLITE[SQLite3]
    end
    
    subgraph "Containerização"
        DOCKER[Docker]
        KAMAL[Kamal Deploy]
    end
    
    HTML --> RAILS
    CSS --> RAILS
    JS --> RAILS
    PWA_TECH --> RAILS
    
    RAILS --> ACTIVERECORD
    RAILS --> ACTIONCONTROLLER
    RAILS --> ACTIONVIEW
    RAILS --> ACTIVEJOB
    
    ACTIVERECORD --> SQLITE
    
    ACTIONCONTROLLER --> BCRYPT
    ACTIONCONTROLLER --> MFA_LIB
    ACTIONCONTROLLER --> CSRF
    
    RAILS --> DOCKER
    DOCKER --> KAMAL
```

## Fluxo de Dados

```mermaid
graph LR
    USER[Usuário] -->|HTTP Request| ROUTES[Routes]
    ROUTES -->|Roteamento| CONTROLLER[Controller]
    CONTROLLER -->|Consulta/Atualiza| MODEL[Model]
    MODEL -->|SQL| DATABASE[(Database)]
    DATABASE -->|Resultado| MODEL
    MODEL -->|Dados| CONTROLLER
    CONTROLLER -->|Renderiza| VIEW[View]
    VIEW -->|HTTP Response| USER
    
    MODEL -.->|Notificações| JOBS[Background Jobs]
    JOBS -.->|Envio| EXTERNAL[Serviços Externos]
```

## Descrição dos Componentes

### Camada de Apresentação
- **Web Browser**: Interface web responsiva
- **Mobile App**: Aplicativo mobile (futuro)
- **PWA**: Progressive Web App com service workers

### Camada de Controladores
- **Auth Controller**: Autenticação e autorização
- **Dashboard Controller**: Painel principal
- **Agendamentos Controller**: Gestão de agendas
- **Consultas Controller**: Gerenciamento de consultas
- **Pacientes Controller**: Cadastro de pacientes
- **Usuarios Controller**: Administração de usuários

### Camada de Negócio
- **Models**: Lógica de negócio e validações
- **ActiveRecord**: ORM para acesso ao banco
- **Validações**: Regras de integridade
- **Scopes**: Consultas reutilizáveis

### Camada de Dados
- **SQLite3**: Banco de dados relacional
- **Migrations**: Controle de versão do schema
- **Seeds**: Dados iniciais

### Serviços Externos
- **Email Service**: Envio de notificações por email
- **SMS Gateway**: Envio de SMS
- **WhatsApp API**: Mensagens via WhatsApp
- **PIX Gateway**: Processamento de pagamentos

---

**Última atualização:** 15/11/2025
