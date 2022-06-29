defmodule MedicineCupboard.Repo do
  use Ecto.Repo,
    otp_app: :medicine_cupboard,
    adapter: Ecto.Adapters.Postgres
end
