use Mix.Config

config :medicine_cupboard, MedicineCupboard.Repo,
  database: "medicine_cupboard_repo_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
