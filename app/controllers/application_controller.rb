class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_usuario, :usuario_signed_in?

  private

  def current_usuario
    # Priority: JWT token first, then session
    return @current_usuario_from_token if @current_usuario_from_token.present?
    
    return @current_usuario if defined?(@current_usuario)
    if session[:usuario_id]
      @current_usuario = Usuario.find_by(id: session[:usuario_id])
    else
      @current_usuario = nil
    end
  end

  def usuario_signed_in?
    current_usuario.present?
  end

  def authenticate_usuario!
    unless usuario_signed_in?
      redirect_to login_path, alert: 'Você precisa fazer login para acessar esta página.'
    end
  end

  # Autorização por papel (roles)
  def usuario_tem_papel?(papel)
    current_usuario && current_usuario.papel == papel.to_s
  end

  def require_roles(*roles)
    roles = roles.flatten.map(&:to_s)
    unless usuario_signed_in? && roles.include?(current_usuario.papel)
      redirect_to root_path, alert: 'Você não tem permissão para acessar esta página.'
    end
  end
end
