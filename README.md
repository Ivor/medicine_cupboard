# MedicineCupboard

A small project to show an approach to filtering records, using Ecto, where the record has a field that is defined as:

```elixir
  field :array_of_string, {:array, :string}
```

The problem arises when we want to filter on other attributes AND the presence of one or more values in the array of strings.

See the [test/medicine_filter_test.exs](test/medicine_filter_test.exs) file for the meat.
