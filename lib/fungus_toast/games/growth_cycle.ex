defmodule FungusToast.Games.GrowthCycle do
  import Ecto.Changeset
  use Ecto.Schema

  @attrs [
    :generation_number,
    :toast_changes,
    :mutation_points_earned
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :generation_number, :integer, default: 0
    embeds_many :toast_changes, FungusToast.Games.GridCell, on_replace: :delete
    embeds_many :player_stats_changes, FungusToast.Games.PlayerStatsChange, on_replace: :delete
    embeds_many :mutation_points_earned, FungusToast.Games.MutationPointsEarned, on_replace: :delete
  end

  def changeset(growth_cycle, %__MODULE__{} = attrs) do
    changeset(growth_cycle, Map.from_struct(attrs))
  end

  def changeset(growth_cycle, attrs) do
    growth_cycle
    |> change(attrs)
    |> cast_embed(:toast_changes)
    |> cast_embed(:mutation_points_earned)
    #TODO validate_required isn't working here and I can't figure out why
    |> validate_required(@attrs)
  end
end
