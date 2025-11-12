class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def login
    begin
      # Parse JSON body if content-type is JSON
      if request.content_type&.include?('application/json')
        body = JSON.parse(request.raw_post)
        username = body['username']
        password = body['password']
      else
        username = params[:username]
        password = params[:password]
      end

      if username.blank? || password.blank?
        render json: { error: 'Username e password são obrigatórios' }, status: :bad_request
        return
      end

      usuario = Usuario.find_by(username: username)

      unless usuario&.authenticate(password)
        render json: { error: 'Credenciais inválidas' }, status: :unauthorized
        return
      end

      # Gerar token JWT
      payload = {
        user_id: usuario.id,
        username: usuario.username,
        papel: usuario.papel
      }

      token = JwtHelper.encode(payload)

      render json: {
        message: 'Login realizado com sucesso',
        token: token,
        user: {
          id: usuario.id,
          username: usuario.username,
          papel: usuario.papel
        },
        expires_at: 24.hours.from_now.iso8601
      }, status: :ok

    rescue JSON::ParserError
      render json: { error: 'Formato JSON inválido' }, status: :bad_request
    rescue => e
      render json: { error: "Erro interno: #{e.message}" }, status: :internal_server_error
    end
  end

  def logout
    # Com JWT stateless, logout é só no frontend
    render json: { message: 'Logout realizado com sucesso' }, status: :ok
  end

  def me
    authenticate_with_token!
    
    render json: {
      user: {
        id: current_usuario.id,
        username: current_usuario.username,
        papel: current_usuario.papel,
        created_at: current_usuario.created_at
      }
    }, status: :ok
  end

  def test_login
    username = params[:username]
    password = params[:password]

    usuario = Usuario.find_by(username: username)

    if usuario&.authenticate(password)
      # Gerar token JWT
      payload = {
        user_id: usuario.id,
        username: usuario.username,
        papel: usuario.papel
      }

      token = JwtHelper.encode(payload)

      render json: {
        success: true,
        message: 'Login realizado com sucesso',
        token: token,
        user: {
          id: usuario.id,
          username: usuario.username,
          papel: usuario.papel
        },
        expires_at: 24.hours.from_now.iso8601
      }
    else
      render json: { success: false, error: 'Credenciais inválidas' }, status: :unauthorized
    end
  end

  private

  def authenticate_with_token!
    token = extract_token_from_header
    unless token.present?
      render json: { error: 'Token não fornecido' }, status: :unauthorized
      return
    end

    unless JwtHelper.valid_token?(token)
      render json: { error: 'Token inválido' }, status: :unauthorized
      return
    end

    if JwtHelper.expired?(token)
      render json: { error: 'Token expirado' }, status: :unauthorized
      return
    end

    @current_usuario_from_token = JwtHelper.user_from_token(token)
    unless @current_usuario_from_token
      render json: { error: 'Usuário não encontrado' }, status: :unauthorized
      return
    end
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')
    auth_header.split(' ').last
  end

  def current_usuario
    @current_usuario_from_token || super
  end
end