defmodule MedicineCupboard.MedicineFilterTest do
  use MedicineCupboard.RepoCase

  alias MedicineCupboard.Repo

  alias MedicineCupboard.Medicine
  alias MedicineCupboard.MedicineFilter

  import Ecto.Query

  def available_medicines_query() do
    Medicine
    |> where([m], m.available == true)
  end

  def get_results(query, params) do
    query
    |> MedicineFilter.type_filter(params)
    |> MedicineFilter.condition_filter(params)
    |> IO.inspect(label: "the query", pretty: true, printable_limit: :infinity)
    |> Repo.all()
  end

  def get_broken_results(query, params) do
    query
    |> MedicineFilter.type_filter(params)
    |> MedicineFilter.broken_condition_filter(params)
    |> IO.inspect(label: "the query", pretty: true, printable_limit: :infinity)
    |> Repo.all()
  end

  setup do
    {:ok, medicine1} =
      %{name: "Medicine1", type: "tablet", conditions: ["fever", "headache"], available: true}
      |> Medicine.changeset()
      |> Repo.insert()

    {:ok, medicine2} =
      %{name: "Medicine2", type: "liquid", conditions: ["fever", "sore throat"], available: true}
      |> Medicine.changeset()
      |> Repo.insert()

    {:ok, medicine3} =
      %{name: "Medicine3", type: "tablet", conditions: ["fever", "nausea"], available: true}
      |> Medicine.changeset()
      |> Repo.insert()

    {:ok, medicine4_unavailable} =
      %{name: "Medicine4", type: "tablet", conditions: ["nausea"], available: false}
      |> Medicine.changeset()
      |> Repo.insert()

    %{
      medicine1: medicine1,
      medicine2: medicine2,
      medicine3: medicine3,
      medicine4_unavailable: medicine4_unavailable
    }
  end

  describe "type_filter" do
    test "only returns records that match the type", %{
      medicine1: medicine1,
      medicine2: medicine2,
      medicine3: medicine3,
      medicine4_unavailable: medicine4_unavailable
    } do
      tablet_results =
        available_medicines_query()
        |> get_results(%{"type" => "tablet"})

      assert [medicine1, medicine3] |> Enum.sort() == tablet_results |> Enum.sort()

      liquid_results =
        available_medicines_query()
        |> get_results(%{"type" => "liquid"})

      assert [medicine2] |> Enum.sort() == liquid_results |> Enum.sort()
    end
  end

  describe "broken_condition_filter" do
    test "fails at filtering on the conditions",
         %{
           medicine1: medicine1,
           medicine2: medicine2,
           medicine3: medicine3,
           medicine4_unavailable: medicine4_unavailable
         } do
      nausea_and_headache_results =
        available_medicines_query()
        |> get_broken_results(%{"conditions" => ["nausea", "headache"]})

      # An unavailable medicine should not be returned. medicine4_unavailable is not available.
      # A medicine without nausea or headache should not be returned. medicine2 does not have either.
      refute "nausea" in medicine2.conditions
      refute "headache" in medicine2.conditions
      refute medicine4_unavailable.available

      assert [medicine1, medicine2, medicine3, medicine4_unavailable] |> Enum.sort() ==
               nausea_and_headache_results |> Enum.sort()

      nausea_and_sore_throat_results =
        available_medicines_query()
        |> get_broken_results(%{"conditions" => ["nausea", "sore throat"]})

      # Again, an unavailable medicine should not be returned. medicine4_unavailable is not available.
      # A medicine without nausea or sore throat should not be returned. medicine1 does not have either.

      refute "nausea" in medicine1.conditions
      refute "sore throat" in medicine1.conditions

      assert [medicine1, medicine2, medicine3, medicine4_unavailable] |> Enum.sort() ==
               nausea_and_sore_throat_results |> Enum.sort()

      nausea_results =
        available_medicines_query()
        |> get_broken_results(%{"conditions" => ["nausea"]})

      # medicine3 is the only medicine with nausea. medicine1 and medicine2 do not have nausea.
      # medicine4_unavailable is not available.
      refute "nausea" in medicine1.conditions
      refute "nausea" in medicine2.conditions

      assert [medicine1, medicine2, medicine3, medicine4_unavailable] |> Enum.sort() ==
               nausea_results |> Enum.sort()

      ferver_results =
        available_medicines_query()
        |> get_broken_results(%{"conditions" => ["fever"]})

      # medicine4_unavailable is not available and medicine4_unavailable does not have fever in the conditions.
      refute "fever" in medicine4_unavailable.conditions

      # medicine4_unavailable is not in the results because it fails the condition filter & is not available.
      assert [medicine1, medicine2, medicine3] |> Enum.sort() ==
               ferver_results |> Enum.sort()
    end
  end

  describe "condition_filter" do
    test "returns medicines that treat at least one of the conditions in the filter params",
         %{
           medicine1: medicine1,
           medicine2: medicine2,
           medicine3: medicine3,
           medicine4_unavailable: medicine4_unavailable
         } do
      nausea_and_headache_results =
        available_medicines_query()
        |> get_results(%{"conditions" => ["nausea", "headache"]})

      assert [medicine1, medicine3] |> Enum.sort() == nausea_and_headache_results |> Enum.sort()

      nausea_and_sore_throat_results =
        available_medicines_query()
        |> get_results(%{"conditions" => ["nausea", "sore throat"]})

      assert [medicine2, medicine3] |> Enum.sort() ==
               nausea_and_sore_throat_results |> Enum.sort()

      nausea_results =
        available_medicines_query()
        |> get_results(%{"conditions" => ["nausea"]})

      assert [medicine3] |> Enum.sort() == nausea_results |> Enum.sort()

      ferver_results =
        available_medicines_query()
        |> get_results(%{"conditions" => ["fever"]})

      assert [medicine1, medicine2, medicine3] |> Enum.sort() == ferver_results |> Enum.sort()
    end
  end

  describe "combining type and condition filter" do
    test "should return records that satisfy both filters", %{
      medicine1: medicine1,
      medicine2: medicine2,
      medicine3: medicine3,
      medicine4_unavailable: medicine4_unavailable
    } do
      combined_results =
        available_medicines_query()
        |> get_results(%{"type" => "tablet", "conditions" => ["fever", "headache"]})

      assert medicine1.type == "tablet"
      assert medicine3.type == "tablet"
      # Not included in the results.
      assert medicine2.type == "liquid"

      assert "headache" in medicine1.conditions
      refute "headache" in medicine3.conditions
      assert "fever" in medicine3.conditions

      # Medicine2 is excluded because it is not a tablet.
      # Medicine1 in included because it has headache as a condition (and also fever).
      # Medicine3 is included because it has fever as a condition.
      assert [medicine1, medicine3] |> Enum.sort() == combined_results |> Enum.sort()
    end
  end
end
