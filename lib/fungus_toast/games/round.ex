defmodule FungusToast.Games.Round do
  use Ecto.Schema
  import Ecto.Changeset

  @required_attrs [
    :number,
    :starting_game_state
  ]

  @derive {Jason.Encoder, only: [:id, :number]}

  schema "rounds" do
    embeds_one :starting_game_state, FungusToast.Games.GameState, on_replace: :delete
    embeds_many :growth_cycles, FungusToast.Games.GrowthCycle, on_replace: :delete
    embeds_many :starting_player_stats, FungusToast.Games.PlayerStats, on_replace: :delete
    embeds_many :active_cell_changes, FungusToast.Games.ActiveCellChange, on_replace: :delete
    field :number, :integer, default: 1, null: false

    belongs_to :game, FungusToast.Games.Game

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> change(attrs)
    |> cast_embed(:starting_game_state)
    |> cast_embed(:growth_cycles)
    |> cast_embed(:active_cell_changes)
    |> validate_required(@required_attrs)
  end
end
