defmodule MedicineCupboard.Repo.Migrations.CreateMedicines do
  use Ecto.Migration

  def change do
    create table(:medicines) do
      add(:name, :string)
      add(:type, :string)
      add(:conditions, {:array, :string})
      add(:available, :boolean, default: false)
    end
  end
end
