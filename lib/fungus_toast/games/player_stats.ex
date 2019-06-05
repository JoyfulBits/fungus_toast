defmodule FungusToast.Games.PlayerStats do
  import Ecto.Changeset
  use Ecto.Schema

  @attrs [
    :player_id,
    :live_cells,
    :dead_cells,
    :grown_cells,
    :perished_cells,
    :regenerated_cells,
    :fungicidal_kills,
    :lost_dead_cells
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :player_id, :integer, null: false
    field :dead_cells, :integer, default: 0, null: false
    field :live_cells, :integer, default: 0, null: false
    field :grown_cells, :integer, null: false, default: 0
    field :perished_cells, :integer, null: false, default: 0
    field :regenerated_cells, :integer, null: false, default: 0
    field :fungicidal_kills, :integer, null: false, default: 0
    field :lost_dead_cells, :integer, null: false, default: 0
  end

  def changeset(player_stats, attrs) do
    player_stats
    |> change(attrs)
    |> validate_required( @attrs)
  end
end
