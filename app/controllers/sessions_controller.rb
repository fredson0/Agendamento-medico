class SessionsController < ApplicationController
  def new
    # form de login
  end

  def create
    usuario = Usuario.find_by(username: params[:username])
    if usuario && usuario.authenticate(params[:password])
      session[:usuario_id] = usuario.id
      redirect_to root_path, notice: 'Login realizado com sucesso.'
    else
      flash.now[:alert] = 'Usuário ou senha inválidos.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:usuario_id)
    redirect_to login_path, notice: 'Você saiu do sistema.'
  end
end
