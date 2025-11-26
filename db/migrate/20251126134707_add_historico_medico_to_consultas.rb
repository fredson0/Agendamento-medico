class AddHistoricoMedicoToConsultas < ActiveRecord::Migration[8.0]
  def change
    add_column :consultas, :relatorio_medico, :text
    add_column :consultas, :data_realizacao, :datetime
    add_column :consultas, :receitas_medicamentos, :text
    add_column :consultas, :exames_solicitados, :text
    add_column :consultas, :proxima_consulta, :date
    add_column :consultas, :atestado_medico, :text
    add_column :consultas, :valor_pago, :decimal
    add_column :consultas, :comprovante_atendimento, :text
  end
end
