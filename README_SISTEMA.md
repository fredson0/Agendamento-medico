# 🏥 Sistema de Agendamento de Consultas Médicas

Sistema completo de gerenciamento de consultas médicas desenvolvido em Ruby on Rails com SQLite3.

## 📋 Índice

- [Características](#características)
- [Tecnologias](#tecnologias)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
- [Instalação](#instalação)
- [Uso](#uso)
- [Modelos](#modelos)
- [Credenciais de Teste](#credenciais-de-teste)

## ✨ Características

- ✅ Gerenciamento completo de usuários (Admin, Atendente, Médico, Paciente)
- ✅ Cadastro de pacientes com múltiplos planos de convênio
- ✅ Cadastro de médicos com especialidades
- ✅ Sistema de agendas configuráveis por médico
- ✅ Controle de disponibilidade de horários
- ✅ Bloqueio de agendas (férias, reuniões, etc)
- ✅ Agendamento de consultas presenciais e teleconsultas
- ✅ Sistema de lembretes (Email, SMS, WhatsApp)
- ✅ Controle de pagamentos
- ✅ Gerenciamento de unidades e salas
- ✅ Sistema de auditoria completo
- ✅ Convênios e planos de saúde

## 🛠 Tecnologias

- **Ruby** 3.4.x
- **Rails** 8.0.3
- **SQLite3** (Banco de dados)
- **BCrypt** (Criptografia de senhas)

## 🗄 Estrutura do Banco de Dados

### Tabelas Principais

1. **usuarios** - Controle de acesso ao sistema
2. **pacientes** - Dados dos pacientes
3. **medicos** - Dados dos médicos
4. **especialidades** - Especialidades médicas
5. **unidades** - Unidades de atendimento
6. **salas** - Salas de consulta
7. **agendas** - Agendas dos médicos
8. **horarios** - Slots de horários disponíveis
9. **consultas** - Consultas agendadas
10. **convenios** - Convênios médicos
11. **planos** - Planos de saúde
12. **pagamentos** - Controle financeiro
13. **lembretes** - Sistema de notificações
14. **auditorias** - Log de auditoria

### Diagrama de Relacionamentos

```
Usuario
  ├─→ Paciente
  │     ├─→ PacientePlano ──→ Plano ──→ Convenio
  │     └─→ Consulta
  │
  └─→ Medico
        ├─→ MedicoEspecialidade ──→ Especialidade
        ├─→ Agenda
        │     ├─→ Horario
        │     └─→ BloqueioAgenda
        └─→ Consulta
              ├─→ Lembrete
              └─→ Pagamento
```

## 🚀 Instalação

### Pré-requisitos

```bash
# Fedora
sudo dnf install ruby ruby-devel sqlite-devel libyaml-devel

# Ubuntu/Debian
sudo apt-get install ruby-full sqlite3 libsqlite3-dev libyaml-dev
```

### Configuração

1. Clone o repositório:
```bash
git clone https://github.com/Bruno-BRG/HOcalendar.git
cd HOcalendar
```

2. Instale as dependências:
```bash
bundle install
```

3. Configure o banco de dados:
```bash
rails db:migrate
rails db:seed
```

4. Inicie o servidor:
```bash
rails server
```

Acesse: `http://localhost:3000`

## 📚 Uso

### Console Rails

Para interagir com o sistema via console:

```bash
rails console
```

Exemplos de uso:

```ruby
# Listar todos os médicos ativos
Medico.ativos.includes(:especialidades)

# Buscar consultas de hoje
Consulta.where('DATE(inicio) = ?', Date.today)

# Verificar horários disponíveis
Horario.disponiveis.where('inicio > ?', DateTime.now)

# Criar nova consulta
consulta = Consulta.create!(
  paciente: Paciente.first,
  medico: Medico.first,
  unidade: Unidade.first,
  inicio: DateTime.now + 1.day,
  fim: DateTime.now + 1.day + 30.minutes,
  tipo: 'presencial',
  status: 'marcada',
  origem: 'app'
)

# Gerar horários de uma agenda
agenda = Agenda.first
agenda.gerar_horarios
```

## 📦 Modelos

### Usuario
Controla o acesso ao sistema com autenticação BCrypt.

**Papéis:**
- `admin` - Acesso total
- `atendente` - Gerenciamento de consultas
- `medico` - Acesso à agenda própria
- `paciente` - Agendamento de consultas

### Paciente
Dados pessoais e histórico médico.

**Atributos principais:**
- Nome, CPF, Data de Nascimento
- Telefone, Email
- Endereço
- Planos de convênio vinculados

### Medico
Dados profissionais dos médicos.

**Atributos principais:**
- Nome, CRM, UF
- Especialidades
- Agendas e disponibilidade

### Consulta
Agendamentos de consultas.

**Tipos:**
- `presencial` - Consulta presencial
- `teleconsulta` - Consulta online

**Status:**
- `marcada` - Agendada
- `confirmada` - Confirmada pelo paciente
- `em_atendimento` - Em andamento
- `concluida` - Finalizada
- `cancelada` - Cancelada
- `no_show` - Paciente não compareceu

### Agenda
Configuração de disponibilidade dos médicos.

**Recursos:**
- Duração de slots configurável
- Dias da semana selecionáveis
- Horários de início e fim
- Intervalo entre consultas
- Suporte a teleconsulta

### Pagamento
Controle financeiro das consultas.

**Formas de pagamento:**
- `pix`
- `cartao`
- `dinheiro`

**Status:**
- `pendente`
- `aprovado`
- `estornado`

### Lembrete
Sistema de notificações.

**Canais:**
- `email`
- `sms`
- `whatsapp`

## 🔐 Credenciais de Teste

Após executar `rails db:seed`:

| Papel | Username | Senha |
|-------|----------|-------|
| Admin | admin | admin123 |
| Atendente | atendente | atendente123 |
| Médico | dr.silva | medico123 |
| Paciente | paciente1 | paciente123 |

## 📊 Dados de Exemplo

O seed cria automaticamente:

- 7 usuários (1 admin, 1 atendente, 3 médicos, 2 pacientes)
- 4 especialidades médicas
- 2 unidades de atendimento
- 3 salas de consulta
- 2 convênios com planos
- 3 agendas configuradas
- 3 consultas agendadas
- Lembretes e pagamentos associados

## 🔍 Recursos Avançados

### Sistema de Auditoria

Todas as ações importantes são registradas:

```ruby
Auditoria.where(entidade: 'Consulta')
         .where('realizado_em >= ?', Date.today)
```

### Validações

Todos os modelos possuem validações robustas:

- Unicidade de CPF, CRM, CNPJ
- Formato de email
- Datas e horários consistentes
- Relacionamentos obrigatórios

### Scopes Úteis

```ruby
# Pacientes ativos
Paciente.ativos

# Médicos de uma especialidade
Medico.joins(:especialidades)
      .where(especialidades: { nome: 'Cardiologia' })

# Consultas confirmadas do dia
Consulta.where(status: 'confirmada')
        .where('DATE(inicio) = ?', Date.today)

# Pagamentos pendentes
Pagamento.pendentes

# Horários disponíveis de hoje
Horario.disponiveis.por_data(Date.today)
```

## 🧪 Testes

Execute os testes com:

```bash
rails test
```

## 📝 Licença

Este projeto foi desenvolvido como sistema de demonstração.

## 👥 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📧 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

Desenvolvido com ❤️ usando Ruby on Rails
