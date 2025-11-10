class AjudaController < ApplicationController
  def index
    @contatos = {
      telefone: '(11) 3000-1234',
      whatsapp: '(11) 99999-8888',
      email: 'contato@hocalendar.com.br',
      endereco: 'Av. Paulista, 1000 - São Paulo/SP',
      horario: 'Segunda à Sexta: 7h às 18h | Sábado: 8h às 12h'
    }
    
    @faqs = [
      {
        pergunta: 'Como faço para agendar uma consulta?',
        resposta: 'Clique em "Agendar Consulta" no menu, escolha a especialidade, médico, data e horário disponível.'
      },
      {
        pergunta: 'Posso cancelar ou remarcar minha consulta?',
        resposta: 'Sim, você pode cancelar ou remarcar até 24 horas antes do horário agendado através do sistema.'
      },
      {
        pergunta: 'Como confirmo minha consulta?',
        resposta: 'Suas consultas são automaticamente confirmadas. Você receberá lembretes por email ou SMS.'
      },
      {
        pergunta: 'O que devo levar no dia da consulta?',
        resposta: 'Documento de identidade, cartão do convênio (se aplicável) e exames anteriores relacionados.'
      },
      {
        pergunta: 'Como funciona a teleconsulta?',
        resposta: 'Para teleconsultas, você receberá um link por email 15 minutos antes do horário agendado.'
      },
      {
        pergunta: 'Esqueci minha senha, como recupero?',
        resposta: 'Entre em contato conosco pelos telefones informados ou envie um email para recuperar sua senha.'
      }
    ]
    
    @tutoriais = [
      {
        titulo: 'Como agendar sua primeira consulta',
        descricao: 'Passo a passo completo para pacientes novos no sistema',
        icone: 'fa-calendar-plus'
      },
      {
        titulo: 'Gerenciando suas consultas',
        descricao: 'Como visualizar, remarcar e cancelar consultas',
        icone: 'fa-calendar-check'
      },
      {
        titulo: 'Atualizando seus dados',
        descricao: 'Como manter suas informações sempre atualizadas',
        icone: 'fa-user-edit'
      },
      {
        titulo: 'Teleconsultas',
        descricao: 'Tudo sobre consultas online e como participar',
        icone: 'fa-video'
      }
    ]
  end
end