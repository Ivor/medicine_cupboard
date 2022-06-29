defmodule MedicineCupboard.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MedicineCupboard.Repo

      import Ecto
      import Ecto.Query
      import MedicineCupboard.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MedicineCupboard.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MedicineCupboard.Repo, {:shared, self()})
    end

    :ok
  end
end
