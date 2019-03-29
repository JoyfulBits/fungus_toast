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
    field :generation_number, :integer, default: 0
    embeds_many :toast_changes, FungusToast.Games.GridCell
    field :mutation_points_earned, :map, default: %{}
  end

  def changeset(growth_cycle, %__MODULE__{} = attrs) do
    changeset(growth_cycle, Map.from_struct(attrs))
  end

  def changeset(growth_cycle, attrs) do
    growth_cycle
    |> change(attrs)
    |> cast_embed(:toast_changes)
    |> validate_required(@attrs)
  end
end
