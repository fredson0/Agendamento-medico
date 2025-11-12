class UsuariosController < ApplicationController
  before_action :authenticate_usuario!

  def perfil
    @usuario = current_usuario
    @paciente = @usuario.paciente if @usuario.papel == 'paciente'
    @medico = @usuario.medico if @usuario.papel == 'medico'
  end

  def update_perfil
    @usuario = current_usuario
    
    if @usuario.update(usuario_params)
      # Atualizar dados específicos baseado no papel
      case @usuario.papel
      when 'paciente'
        @paciente = @usuario.paciente
        if @paciente && @paciente.update(paciente_params)
          redirect_to perfil_path, notice: 'Perfil atualizado com sucesso!'
        else
          render :perfil, status: :unprocessable_entity
        end
      when 'medico'
        @medico = @usuario.medico
        if @medico && @medico.update(medico_params)
          redirect_to perfil_path, notice: 'Perfil atualizado com sucesso!'
        else
          render :perfil, status: :unprocessable_entity
        end
      else
        redirect_to perfil_path, notice: 'Perfil atualizado com sucesso!'
      end
    else
      render :perfil, status: :unprocessable_entity
    end
  end

  private

  def usuario_params
    params.require(:usuario).permit(:username, :password, :password_confirmation)
  end

  def paciente_params
    return {} unless params[:paciente]
    params.require(:paciente).permit(:nome, :telefone, :email, :endereco)
  end

  def medico_params
    return {} unless params[:medico]
    params.require(:medico).permit(:nome, :telefone, :email)
  end
end