module ApplicationHelper
  def status_badge(status)
    content_tag :span, status_text(status), class: "status-badge status-#{status}"
  end
  
  def status_card_class(status)
    "status-#{status}"
  end
  
  def status_text(status)
    case status
    when 'marcada'
      'Marcada'
    when 'confirmada'
      'Confirmada'
    when 'em_atendimento'
      'Em Atendimento'
    when 'concluida'
      'Concluída'
    when 'cancelada'
      'Cancelada'
    when 'no_show'
      'Não Compareceu'
    else
      status.humanize
    end
  end
  
  def tipo_icon(tipo)
    case tipo
    when 'teleconsulta'
      content_tag :i, '', class: 'fas fa-video'
    when 'presencial'
      content_tag :i, '', class: 'fas fa-hospital'
    else
      content_tag :i, '', class: 'fas fa-calendar'
    end
  end
  
  def can_edit_consulta?(consulta)
    return false unless usuario_signed_in?
    
    case current_usuario.papel
    when 'admin'
      true
    when 'atendente'
      consulta.status.in?(['marcada', 'confirmada'])
    when 'medico'
      consulta.medico.usuario == current_usuario && 
      consulta.status.in?(['marcada', 'confirmada'])
    when 'paciente'
      consulta.paciente.usuario == current_usuario && 
      consulta.status == 'marcada' && 
      consulta.inicio > 24.hours.from_now
    else
      false
    end
  end
  
  def papel_texto(papel)
    case papel
    when 'admin'
      'Administrador'
    when 'atendente'
      'Atendente'
    when 'medico'
      'Médico'
    when 'paciente'
      'Paciente'
    else
      papel.humanize
    end
  end
  
  def nav_link_class(section)
    base_class = 'nav-link'
    current_section = controller_name == 'dashboard' ? 'dashboard' : controller_name
    current_section = 'agendamento' if controller_name == 'agendamentos'
    current_section = 'nova_consulta' if controller_name == 'consultas' && action_name == 'new'
    
    if current_section == section.to_s
      "#{base_class} active"
    else
      base_class
    end
  end
end
