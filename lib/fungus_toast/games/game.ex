defmodule FungusToast.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :number_of_human_players,
    :number_of_ai_players,
    :grid_size,
    :total_live_cells,
    :total_dead_cells,
    :total_moist_cells,
    :status,
    :end_of_game_count_down,
    :light_level
  ]

  @default_grid_size 50
  def default_grid_size, do: @default_grid_size
  @default_light_level 50
  def default_light_level, do: @default_light_level

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "games" do
    field :status, :string, default: FungusToast.Game.Status.status_not_started
    field :grid_size, :integer, default: @default_grid_size, null: false
    field :number_of_human_players, :integer, null: false
    field :number_of_ai_players, :integer, default: 0, null: false
    field :total_live_cells, :integer, default: 0, null: false
    field :total_dead_cells, :integer, default: 0, null: false
    field :total_moist_cells, :integer, default: 0, null: false
    field :end_of_game_count_down, :integer, default: nil, null: true
    field :light_level, :integer, default: @default_light_level, null: false

    has_many :rounds, FungusToast.Games.Round, on_delete: :delete_all
    has_many :players, FungusToast.Games.Player, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, @attrs)
    |> validate_required([:number_of_human_players])
    |> validate_inclusion(:status, FungusToast.Game.Status.statuses)
  end

  @doc """
  Return the number of empty cells left on the grid
  """
  def number_of_empty_cells(game) do
    game.grid_size * game.grid_size - game.total_live_cells - game.total_dead_cells - game.total_moist_cells
  end
end
