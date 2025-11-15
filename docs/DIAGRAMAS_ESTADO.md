# 🔄 Diagramas de Estado

Este documento apresenta os diagramas de estado das principais entidades do sistema.

## 1. Diagrama de Estados: Consulta

```mermaid
stateDiagram-v2
    [*] --> Marcada: Consulta agendada
    
    Marcada --> Confirmada: Paciente confirma presença
    Marcada --> Cancelada: Cancelamento solicitado
    Marcada --> NoShow: Paciente não compareceu
    
    Confirmada --> EmAtendimento: Médico inicia atendimento
    Confirmada --> Cancelada: Cancelamento solicitado
    Confirmada --> NoShow: Paciente não compareceu
    
    EmAtendimento --> Concluida: Médico finaliza consulta
    EmAtendimento --> Cancelada: Cancelamento excepcional
    
    Concluida --> [*]: Fim do ciclo
    Cancelada --> [*]: Fim do ciclo
    NoShow --> [*]: Fim do ciclo
    
    note right of Marcada
        Estado inicial após agendamento
        Lembretes são enviados
    end note
    
    note right of Confirmada
        Paciente confirmou presença
        Reduz taxa de no-show
    end note
    
    note right of EmAtendimento
        Atendimento em andamento
        Sala ocupada
    end note
    
    note right of Concluida
        Consulta finalizada
        Pagamento processado
    end note
    
    note right of Cancelada
        Consulta cancelada
        Horário liberado
        Pagamento estornado (se aplicável)
    end note
    
    note right of NoShow
        Paciente não compareceu
        Registrado para métricas
    end note
```

## 2. Diagrama de Estados: Horário

```mermaid
stateDiagram-v2
    [*] --> Disponivel: Horário gerado
    
    Disponivel --> Reservado: Consulta agendada
    Disponivel --> Bloqueado: Agenda bloqueada
    
    Reservado --> Disponivel: Consulta cancelada
    Reservado --> Ocupado: Consulta iniciada
    
    Ocupado --> Finalizado: Consulta concluída
    
    Bloqueado --> Disponivel: Bloqueio removido
    
    Finalizado --> [*]: Fim do ciclo
    
    note right of Disponivel
        Horário livre para agendamento
        Aparece na busca de horários
    end note
    
    note right of Reservado
        Horário reservado para consulta
        Não aparece como disponível
    end note
    
    note right of Bloqueado
        Horário bloqueado (férias, reunião)
        Não pode ser agendado
    end note
    
    note right of Ocupado
        Consulta em andamento
        Sala em uso
    end note
    
    note right of Finalizado
        Horário utilizado
        Arquivado para histórico
    end note
```

## 3. Diagrama de Estados: Pagamento

```mermaid
stateDiagram-v2
    [*] --> Pendente: Pagamento criado
    
    Pendente --> Processando: Iniciando processamento
    Pendente --> Cancelado: Consulta cancelada
    
    Processando --> Aprovado: Pagamento confirmado
    Processando --> Recusado: Pagamento negado
    Processando --> Erro: Erro no processamento
    
    Aprovado --> Estornado: Estorno solicitado
    
    Recusado --> Pendente: Tentar novamente
    Erro --> Pendente: Tentar novamente
    
    Estornado --> [*]: Fim do ciclo
    Aprovado --> [*]: Fim do ciclo
    Cancelado --> [*]: Fim do ciclo
    
    note right of Pendente
        Aguardando processamento
        Valor registrado
    end note
    
    note right of Processando
        Validando com gateway
        Processando transação
    end note
    
    note right of Aprovado
        Pagamento confirmado
        Valor creditado
    end note
    
    note right of Estornado
        Pagamento devolvido
        Consulta cancelada
    end note
```

## 4. Diagrama de Estados: Lembrete

```mermaid
stateDiagram-v2
    [*] --> Pendente: Lembrete criado
    
    Pendente --> Agendado: Agendado para envio
    Pendente --> Cancelado: Consulta cancelada
    
    Agendado --> Enviando: Hora de enviar
    
    Enviando --> Enviado: Envio bem-sucedido
    Enviando --> Erro: Falha no envio
    
    Erro --> Tentando: Tentar novamente (retry)
    Tentando --> Enviado: Sucesso na tentativa
    Tentando --> Falhou: Todas tentativas falharam
    
    Enviado --> [*]: Fim do ciclo
    Cancelado --> [*]: Fim do ciclo
    Falhou --> [*]: Fim do ciclo
    
    note right of Pendente
        Lembrete criado
        Aguardando momento de envio
    end note
    
    note right of Agendado
        Agendado para envio
        24h antes da consulta
    end note
    
    note right of Enviando
        Enviando via canal selecionado
        (Email, SMS, WhatsApp)
    end note
    
    note right of Erro
        Falha no envio
        Sistema tentará novamente
    end note
    
    note right of Enviado
        Lembrete entregue
        Timestamp registrado
    end note
```

## 5. Diagrama de Estados: Usuário

```mermaid
stateDiagram-v2
    [*] --> Criado: Usuário cadastrado
    
    Criado --> Ativo: Ativação bem-sucedida
    Criado --> Inativo: Ativação pendente
    
    Ativo --> Suspenso: Suspensão aplicada
    Ativo --> Bloqueado: Múltiplas tentativas falhas
    Ativo --> Inativo: Desativação solicitada
    
    Suspenso --> Ativo: Suspensão removida
    Suspenso --> Inativo: Desativação durante suspensão
    
    Bloqueado --> Ativo: Desbloqueio por admin
    Bloqueado --> Inativo: Desativação durante bloqueio
    
    Inativo --> Ativo: Reativação
    Inativo --> [*]: Exclusão permanente
    
    note right of Criado
        Usuário recém-cadastrado
        Senha temporária gerada
    end note
    
    note right of Ativo
        Usuário pode acessar sistema
        Todas funcionalidades disponíveis
    end note
    
    note right of Suspenso
        Acesso temporariamente suspenso
        Decisão administrativa
    end note
    
    note right of Bloqueado
        Bloqueado por segurança
        Ex: múltiplas tentativas de login
    end note
    
    note right of Inativo
        Usuário desativado
        Não pode fazer login
        Dados preservados
    end note
```

## 6. Diagrama de Estados: Agenda

```mermaid
stateDiagram-v2
    [*] --> Rascunho: Agenda sendo criada
    
    Rascunho --> Ativa: Agenda ativada
    Rascunho --> Cancelada: Criação cancelada
    
    Ativa --> Pausada: Pausa temporária
    Ativa --> Bloqueada: Bloqueio aplicado
    Ativa --> Encerrada: Fim do período
    Ativa --> Inativa: Desativação
    
    Pausada --> Ativa: Retomar agenda
    Pausada --> Inativa: Desativar durante pausa
    
    Bloqueada --> Ativa: Bloqueio removido
    Bloqueada --> Inativa: Desativar durante bloqueio
    
    Inativa --> Ativa: Reativação
    Inativa --> Arquivada: Arquivar permanentemente
    
    Encerrada --> Arquivada: Arquivar
    Arquivada --> [*]: Fim do ciclo
    Cancelada --> [*]: Fim do ciclo
    
    note right of Rascunho
        Configuração inicial
        Horários não gerados
    end note
    
    note right of Ativa
        Agenda operacional
        Aceita agendamentos
        Horários disponíveis
    end note
    
    note right of Pausada
        Pausada temporariamente
        Horários não disponíveis
        Ex: médico em curso
    end note
    
    note right of Bloqueada
        Período bloqueado
        Ex: férias, reunião
        Horários marcados como bloqueados
    end note
    
    note right of Encerrada
        Período de agenda finalizado
        Não aceita mais agendamentos
    end note
    
    note right of Arquivada
        Agenda arquivada
        Apenas para consulta histórica
    end note
```

## 7. Diagrama de Estados: Paciente/Médico (Status Cadastral)

```mermaid
stateDiagram-v2
    [*] --> EmCadastro: Iniciando cadastro
    
    EmCadastro --> AguardandoValidacao: Dados enviados
    EmCadastro --> Cancelado: Cadastro cancelado
    
    AguardandoValidacao --> Ativo: Validação aprovada
    AguardandoValidacao --> Rejeitado: Validação rejeitada
    
    Rejeitado --> EmCadastro: Corrigir dados
    
    Ativo --> Suspenso: Suspensão aplicada
    Ativo --> Inativo: Desativação
    
    Suspenso --> Ativo: Suspensão removida
    Suspenso --> Inativo: Desativado durante suspensão
    
    Inativo --> Ativo: Reativação
    Inativo --> Arquivado: Arquivamento permanente
    
    Arquivado --> [*]: Fim do ciclo
    Cancelado --> [*]: Fim do ciclo
    
    note right of EmCadastro
        Preenchendo dados cadastrais
        Informações básicas
    end note
    
    note right of AguardandoValidacao
        Aguardando aprovação
        Documentos em análise
    end note
    
    note right of Ativo
        Cadastro aprovado e ativo
        Pode usar o sistema
        Pode ter consultas
    end note
    
    note right of Suspenso
        Temporariamente suspenso
        Não pode agendar/atender
        Decisão administrativa
    end note
    
    note right of Inativo
        Cadastro inativo
        Não pode usar sistema
        Dados preservados
    end note
```

## Transições de Estado - Regras de Negócio

### Consulta

| De | Para | Condição | Efeito |
|----|------|----------|--------|
| Marcada | Confirmada | Paciente confirma | Reduz probabilidade de no-show |
| Marcada | Cancelada | Qualquer ator cancela | Libera horário, estorna pagamento |
| Confirmada | Em Atendimento | Médico inicia | Marca início do atendimento |
| Em Atendimento | Concluída | Médico finaliza | Processa pagamento, finaliza ciclo |
| Confirmada | No-Show | Horário passou sem atendimento | Registra métrica, libera horário |

### Horário

| De | Para | Condição | Efeito |
|----|------|----------|--------|
| Disponível | Reservado | Consulta agendada | Remove da lista de disponíveis |
| Reservado | Disponível | Consulta cancelada | Retorna para lista de disponíveis |
| Reservado | Ocupado | Consulta iniciada | Marca como em uso |
| Disponível | Bloqueado | Bloqueio de agenda | Impede agendamentos |

### Pagamento

| De | Para | Condição | Efeito |
|----|------|----------|--------|
| Pendente | Processando | Início do processamento | Valida com gateway |
| Processando | Aprovado | Gateway confirma | Libera consulta |
| Aprovado | Estornado | Consulta cancelada | Devolve valor |
| Erro | Pendente | Retry automático | Nova tentativa |

## Eventos de Sistema

```mermaid
stateDiagram-v2
    [*] --> Aguardando: Sistema iniciado
    
    Aguardando --> ProcessandoLembretes: Cron: Enviar lembretes
    Aguardando --> ProcessandoAgendas: Cron: Gerar horários
    Aguardando --> ProcessandoLimpeza: Cron: Limpar dados antigos
    
    ProcessandoLembretes --> Aguardando: Processamento concluído
    ProcessandoAgendas --> Aguardando: Processamento concluído
    ProcessandoLimpeza --> Aguardando: Processamento concluído
    
    Aguardando --> [*]: Sistema desligado
```

---

**Última atualização:** 15/11/2025
