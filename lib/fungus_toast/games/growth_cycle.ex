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

  def changeset(growth_cycle, %__MODULE__{} = attrs) do
    changeset(growth_cycle, Map.from_struct(attrs))
  end

  def changeset(growth_cycle, attrs) do
    growth_cycle
    |> change(attrs)
    |> validate_required(@attrs)
  end
end
