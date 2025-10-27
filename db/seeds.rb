# Seeds para o Sistema de Agendamento de Consultas Médicas
puts "🌱 Iniciando seed do banco de dados..."

# Limpar dados existentes
puts "🧹 Limpando dados existentes..."
[Auditoria, Pagamento, Lembrete, Consulta, Horario, BloqueioAgenda, 
 Agenda, PacientePlano, Plano, Convenio, Sala, Unidade, 
 MedicoEspecialidade, Especialidade, Medico, Paciente, Usuario].each(&:destroy_all)

# 1. Criar Usuários
puts "👤 Criando usuários..."
admin = Usuario.create!(
  username: 'admin',
  password: 'admin123',
  papel: 'admin',
  mfa_enabled: true
)

atendente = Usuario.create!(
  username: 'atendente',
  password: 'atendente123',
  papel: 'atendente',
  mfa_enabled: false
)

# 2. Criar Especialidades
puts "🏥 Criando especialidades..."
cardiologia = Especialidade.create!(nome: 'Cardiologia', descricao: 'Especialidade médica que cuida do coração')
ortopedia = Especialidade.create!(nome: 'Ortopedia', descricao: 'Especialidade médica que cuida dos ossos e articulações')
pediatria = Especialidade.create!(nome: 'Pediatria', descricao: 'Especialidade médica que cuida de crianças')
clinica_geral = Especialidade.create!(nome: 'Clínica Geral', descricao: 'Atendimento geral')

# 3. Criar Médicos
puts "👨‍⚕️ Criando médicos..."
usuario_medico1 = Usuario.create!(
  username: 'dr.silva',
  password: 'medico123',
  papel: 'medico'
)

medico1 = Medico.create!(
  nome: 'Dr. João Silva',
  crm: '123456',
  uf_crm: 'SP',
  telefone: '11987654321',
  email: 'joao.silva@hospital.com',
  usuario: usuario_medico1,
  ativo: true
)
medico1.especialidades << [cardiologia, clinica_geral]

usuario_medico2 = Usuario.create!(
  username: 'dra.santos',
  password: 'medico123',
  papel: 'medico'
)

medico2 = Medico.create!(
  nome: 'Dra. Maria Santos',
  crm: '789012',
  uf_crm: 'SP',
  telefone: '11987654322',
  email: 'maria.santos@hospital.com',
  usuario: usuario_medico2,
  ativo: true
)
medico2.especialidades << [pediatria, clinica_geral]

usuario_medico3 = Usuario.create!(
  username: 'dr.oliveira',
  password: 'medico123',
  papel: 'medico'
)

medico3 = Medico.create!(
  nome: 'Dr. Carlos Oliveira',
  crm: '345678',
  uf_crm: 'RJ',
  telefone: '21987654323',
  email: 'carlos.oliveira@hospital.com',
  usuario: usuario_medico3,
  ativo: true
)
medico3.especialidades << ortopedia

# 4. Criar Pacientes
puts "🤒 Criando pacientes..."
usuario_paciente1 = Usuario.create!(
  username: 'paciente1',
  password: 'paciente123',
  papel: 'paciente'
)

paciente1 = Paciente.create!(
  nome: 'Ana Paula Costa',
  cpf: '12345678901',
  data_nascimento: Date.new(1990, 5, 15),
  telefone: '11987654324',
  email: 'ana.costa@email.com',
  sexo: 'F',
  endereco: 'Rua das Flores, 123 - São Paulo/SP',
  usuario: usuario_paciente1,
  ativo: true
)

usuario_paciente2 = Usuario.create!(
  username: 'paciente2',
  password: 'paciente123',
  papel: 'paciente'
)

paciente2 = Paciente.create!(
  nome: 'Pedro Henrique Alves',
  cpf: '23456789012',
  data_nascimento: Date.new(1985, 8, 20),
  telefone: '11987654325',
  email: 'pedro.alves@email.com',
  sexo: 'M',
  endereco: 'Av. Paulista, 456 - São Paulo/SP',
  usuario: usuario_paciente2,
  ativo: true
)

paciente3 = Paciente.create!(
  nome: 'Julia Fernandes Silva',
  cpf: '34567890123',
  data_nascimento: Date.new(2015, 3, 10),
  telefone: '11987654326',
  email: 'responsavel.julia@email.com',
  sexo: 'F',
  endereco: 'Rua dos Lírios, 789 - São Paulo/SP',
  ativo: true
)

# 5. Criar Convênios e Planos
puts "💳 Criando convênios e planos..."
convenio1 = Convenio.create!(nome: 'Unimed', ans: '123456', ativo: true)
convenio2 = Convenio.create!(nome: 'Bradesco Saúde', ans: '789012', ativo: true)

plano1 = Plano.create!(
  convenio: convenio1,
  nome: 'Unimed Premium',
  regras: { cobertura: 'completa', carencia: 0 }
)

plano2 = Plano.create!(
  convenio: convenio2,
  nome: 'Bradesco Top',
  regras: { cobertura: 'completa', carencia: 30 }
)

# Associar pacientes a planos
PacientePlano.create!(
  paciente: paciente1,
  plano: plano1,
  numero_carteira: '1234567890',
  validade: Date.today + 1.year
)

PacientePlano.create!(
  paciente: paciente2,
  plano: plano2,
  numero_carteira: '0987654321',
  validade: Date.today + 2.years
)

# 6. Criar Unidades
puts "🏢 Criando unidades..."
unidade1 = Unidade.create!(
  nome: 'Hospital Central',
  cnpj: '12345678000190',
  endereco: 'Av. Central, 1000 - São Paulo/SP',
  telefone: '1133334444'
)

unidade2 = Unidade.create!(
  nome: 'Clínica do Bairro',
  cnpj: '98765432000110',
  endereco: 'Rua do Comércio, 200 - São Paulo/SP',
  telefone: '1133335555'
)

# 7. Criar Salas
puts "🚪 Criando salas..."
sala1 = Sala.create!(
  unidade: unidade1,
  nome: 'Consultório 101',
  recursos: 'Mesa, cadeiras, maca, computador',
  ativa: true
)

sala2 = Sala.create!(
  unidade: unidade1,
  nome: 'Consultório 102',
  recursos: 'Mesa, cadeiras, maca, eletrocardiógrafo',
  ativa: true
)

sala3 = Sala.create!(
  unidade: unidade2,
  nome: 'Consultório A',
  recursos: 'Mesa, cadeiras, maca',
  ativa: true
)

# 8. Criar Agendas
puts "📅 Criando agendas..."
agenda1 = Agenda.create!(
  medico: medico1,
  unidade: unidade1,
  duracao_slot_min: 30,
  data_inicio: Date.today,
  data_fim: Date.today + 30.days,
  dias_semana: 'MON,TUE,WED,THU,FRI',
  hora_inicio: Time.zone.parse('09:00'),
  hora_fim: Time.zone.parse('17:00'),
  politica_intervalo: 0,
  permite_teleconsulta: true
)

agenda2 = Agenda.create!(
  medico: medico2,
  unidade: unidade1,
  duracao_slot_min: 20,
  data_inicio: Date.today,
  data_fim: Date.today + 30.days,
  dias_semana: 'TUE,THU',
  hora_inicio: Time.zone.parse('08:00'),
  hora_fim: Time.zone.parse('12:00'),
  politica_intervalo: 10,
  permite_teleconsulta: false
)

agenda3 = Agenda.create!(
  medico: medico3,
  unidade: unidade2,
  duracao_slot_min: 45,
  data_inicio: Date.today,
  data_fim: Date.today + 30.days,
  dias_semana: 'MON,TUE,WED,THU,FRI',
  hora_inicio: Time.zone.parse('14:00'),
  hora_fim: Time.zone.parse('18:00'),
  politica_intervalo: 15,
  permite_teleconsulta: false
)

# 9. Criar Consultas
puts "📋 Criando consultas..."
consulta1 = Consulta.create!(
  paciente: paciente1,
  medico: medico1,
  unidade: unidade1,
  sala: sala1,
  especialidade: cardiologia,
  inicio: DateTime.now + 1.day + 10.hours,
  fim: DateTime.now + 1.day + 10.hours + 30.minutes,
  tipo: 'presencial',
  status: 'confirmada',
  origem: 'app',
  observacoes: 'Consulta de rotina'
)

consulta2 = Consulta.create!(
  paciente: paciente3,
  medico: medico2,
  unidade: unidade1,
  sala: sala2,
  especialidade: pediatria,
  inicio: DateTime.now + 2.days + 9.hours,
  fim: DateTime.now + 2.days + 9.hours + 20.minutes,
  tipo: 'presencial',
  status: 'marcada',
  origem: 'recepcao',
  observacoes: 'Primeira consulta'
)

consulta3 = Consulta.create!(
  paciente: paciente2,
  medico: medico1,
  unidade: unidade1,
  especialidade: clinica_geral,
  inicio: DateTime.now + 3.days + 15.hours,
  fim: DateTime.now + 3.days + 15.hours + 30.minutes,
  tipo: 'teleconsulta',
  status: 'marcada',
  origem: 'app'
)

# 10. Criar Lembretes
puts "🔔 Criando lembretes..."
Lembrete.create!(
  consulta: consulta1,
  canal: 'email',
  status: 'pendente'
)

Lembrete.create!(
  consulta: consulta1,
  canal: 'whatsapp',
  status: 'pendente'
)

Lembrete.create!(
  consulta: consulta2,
  canal: 'sms',
  status: 'pendente'
)

# 11. Criar Pagamentos
puts "💰 Criando pagamentos..."
Pagamento.create!(
  consulta: consulta1,
  valor: 250.00,
  forma: 'cartao',
  status: 'aprovado'
)

Pagamento.create!(
  consulta: consulta2,
  valor: 180.00,
  forma: 'pix',
  status: 'pendente'
)

# 12. Criar Bloqueio de Agenda
puts "🚫 Criando bloqueios de agenda..."
BloqueioAgenda.create!(
  agenda: agenda1,
  inicio: DateTime.now + 7.days + 13.hours,
  fim: DateTime.now + 7.days + 15.hours,
  motivo: 'Reunião administrativa'
)

puts "✅ Seed concluído com sucesso!"
puts ""
puts "📊 Resumo:"
puts "  - #{Usuario.count} usuários"
puts "  - #{Medico.count} médicos"
puts "  - #{Paciente.count} pacientes"
puts "  - #{Especialidade.count} especialidades"
puts "  - #{Unidade.count} unidades"
puts "  - #{Sala.count} salas"
puts "  - #{Convenio.count} convênios"
puts "  - #{Plano.count} planos"
puts "  - #{Agenda.count} agendas"
puts "  - #{Consulta.count} consultas"
puts "  - #{Lembrete.count} lembretes"
puts "  - #{Pagamento.count} pagamentos"
puts ""
puts "👤 Credenciais de acesso:"
puts "  Admin: admin / admin123"
puts "  Atendente: atendente / atendente123"
puts "  Médico: dr.silva / medico123"
puts "  Paciente: paciente1 / paciente123"
