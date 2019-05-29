defmodule FungusToast.Games.PlayerStatsChange do
  import Ecto.Changeset
  use Ecto.Schema

  @attrs [
    :player_id,
    :grown_cells,
    :perished_cells,
    :regenerated_cells,
    :fungicidal_kills
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :player_id, :integer, null: false
    field :grown_cells, :integer, null: false, default: 0
    field :perished_cells, :integer, null: false, default: 0
    field :regenerated_cells, :integer, null: false, default: 0
    field :fungicidal_kills, :integer, null: false, default: 0
  end

  def changeset(player_stats_change, attrs) do
    player_stats_change
    |> change(attrs)
    |> validate_required( @attrs)
  end
end
