# 🎯 Guia de Exemplos - Console Rails

Este documento contém exemplos práticos de uso do sistema através do console Rails.

## 🚀 Iniciando o Console

```bash
rails console
# ou apenas
rails c
```

## 👤 Gerenciamento de Usuários

### Criar novo usuário

```ruby
# Admin
admin = Usuario.create!(
  username: 'novo_admin',
  password: 'senha123',
  papel: 'admin',
  mfa_enabled: true
)

# Atendente
atendente = Usuario.create!(
  username: 'maria_atendente',
  password: 'senha123',
  papel: 'atendente'
)
```

### Buscar usuários

```ruby
# Por username
Usuario.find_by(username: 'admin')

# Por papel
Usuario.where(papel: 'medico')

# Com autenticação de dois fatores
Usuario.where(mfa_enabled: true)
```

### Autenticar usuário

```ruby
usuario = Usuario.find_by(username: 'admin')
senha_digitada = 'admin123'

if usuario.authenticate(senha_digitada)
  puts "Autenticado com sucesso!"
else
  puts "Senha incorreta"
end
```

## 👨‍⚕️ Gerenciamento de Médicos

### Criar médico completo

```ruby
# Criar usuário
usuario = Usuario.create!(
  username: 'dr.fernando',
  password: 'medico123',
  papel: 'medico'
)

# Criar médico
medico = Medico.create!(
  nome: 'Dr. Fernando Cardoso',
  crm: '456789',
  uf_crm: 'RJ',
  telefone: '21987654321',
  email: 'fernando.cardoso@hospital.com',
  usuario: usuario,
  ativo: true
)

# Adicionar especialidades
cardiologia = Especialidade.find_by(nome: 'Cardiologia')
clinica = Especialidade.find_by(nome: 'Clínica Geral')
medico.especialidades << [cardiologia, clinica]
```

### Buscar médicos

```ruby
# Todos os médicos ativos
Medico.ativos

# Médicos por especialidade
Medico.joins(:especialidades)
      .where(especialidades: { nome: 'Cardiologia' })

# Médico com todas as informações
medico = Medico.includes(:especialidades, :usuario, :agendas).first
puts "Nome: #{medico.nome}"
puts "Especialidades: #{medico.especialidades.pluck(:nome).join(', ')}"
puts "Total de agendas: #{medico.agendas.count}"
```

### Listar médicos disponíveis

```ruby
# Médicos com agenda ativa hoje
medicos_hoje = Medico.joins(:agendas)
                     .where('agendas.data_inicio <= ? AND agendas.data_fim >= ?', 
                            Date.today, Date.today)
                     .distinct

medicos_hoje.each do |medico|
  puts "#{medico.nome} - #{medico.especialidades.pluck(:nome).join(', ')}"
end
```

## 🤒 Gerenciamento de Pacientes

### Criar paciente completo

```ruby
# Criar usuário
usuario = Usuario.create!(
  username: 'joao_silva',
  hash_senha: BCrypt::Password.create('paciente123'),
  papel: 'paciente'
)

# Criar paciente
paciente = Paciente.create!(
  nome: 'João da Silva',
  cpf: '12345678910',
  data_nascimento: Date.new(1995, 3, 15),
  telefone: '11987654321',
  email: 'joao.silva@email.com',
  sexo: 'M',
  endereco: 'Rua das Acácias, 100 - São Paulo/SP',
  usuario: usuario,
  ativo: true
)

# Vincular plano de saúde
plano = Plano.first
PacientePlano.create!(
  paciente: paciente,
  plano: plano,
  numero_carteira: '123456789',
  validade: Date.today + 1.year
)
```

### Buscar pacientes

```ruby
# Por CPF
Paciente.find_by(cpf: '12345678901')

# Pacientes com plano válido
pacientes_com_plano = Paciente.joins(:paciente_planos)
                              .merge(PacientePlano.validos)

# Pacientes ativos com consultas futuras
Paciente.ativos
        .joins(:consultas)
        .where('consultas.inicio > ?', DateTime.now)
        .distinct
```

### Histórico do paciente

```ruby
paciente = Paciente.find_by(cpf: '12345678901')

puts "=== Histórico de #{paciente.nome} ==="
puts "CPF: #{paciente.cpf}"
puts "Email: #{paciente.email}"
puts "\nConsultas:"

paciente.consultas.order(inicio: :desc).each do |consulta|
  puts "  - #{consulta.inicio.strftime('%d/%m/%Y %H:%M')} - Dr. #{consulta.medico.nome}"
  puts "    Status: #{consulta.status}"
  puts "    Especialidade: #{consulta.especialidade&.nome}"
end
```

## 📅 Gerenciamento de Agendas

### Criar agenda

```ruby
medico = Medico.find_by(crm: '123456')
unidade = Unidade.first

agenda = Agenda.create!(
  medico: medico,
  unidade: unidade,
  duracao_slot_min: 30,
  data_inicio: Date.today,
  data_fim: Date.today + 60.days,
  dias_semana: 'MON,WED,FRI',  # Segunda, Quarta, Sexta
  hora_inicio: Time.zone.parse('09:00'),
  hora_fim: Time.zone.parse('17:00'),
  politica_intervalo: 15,  # 15 minutos entre consultas
  permite_teleconsulta: true
)

# Gerar horários automaticamente
agenda.gerar_horarios
```

### Verificar disponibilidade

```ruby
# Horários disponíveis hoje
Horario.disponiveis
       .por_data(Date.today)
       .includes(agenda: :medico)
       .each do |horario|
  puts "#{horario.inicio.strftime('%H:%M')} - Dr. #{horario.agenda.medico.nome}"
end

# Horários disponíveis de um médico específico
medico = Medico.first
horarios = Horario.joins(:agenda)
                  .where(agendas: { medico_id: medico.id })
                  .where('inicio > ?', DateTime.now)
                  .disponiveis
                  .order(:inicio)
                  .limit(10)

horarios.each do |h|
  puts "#{h.inicio.strftime('%d/%m/%Y %H:%M')} - #{h.fim.strftime('%H:%M')}"
end
```

### Bloquear horários

```ruby
agenda = Agenda.first

# Bloquear período (ex: reunião)
bloqueio = BloqueioAgenda.create!(
  agenda: agenda,
  inicio: DateTime.now + 3.days + 14.hours,
  fim: DateTime.now + 3.days + 16.hours,
  motivo: 'Reunião médica'
)

# Bloquear férias
BloqueioAgenda.create!(
  agenda: agenda,
  inicio: Date.today + 30.days,
  fim: Date.today + 45.days,
  motivo: 'Férias'
)
```

## 📋 Gerenciamento de Consultas

### Agendar consulta

```ruby
# Buscar dados necessários
paciente = Paciente.find_by(cpf: '12345678901')
medico = Medico.find_by(crm: '123456')
unidade = Unidade.first
sala = Sala.where(unidade: unidade, ativa: true).first
especialidade = Especialidade.find_by(nome: 'Cardiologia')

# Criar consulta
consulta = Consulta.create!(
  paciente: paciente,
  medico: medico,
  unidade: unidade,
  sala: sala,
  especialidade: especialidade,
  inicio: DateTime.now + 2.days + 10.hours,
  fim: DateTime.now + 2.days + 10.hours + 30.minutes,
  tipo: 'presencial',
  status: 'marcada',
  origem: 'app',
  observacoes: 'Primeira consulta de cardiologia'
)

# Criar lembrete automático
Lembrete.create!(
  consulta: consulta,
  canal: 'email',
  status: 'pendente'
)

Lembrete.create!(
  consulta: consulta,
  canal: 'whatsapp',
  status: 'pendente'
)
```

### Buscar consultas

```ruby
# Consultas de hoje
Consulta.where('DATE(inicio) = ?', Date.today)

# Consultas futuras
Consulta.where('inicio > ?', DateTime.now)
        .order(:inicio)

# Consultas de um paciente
paciente = Paciente.first
paciente.consultas.order(inicio: :desc)

# Consultas pendentes de confirmação
Consulta.where(status: 'marcada')
        .where('inicio > ?', DateTime.now)
        .includes(:paciente, :medico)
```

### Atualizar status da consulta

```ruby
consulta = Consulta.find(1)

# Confirmar consulta
consulta.update!(status: 'confirmada')

# Iniciar atendimento
consulta.update!(status: 'em_atendimento')

# Concluir
consulta.update!(status: 'concluida')

# Cancelar
consulta.update!(
  status: 'cancelada',
  observacoes: 'Cancelado a pedido do paciente'
)
```

### Relatório de consultas

```ruby
# Consultas do dia por médico
data = Date.today

Medico.ativos.each do |medico|
  consultas = medico.consultas.where('DATE(inicio) = ?', data)
  puts "Dr. #{medico.nome}: #{consultas.count} consultas"
  
  consultas.each do |c|
    puts "  #{c.inicio.strftime('%H:%M')} - #{c.paciente.nome} - #{c.status}"
  end
end
```

## 💰 Gerenciamento de Pagamentos

### Registrar pagamento

```ruby
consulta = Consulta.find(1)

pagamento = Pagamento.create!(
  consulta: consulta,
  valor: 250.00,
  forma: 'pix',
  status: 'pendente'
)

# Aprovar pagamento
pagamento.update!(status: 'aprovado')
```

### Relatório financeiro

```ruby
# Pagamentos aprovados do mês
inicio_mes = Date.today.beginning_of_month
fim_mes = Date.today.end_of_month

pagamentos = Pagamento.where(status: 'aprovado')
                      .joins(:consulta)
                      .where('consultas.inicio BETWEEN ? AND ?', inicio_mes, fim_mes)

total = pagamentos.sum(:valor)
puts "Total recebido no mês: R$ #{total}"

# Por forma de pagamento
pagamentos.group(:forma).sum(:valor).each do |forma, valor|
  puts "  #{forma}: R$ #{valor}"
end
```

## 🔔 Sistema de Lembretes

### Criar lembretes

```ruby
consulta = Consulta.where('inicio > ?', DateTime.now).first

# Email
Lembrete.create!(
  consulta: consulta,
  canal: 'email',
  status: 'pendente'
)

# SMS
Lembrete.create!(
  consulta: consulta,
  canal: 'sms',
  status: 'pendente'
)

# WhatsApp
Lembrete.create!(
  consulta: consulta,
  canal: 'whatsapp',
  status: 'pendente'
)
```

### Processar lembretes pendentes

```ruby
# Buscar lembretes pendentes de consultas nas próximas 24h
lembretes = Lembrete.pendentes
                    .joins(:consulta)
                    .where('consultas.inicio BETWEEN ? AND ?', 
                           DateTime.now, DateTime.now + 24.hours)

lembretes.each do |lembrete|
  consulta = lembrete.consulta
  
  puts "Enviando lembrete via #{lembrete.canal}"
  puts "Para: #{consulta.paciente.nome}"
  puts "Consulta: #{consulta.inicio.strftime('%d/%m/%Y às %H:%M')}"
  puts "Médico: Dr. #{consulta.medico.nome}"
  puts "---"
  
  # Aqui você implementaria o envio real
  # Por exemplo: EnviarEmailJob.perform_later(lembrete.id)
  
  # Marcar como enviado
  lembrete.update!(
    status: 'enviado',
    enviado_em: DateTime.now
  )
end
```

## 🏥 Convênios e Planos

### Criar convênio e planos

```ruby
# Criar convênio
convenio = Convenio.create!(
  nome: 'SulAmérica',
  ans: '123456',
  ativo: true
)

# Criar planos
plano_basico = Plano.create!(
  convenio: convenio,
  nome: 'SulAmérica Básico',
  regras: {
    cobertura: 'básica',
    carencia: 60,
    rede: 'restrita'
  }
)

plano_premium = Plano.create!(
  convenio: convenio,
  nome: 'SulAmérica Premium',
  regras: {
    cobertura: 'completa',
    carencia: 0,
    rede: 'ampla',
    coparticipacao: false
  }
)
```

### Verificar cobertura

```ruby
paciente = Paciente.first

# Verificar planos ativos
planos_ativos = paciente.paciente_planos.joins(:plano)
                        .merge(PacientePlano.validos)

planos_ativos.each do |pp|
  puts "Plano: #{pp.plano.nome}"
  puts "Carteira: #{pp.numero_carteira}"
  puts "Validade: #{pp.validade}"
  puts "Regras: #{pp.plano.regras}"
  puts "---"
end
```

## 📊 Relatórios e Estatísticas

### Estatísticas gerais

```ruby
puts "=== ESTATÍSTICAS DO SISTEMA ==="
puts "Usuários cadastrados: #{Usuario.count}"
puts "Pacientes ativos: #{Paciente.ativos.count}"
puts "Médicos ativos: #{Medico.ativos.count}"
puts "Especialidades: #{Especialidade.count}"
puts "Unidades: #{Unidade.count}"
puts "Consultas agendadas: #{Consulta.where('inicio > ?', DateTime.now).count}"
puts "Consultas hoje: #{Consulta.where('DATE(inicio) = ?', Date.today).count}"
```

### Taxa de no-show

```ruby
total_consultas = Consulta.where('inicio < ?', DateTime.now).count
no_shows = Consulta.where(status: 'no_show').count
taxa = (no_shows.to_f / total_consultas * 100).round(2)

puts "Total de consultas passadas: #{total_consultas}"
puts "No-shows: #{no_shows}"
puts "Taxa de no-show: #{taxa}%"
```

### Médicos mais procurados

```ruby
ranking = Medico.joins(:consultas)
                .where('consultas.inicio > ?', 30.days.ago)
                .group('medicos.id', 'medicos.nome')
                .order('count_all DESC')
                .limit(10)
                .count

puts "=== TOP 10 MÉDICOS (ÚLTIMOS 30 DIAS) ==="
ranking.each_with_index do |(medico_id, nome), count), index|
  puts "#{index + 1}. Dr. #{nome} - #{count} consultas"
end
```

### Especialidades mais procuradas

```ruby
ranking = Especialidade.joins(:consultas)
                       .where('consultas.inicio > ?', 30.days.ago)
                       .group('especialidades.nome')
                       .order('count_all DESC')
                       .count

puts "=== ESPECIALIDADES MAIS PROCURADAS ==="
ranking.each do |especialidade, count|
  puts "#{especialidade}: #{count} consultas"
end
```

## 🔍 Auditoria

### Registrar ação

```ruby
# Exemplo ao criar uma consulta
usuario = Usuario.find_by(username: 'admin')
consulta = Consulta.last

Auditoria.create!(
  entidade: 'Consulta',
  id_registro: consulta.id,
  acao: 'create',
  realizado_por: usuario.id,
  realizado_em: DateTime.now,
  diffs: {
    paciente_id: consulta.paciente_id,
    medico_id: consulta.medico_id,
    status: consulta.status
  }
)
```

### Consultar auditoria

```ruby
# Últimas ações de um usuário
usuario = Usuario.find_by(username: 'admin')
acoes = Auditoria.where(realizado_por: usuario.id)
                 .order(realizado_em: :desc)
                 .limit(10)

acoes.each do |acao|
  puts "#{acao.realizado_em.strftime('%d/%m/%Y %H:%M')} - #{acao.acao} em #{acao.entidade}"
end

# Histórico de uma entidade
Auditoria.where(entidade: 'Consulta', id_registro: 1)
         .order(realizado_em: :desc)
```

## 🧹 Manutenção

### Limpar dados antigos

```ruby
# Remover consultas canceladas antigas (mais de 6 meses)
Consulta.where(status: 'cancelada')
        .where('updated_at < ?', 6.months.ago)
        .destroy_all

# Remover lembretes antigos enviados
Lembrete.where(status: 'enviado')
        .where('enviado_em < ?', 3.months.ago)
        .destroy_all
```

### Reativar horários bloqueados expirados

```ruby
# Buscar bloqueios expirados
bloqueios_expirados = BloqueioAgenda.where('fim < ?', DateTime.now)

bloqueios_expirados.each do |bloqueio|
  # Liberar horários
  Horario.where(agenda_id: bloqueio.agenda_id)
         .where('inicio >= ? AND fim <= ?', bloqueio.inicio, bloqueio.fim)
         .where(status: 'bloqueado')
         .update_all(status: 'disponivel')
  
  # Remover bloqueio
  bloqueio.destroy
end
```

---

## 💡 Dicas

1. **Use includes/joins** para evitar problema N+1:
```ruby
# Ruim
Medico.all.each { |m| puts m.especialidades.count }

# Bom
Medico.includes(:especialidades).each { |m| puts m.especialidades.count }
```

2. **Use transações** para operações complexas:
```ruby
ActiveRecord::Base.transaction do
  consulta = Consulta.create!(...)
  pagamento = Pagamento.create!(consulta: consulta, ...)
  lembrete = Lembrete.create!(consulta: consulta, ...)
end
```

3. **Use scopes** para queries comuns:
```ruby
# Já definido nos models
Paciente.ativos
Consulta.where(status: 'marcada')
Pagamento.pendentes
```

---

**Última atualização:** 02/10/2025
