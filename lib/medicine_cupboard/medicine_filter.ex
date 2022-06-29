defmodule MedicineCupboard.MedicineFilter do
  import Ecto.Query

  alias MedicineCupboard.Medicine

  def type_filter(query, %{"type" => type}) do
    where(query, [m], m.type == ^type)
  end

  def type_filter(query, _), do: query

  def condition_filter(query, %{"conditions" => conditions_list} = params) do
    conditions_sub_query =
      Enum.reduce(conditions_list, Medicine, fn condition, conditions_query ->
        or_where(conditions_query, [m], ^condition in m.conditions)
      end)
      |> select([:id])

    query
    |> where([m], m.id in subquery(conditions_sub_query))
  end

  def condition_filter(query, _), do: query

  def broken_condition_filter(query, %{"conditions" => conditions_list}) do
    conditions_list
    |> Enum.reduce(query, fn condition, query ->
      or_where(query, [m], ^condition in m.conditions)
    end)
  end
end
