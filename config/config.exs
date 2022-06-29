import Config

config :medicine_cupboard, MedicineCupboard.Repo,
  database: "medicine_cupboard_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :medicine_cupboard,
  ecto_repos: [MedicineCupboard.Repo]

if Mix.env() == :test do
  import_config "#{Mix.env()}.exs"
end
