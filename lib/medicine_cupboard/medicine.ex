defmodule MedicineCupboard.Medicine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medicines" do
    field(:name, :string)
    field(:type, :string)
    field(:conditions, {:array, :string})
    field(:available, :boolean, default: false)
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :type, :conditions, :available])
    |> validate_required([:name, :available])
  end
end
