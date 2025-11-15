# 🔄 Diagramas de Sequência

Este documento contém os principais fluxos do sistema em diagramas de sequência.

## 1. Fluxo de Agendamento de Consulta

```mermaid
sequenceDiagram
    actor Paciente
    participant Web as Interface Web
    participant AuthC as Auth Controller
    participant AgendC as Agendamentos Controller
    participant ConsultaC as Consultas Controller
    participant Agenda as Agenda Model
    participant Horario as Horario Model
    participant Consulta as Consulta Model
    participant Lembrete as Lembrete Model
    participant DB as Database
    
    Paciente->>Web: Acessa sistema
    Web->>AuthC: Login (username, password)
    AuthC->>DB: Valida credenciais
    DB-->>AuthC: Usuário autenticado
    AuthC-->>Web: Sessão criada
    
    Paciente->>Web: Busca especialidade
    Web->>AgendC: Lista médicos disponíveis
    AgendC->>Agenda: Busca agendas ativas
    Agenda->>DB: Query agendas
    DB-->>Agenda: Lista de agendas
    Agenda-->>AgendC: Médicos com disponibilidade
    AgendC-->>Web: Lista de médicos
    
    Paciente->>Web: Seleciona médico
    Web->>AgendC: Busca horários disponíveis
    AgendC->>Horario: horarios.disponiveis
    Horario->>DB: Query horários livres
    DB-->>Horario: Lista de horários
    Horario-->>AgendC: Horários disponíveis
    AgendC-->>Web: Lista de horários
    
    Paciente->>Web: Seleciona horário
    Web->>ConsultaC: Criar consulta
    ConsultaC->>Horario: Reserva horário
    Horario->>DB: UPDATE status = 'reservado'
    DB-->>Horario: Confirmado
    
    ConsultaC->>Consulta: Criar nova consulta
    Consulta->>DB: INSERT consulta
    DB-->>Consulta: Consulta criada
    
    ConsultaC->>Lembrete: Criar lembretes
    Lembrete->>DB: INSERT lembretes (email, SMS, WhatsApp)
    DB-->>Lembrete: Lembretes criados
    
    Lembrete-->>ConsultaC: Sucesso
    Consulta-->>ConsultaC: Consulta agendada
    ConsultaC-->>Web: Confirmação
    Web-->>Paciente: Consulta agendada com sucesso
```

## 2. Fluxo de Atendimento de Consulta

```mermaid
sequenceDiagram
    actor Atendente
    actor Medico
    participant Web as Interface Web
    participant ConsultaC as Consultas Controller
    participant Consulta as Consulta Model
    participant Pagamento as Pagamento Model
    participant Auditoria as Auditoria Model
    participant DB as Database
    
    Atendente->>Web: Acessa lista de consultas do dia
    Web->>ConsultaC: Lista consultas (data=hoje)
    ConsultaC->>Consulta: where(data=hoje)
    Consulta->>DB: Query consultas
    DB-->>Consulta: Lista de consultas
    Consulta-->>ConsultaC: Consultas do dia
    ConsultaC-->>Web: Lista formatada
    Web-->>Atendente: Exibe consultas
    
    Atendente->>Web: Confirma chegada do paciente
    Web->>ConsultaC: Atualizar status
    ConsultaC->>Consulta: update(status='confirmada')
    Consulta->>DB: UPDATE consulta
    DB-->>Consulta: Atualizado
    
    ConsultaC->>Auditoria: Registrar ação
    Auditoria->>DB: INSERT auditoria
    DB-->>Auditoria: Registrado
    
    Consulta-->>ConsultaC: Status atualizado
    ConsultaC-->>Web: Confirmação
    Web-->>Atendente: Paciente confirmado
    
    Note over Medico: Médico inicia atendimento
    
    Medico->>Web: Iniciar atendimento
    Web->>ConsultaC: Atualizar status
    ConsultaC->>Consulta: update(status='em_atendimento')
    Consulta->>DB: UPDATE consulta
    DB-->>Consulta: Atualizado
    Consulta-->>ConsultaC: Em atendimento
    ConsultaC-->>Web: Confirmação
    Web-->>Medico: Atendimento iniciado
    
    Note over Medico: Médico finaliza atendimento
    
    Medico->>Web: Finalizar consulta
    Web->>ConsultaC: Atualizar status
    ConsultaC->>Consulta: update(status='concluida')
    Consulta->>DB: UPDATE consulta
    DB-->>Consulta: Atualizado
    
    ConsultaC->>Auditoria: Registrar conclusão
    Auditoria->>DB: INSERT auditoria
    
    Consulta-->>ConsultaC: Consulta finalizada
    ConsultaC-->>Web: Confirmação
    Web-->>Medico: Consulta concluída
    
    Note over Atendente: Atendente processa pagamento
    
    Atendente->>Web: Registrar pagamento
    Web->>ConsultaC: Criar pagamento
    ConsultaC->>Pagamento: create(consulta, valor, forma)
    Pagamento->>DB: INSERT pagamento
    DB-->>Pagamento: Pagamento criado
    Pagamento-->>ConsultaC: Sucesso
    ConsultaC-->>Web: Pagamento registrado
    Web-->>Atendente: Confirmação de pagamento
```

## 3. Fluxo de Criação de Agenda

```mermaid
sequenceDiagram
    actor Admin
    participant Web as Interface Web
    participant AgendaC as Agendamentos Controller
    participant Medico as Medico Model
    participant Unidade as Unidade Model
    participant Agenda as Agenda Model
    participant Horario as Horario Model
    participant DB as Database
    
    Admin->>Web: Acessar criação de agenda
    Web->>AgendaC: Formulário nova agenda
    
    AgendaC->>Medico: Lista médicos ativos
    Medico->>DB: Query medicos ativos
    DB-->>Medico: Lista de médicos
    Medico-->>AgendaC: Médicos disponíveis
    
    AgendaC->>Unidade: Lista unidades
    Unidade->>DB: Query unidades
    DB-->>Unidade: Lista de unidades
    Unidade-->>AgendaC: Unidades disponíveis
    
    AgendaC-->>Web: Formulário com opções
    Web-->>Admin: Exibe formulário
    
    Admin->>Web: Preenche dados da agenda
    Note right of Admin: Médico, Unidade, Horários,<br/>Dias da semana, Duração slots
    
    Admin->>Web: Submete formulário
    Web->>AgendaC: Criar agenda
    
    AgendaC->>Agenda: Validar dados
    Agenda->>Agenda: Valida horários, datas, configurações
    
    alt Validação OK
        Agenda->>DB: INSERT agenda
        DB-->>Agenda: Agenda criada (id=X)
        
        Agenda->>Agenda: gerar_horarios()
        
        loop Para cada dia e slot
            Agenda->>Horario: Criar horário
            Horario->>DB: INSERT horario
            DB-->>Horario: Horário criado
        end
        
        Horario-->>Agenda: Todos horários criados
        Agenda-->>AgendaC: Agenda criada com sucesso
        AgendaC-->>Web: Confirmação
        Web-->>Admin: Agenda criada (X horários gerados)
        
    else Validação Falhou
        Agenda-->>AgendaC: Erros de validação
        AgendaC-->>Web: Lista de erros
        Web-->>Admin: Exibe erros
    end
```

## 4. Fluxo de Envio de Lembretes

```mermaid
sequenceDiagram
    participant Cron as Cron Job
    participant Job as Background Job
    participant Lembrete as Lembrete Model
    participant Consulta as Consulta Model
    participant Email as Email Service
    participant SMS as SMS Gateway
    participant WhatsApp as WhatsApp API
    participant DB as Database
    
    Note over Cron: Executa a cada hora
    
    Cron->>Job: Executar envio de lembretes
    Job->>Lembrete: Buscar lembretes pendentes
    
    Lembrete->>DB: Query lembretes pendentes<br/>para consultas nas próximas 24h
    DB-->>Lembrete: Lista de lembretes
    
    loop Para cada lembrete
        Lembrete->>Consulta: Buscar dados da consulta
        Consulta->>DB: Query consulta completa
        DB-->>Consulta: Dados da consulta
        
        alt Canal = Email
            Lembrete->>Email: Enviar email
            Email-->>Lembrete: Status de envio
            
        else Canal = SMS
            Lembrete->>SMS: Enviar SMS
            SMS-->>Lembrete: Status de envio
            
        else Canal = WhatsApp
            Lembrete->>WhatsApp: Enviar mensagem
            WhatsApp-->>Lembrete: Status de envio
        end
        
        alt Envio bem-sucedido
            Lembrete->>DB: UPDATE status='enviado'<br/>enviado_em=NOW()
            DB-->>Lembrete: Atualizado
            
        else Erro no envio
            Lembrete->>DB: UPDATE status='erro'
            DB-->>Lembrete: Atualizado
        end
    end
    
    Lembrete-->>Job: Processamento concluído
    Job-->>Cron: Finalizado
```

## 5. Fluxo de Cancelamento de Consulta

```mermaid
sequenceDiagram
    actor Usuario as Usuário (Paciente/Atendente)
    participant Web as Interface Web
    participant ConsultaC as Consultas Controller
    participant Consulta as Consulta Model
    participant Horario as Horario Model
    participant Pagamento as Pagamento Model
    participant Lembrete as Lembrete Model
    participant Auditoria as Auditoria Model
    participant DB as Database
    
    Usuario->>Web: Solicita cancelamento
    Web->>ConsultaC: Cancelar consulta (id)
    
    ConsultaC->>Consulta: Buscar consulta
    Consulta->>DB: Query consulta
    DB-->>Consulta: Dados da consulta
    
    ConsultaC->>Consulta: Validar cancelamento
    
    alt Pode cancelar
        Note right of Consulta: Verifica se consulta<br/>ainda não ocorreu
        
        Consulta->>DB: UPDATE status='cancelada'
        DB-->>Consulta: Status atualizado
        
        Consulta->>Horario: Liberar horário
        Horario->>DB: UPDATE status='disponivel'
        DB-->>Horario: Horário liberado
        
        Consulta->>Pagamento: Verificar pagamentos
        Pagamento->>DB: Query pagamentos da consulta
        DB-->>Pagamento: Lista de pagamentos
        
        alt Tem pagamento aprovado
            Pagamento->>DB: UPDATE status='estornado'
            DB-->>Pagamento: Pagamento estornado
        end
        
        Consulta->>Lembrete: Cancelar lembretes
        Lembrete->>DB: DELETE lembretes pendentes
        DB-->>Lembrete: Lembretes removidos
        
        Consulta->>Auditoria: Registrar cancelamento
        Auditoria->>DB: INSERT auditoria
        DB-->>Auditoria: Registrado
        
        Consulta-->>ConsultaC: Cancelamento realizado
        ConsultaC-->>Web: Confirmação
        Web-->>Usuario: Consulta cancelada com sucesso
        
    else Não pode cancelar
        Consulta-->>ConsultaC: Erro: Consulta já realizada
        ConsultaC-->>Web: Mensagem de erro
        Web-->>Usuario: Não é possível cancelar
    end
```

## 6. Fluxo de Bloqueio de Agenda

```mermaid
sequenceDiagram
    actor Medico
    participant Web as Interface Web
    participant AgendaC as Agendamentos Controller
    participant Agenda as Agenda Model
    participant Bloqueio as Bloqueio Agenda Model
    participant Horario as Horario Model
    participant Consulta as Consulta Model
    participant DB as Database
    
    Medico->>Web: Solicitar bloqueio de agenda
    Web->>AgendaC: Formulário de bloqueio
    
    AgendaC->>Agenda: Buscar agendas do médico
    Agenda->>DB: Query agendas
    DB-->>Agenda: Lista de agendas
    Agenda-->>AgendaC: Agendas disponíveis
    AgendaC-->>Web: Formulário preenchido
    
    Web-->>Medico: Exibe formulário
    
    Medico->>Web: Preenche período e motivo
    Note right of Medico: Data/hora início<br/>Data/hora fim<br/>Motivo
    
    Web->>AgendaC: Criar bloqueio
    AgendaC->>Bloqueio: Validar período
    
    Bloqueio->>Horario: Verificar consultas existentes
    Horario->>Consulta: Query consultas no período
    Consulta->>DB: Query consultas agendadas
    DB-->>Consulta: Lista de consultas
    
    alt Tem consultas agendadas
        Consulta-->>AgendaC: Aviso: X consultas no período
        AgendaC-->>Web: Confirmação necessária
        Web-->>Medico: Deseja reagendar consultas?
        
        Medico->>Web: Confirma bloqueio
        
        loop Para cada consulta afetada
            Web->>ConsultaC: Notificar paciente
            Note right of ConsultaC: Sistema envia<br/>notificação automática
        end
    end
    
    Bloqueio->>DB: INSERT bloqueio_agenda
    DB-->>Bloqueio: Bloqueio criado
    
    Bloqueio->>Horario: Bloquear horários
    Horario->>DB: UPDATE status='bloqueado'
    DB-->>Horario: Horários bloqueados
    
    Horario-->>Bloqueio: Horários bloqueados
    Bloqueio-->>AgendaC: Bloqueio criado
    AgendaC-->>Web: Confirmação
    Web-->>Medico: Agenda bloqueada com sucesso
```

## 7. Fluxo de Autenticação com MFA

```mermaid
sequenceDiagram
    actor Usuario
    participant Web as Interface Web
    participant AuthC as Auth Controller
    participant User as Usuario Model
    participant MFA as MFA Service
    participant DB as Database
    
    Usuario->>Web: Inserir username e senha
    Web->>AuthC: Login (username, password)
    
    AuthC->>User: Buscar usuário
    User->>DB: Query usuario by username
    DB-->>User: Dados do usuário
    
    User->>User: authenticate(password)
    
    alt Credenciais inválidas
        User-->>AuthC: Autenticação falhou
        AuthC-->>Web: Erro de autenticação
        Web-->>Usuario: Usuário ou senha incorretos
        
    else Credenciais válidas
        User-->>AuthC: Usuário autenticado
        
        alt MFA habilitado
            AuthC->>MFA: Gerar código MFA
            MFA->>MFA: Gerar token temporário
            MFA-->>AuthC: Código gerado
            
            AuthC->>Web: Solicitar código MFA
            Web-->>Usuario: Digite o código MFA
            
            Usuario->>Web: Inserir código
            Web->>AuthC: Validar código MFA
            
            AuthC->>MFA: Verificar código
            
            alt Código válido
                MFA-->>AuthC: Código correto
                AuthC->>DB: Criar sessão
                DB-->>AuthC: Sessão criada
                AuthC-->>Web: Login bem-sucedido
                Web-->>Usuario: Redirecionar para dashboard
                
            else Código inválido
                MFA-->>AuthC: Código incorreto
                AuthC-->>Web: Erro MFA
                Web-->>Usuario: Código inválido
            end
            
        else MFA desabilitado
            AuthC->>DB: Criar sessão
            DB-->>AuthC: Sessão criada
            AuthC-->>Web: Login bem-sucedido
            Web-->>Usuario: Redirecionar para dashboard
        end
    end
```

## Descrição dos Fluxos

### 1. Agendamento de Consulta
Fluxo completo desde a autenticação até a confirmação do agendamento, incluindo:
- Autenticação do paciente
- Busca de médicos e especialidades
- Verificação de disponibilidade
- Reserva de horário
- Criação de lembretes automáticos

### 2. Atendimento de Consulta
Processo de atendimento desde a confirmação da chegada até o pagamento:
- Confirmação de chegada
- Transição de status
- Registro de auditoria
- Processamento de pagamento

### 3. Criação de Agenda
Criação de agenda pelo administrador com geração automática de slots:
- Validação de dados
- Criação da agenda
- Geração automática de horários disponíveis

### 4. Envio de Lembretes
Processo automático de envio de notificações:
- Execução via cron job
- Múltiplos canais (Email, SMS, WhatsApp)
- Controle de status de envio

### 5. Cancelamento de Consulta
Fluxo completo de cancelamento com todas as implicações:
- Liberação de horário
- Estorno de pagamento
- Cancelamento de lembretes
- Registro de auditoria

### 6. Bloqueio de Agenda
Bloqueio temporário de agenda (férias, reuniões):
- Verificação de consultas existentes
- Notificação de pacientes afetados
- Bloqueio de horários

### 7. Autenticação com MFA
Processo de login com autenticação de dois fatores:
- Validação de credenciais
- Geração e validação de código MFA
- Criação de sessão

---

**Última atualização:** 15/11/2025
