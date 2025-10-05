class DashboardController < ApplicationController
  before_action :authenticate_usuario!

  def index
    now = DateTime.now

    if current_usuario.papel == 'medico'
      @consultas_proximas = Consulta.where(medico: current_usuario.medico).where('inicio > ?', now).order(:inicio).limit(10)
      @medicos = [current_usuario.medico]
      # list pacientes atendidos nas próximas consultas do médico
      @pacientes = @consultas_proximas.includes(:paciente).map(&:paciente).compact.uniq.first(10)
    elsif current_usuario.papel == 'paciente'
      @paciente = current_usuario.paciente
      @consultas_proximas = Consulta.where(paciente: @paciente).where('inicio > ?', now).order(:inicio).limit(10)
      @medicos = Medico.ativos.limit(5)
    else
      @consultas_proximas = Consulta.where('inicio > ?', now).order(:inicio).limit(10)
      @medicos = Medico.ativos.limit(5)
      @pacientes = Paciente.ativos.order(:nome).limit(10)
    end
  end
end
