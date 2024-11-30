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

ActiveRecord::Schema[7.1].define(version: 2024_11_30_111153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bios", force: :cascade do |t|
    t.string "text"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bios_on_user_id"
  end

  create_table "electricien_tasks", force: :cascade do |t|
    t.string "type_de_travaux"
    t.string "type_de_batiment"
    t.string "nombre_de_pieces"
    t.string "surface_totale"
    t.string "amperage_principal"
    t.string "tension_requise"
    t.string "phase_type"
    t.boolean "installation_tableau_electrique"
    t.boolean "mise_aux_normes_tableau"
    t.boolean "pose_prises_electriques"
    t.boolean "pose_interrupteurs"
    t.boolean "installation_eclairage"
    t.boolean "pose_luminaires"
    t.boolean "installation_cuisine"
    t.boolean "installation_salle_de_bain"
    t.boolean "installation_exterieure"
    t.boolean "installation_cave_garage"
    t.boolean "mise_a_la_terre"
    t.boolean "installation_differentiel"
    t.boolean "installation_parafoudre"
    t.boolean "verification_conformite"
    t.boolean "installation_domotique"
    t.boolean "installation_videophone"
    t.boolean "installation_alarme"
    t.boolean "installation_ventilation"
    t.boolean "depannage_urgent"
    t.boolean "recherche_panne"
    t.boolean "modification_existant"
    t.boolean "passage_cables"
    t.boolean "saignee_murs"
    t.text "other_task"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "peintre_tasks", force: :cascade do |t|
    t.string "type_de_travaux"
    t.string "type_de_surface"
    t.string "nombre_de_logements"
    t.string "nombre_de_pieces"
    t.string "surface_sol"
    t.string "surface_mur"
    t.string "surface_plafond"
    t.boolean "peinture_lisse"
    t.boolean "gouttelette"
    t.boolean "gouttelette_ecrase"
    t.boolean "pose_revetement_tapisserie"
    t.boolean "pose_revetement_toile_de_verre"
    t.boolean "pose_revetement_type_vescom"
    t.boolean "pose_sol_sans_soudure"
    t.boolean "pose_sol_avec_soudure_a_chaux"
    t.boolean "stuco_decoration"
    t.boolean "peinture_facade"
    t.boolean "pose_plaques_type_decochoc"
    t.boolean "pose_faience"
    t.boolean "pose_petite_platrerie"
    t.boolean "pose_plinthe"
    t.boolean "pose_parquet_fottant"
    t.boolean "rattrapage_bande_placo"
    t.boolean "ratissage"
    t.boolean "pose_baguette_angles"
    t.text "other_task"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "taskable_type", null: false
    t.bigint "taskable_id", null: false
    t.bigint "contractor_id", null: false
    t.bigint "sub_contractor_id"
    t.string "site_name"
    t.string "street"
    t.string "city"
    t.string "area_code"
    t.decimal "proposed_price", precision: 10, scale: 2
    t.decimal "accepted_price", precision: 10, scale: 2
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.string "work_progress"
    t.string "billing_process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id"], name: "index_tasks_on_contractor_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["sub_contractor_id"], name: "index_tasks_on_sub_contractor_id"
    t.index ["taskable_id", "taskable_type"], name: "index_tasks_on_taskable_id_and_taskable_type"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.boolean "admin"
    t.string "position"
    t.string "legal_status"
    t.string "company_name"
    t.string "siret_number"
    t.string "activity_sector"
    t.integer "employees_number"
    t.integer "establishment_date"
    t.decimal "turnover", precision: 10, scale: 2
    t.string "street"
    t.string "area_code"
    t.string "city"
    t.string "country", default: "France"
    t.float "latitude"
    t.float "longitude"
    t.index ["city"], name: "index_users_on_city"
    t.index ["company_name"], name: "index_users_on_company_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["siret_number"], name: "index_users_on_siret_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bios", "users"
  add_foreign_key "tasks", "users", column: "contractor_id"
  add_foreign_key "tasks", "users", column: "sub_contractor_id"
end
