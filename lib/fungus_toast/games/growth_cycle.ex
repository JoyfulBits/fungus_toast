defmodule FungusToast.Games.GrowthCycle do
  import Ecto.Changeset
  use Ecto.Schema

  @attrs [
    :generation_number,
    :toast_changes,
    :mutation_points_earned
  ]

  @derive Jason.Encoder
  embedded_schema do
    field :generation_number, :integer
    field :toast_changes, :map
    field :mutation_points_earned, :map
  end

  def changeset(growth_cycle, attrs) do
    IO.inspect growth_cycle
    growth_cycle
    |> change(attrs)
    |> validate_required(@attrs)
  end
end
