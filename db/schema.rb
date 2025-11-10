# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_02_150000) do
  create_table "agendas", force: :cascade do |t|
    t.integer "medico_id", null: false
    t.integer "unidade_id", null: false
    t.integer "duracao_slot_min"
    t.date "data_inicio"
    t.date "data_fim"
    t.string "dias_semana"
    t.time "hora_inicio"
    t.time "hora_fim"
    t.integer "politica_intervalo"
    t.boolean "permite_teleconsulta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medico_id"], name: "index_agendas_on_medico_id"
    t.index ["unidade_id"], name: "index_agendas_on_unidade_id"
  end

  create_table "auditorias", force: :cascade do |t|
    t.string "entidade", limit: 50
    t.integer "id_registro"
    t.string "acao", limit: 50
    t.integer "realizado_por"
    t.datetime "realizado_em"
    t.text "diffs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entidade"], name: "index_auditorias_on_entidade"
    t.index ["realizado_por"], name: "index_auditorias_on_realizado_por"
  end

  create_table "bloqueio_agendas", force: :cascade do |t|
    t.integer "agenda_id", null: false
    t.datetime "inicio"
    t.datetime "fim"
    t.string "motivo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agenda_id"], name: "index_bloqueio_agendas_on_agenda_id"
  end

  create_table "consultas", force: :cascade do |t|
    t.integer "paciente_id", null: false
    t.integer "medico_id", null: false
    t.integer "unidade_id", null: false
    t.integer "sala_id"
    t.integer "especialidade_id"
    t.datetime "inicio", null: false
    t.datetime "fim", null: false
    t.string "tipo", default: "presencial"
    t.string "status", default: "marcada"
    t.string "origem", default: "app"
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["especialidade_id"], name: "index_consultas_on_especialidade_id"
    t.index ["inicio"], name: "index_consultas_on_inicio"
    t.index ["medico_id"], name: "index_consultas_on_medico_id"
    t.index ["paciente_id"], name: "index_consultas_on_paciente_id"
    t.index ["sala_id"], name: "index_consultas_on_sala_id"
    t.index ["status"], name: "index_consultas_on_status"
    t.index ["unidade_id"], name: "index_consultas_on_unidade_id"
  end

  create_table "convenios", force: :cascade do |t|
    t.string "nome", limit: 100, null: false
    t.string "ans", limit: 20
    t.boolean "ativo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "especialidades", force: :cascade do |t|
    t.string "nome"
    t.string "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "horarios", force: :cascade do |t|
    t.integer "agenda_id", null: false
    t.datetime "inicio"
    t.datetime "fim"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agenda_id"], name: "index_horarios_on_agenda_id"
  end

  create_table "lembretes", force: :cascade do |t|
    t.integer "consulta_id", null: false
    t.string "canal"
    t.datetime "enviado_em"
    t.string "status", default: "pendente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consulta_id"], name: "index_lembretes_on_consulta_id"
    t.index ["status"], name: "index_lembretes_on_status"
  end

  create_table "medico_especialidades", force: :cascade do |t|
    t.integer "medico_id", null: false
    t.integer "especialidade_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["especialidade_id"], name: "index_medico_especialidades_on_especialidade_id"
    t.index ["medico_id"], name: "index_medico_especialidades_on_medico_id"
  end

  create_table "medicos", force: :cascade do |t|
    t.string "nome", limit: 150, null: false
    t.string "crm", limit: 20, null: false
    t.string "uf_crm", limit: 2, null: false
    t.string "telefone", limit: 20
    t.string "email", limit: 100
    t.integer "usuario_id"
    t.boolean "ativo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm", "uf_crm"], name: "index_medicos_on_crm_and_uf_crm", unique: true
    t.index ["usuario_id"], name: "index_medicos_on_usuario_id"
  end

  create_table "paciente_planos", force: :cascade do |t|
    t.integer "paciente_id", null: false
    t.integer "plano_id", null: false
    t.string "numero_carteira"
    t.date "validade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paciente_id"], name: "index_paciente_planos_on_paciente_id"
    t.index ["plano_id"], name: "index_paciente_planos_on_plano_id"
  end

  create_table "pacientes", force: :cascade do |t|
    t.string "nome", limit: 150, null: false
    t.string "cpf", limit: 11, null: false
    t.date "data_nascimento"
    t.string "telefone", limit: 20
    t.string "email", limit: 100
    t.string "sexo", limit: 1
    t.string "endereco", limit: 255
    t.integer "usuario_id"
    t.boolean "ativo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_pacientes_on_cpf", unique: true
    t.index ["usuario_id"], name: "index_pacientes_on_usuario_id"
  end

  create_table "pagamentos", force: :cascade do |t|
    t.integer "consulta_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.string "forma"
    t.string "status", default: "pendente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consulta_id"], name: "index_pagamentos_on_consulta_id"
    t.index ["status"], name: "index_pagamentos_on_status"
  end

  create_table "planos", force: :cascade do |t|
    t.integer "convenio_id", null: false
    t.string "nome"
    t.text "regras"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["convenio_id"], name: "index_planos_on_convenio_id"
  end

  create_table "salas", force: :cascade do |t|
    t.integer "unidade_id", null: false
    t.string "nome"
    t.string "recursos"
    t.boolean "ativa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unidade_id"], name: "index_salas_on_unidade_id"
  end

  create_table "unidades", force: :cascade do |t|
    t.string "nome", limit: 150, null: false
    t.string "cnpj", limit: 14
    t.string "endereco", limit: 255
    t.string "telefone", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_unidades_on_cnpj", unique: true
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "username", limit: 50, null: false
    t.string "hash_senha", limit: 255
    t.string "papel", null: false
    t.boolean "mfa_enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["username"], name: "index_usuarios_on_username", unique: true
  end

  add_foreign_key "agendas", "medicos"
  add_foreign_key "agendas", "unidades"
  add_foreign_key "auditorias", "usuarios", column: "realizado_por"
  add_foreign_key "bloqueio_agendas", "agendas"
  add_foreign_key "consultas", "especialidades"
  add_foreign_key "consultas", "medicos"
  add_foreign_key "consultas", "pacientes"
  add_foreign_key "consultas", "salas"
  add_foreign_key "consultas", "unidades"
  add_foreign_key "horarios", "agendas"
  add_foreign_key "lembretes", "consultas"
  add_foreign_key "medico_especialidades", "especialidades"
  add_foreign_key "medico_especialidades", "medicos"
  add_foreign_key "medicos", "usuarios"
  add_foreign_key "paciente_planos", "pacientes"
  add_foreign_key "paciente_planos", "planos"
  add_foreign_key "pacientes", "usuarios"
  add_foreign_key "pagamentos", "consultas"
  add_foreign_key "planos", "convenios"
  add_foreign_key "salas", "unidades"
end
