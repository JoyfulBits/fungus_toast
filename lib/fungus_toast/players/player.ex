defmodule FungusToast.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :name,
    :human,
    :mutation_points,
    :top_left_growth_chance,
    :top_growth_chance,
    :top_right_growth_chance,
    :right_growth_chance,
    :bottom_right_growth_chance,
    :bottom_growth_chance,
    :bottom_left_growth_chance,
    :left_growth_chance,
    :dead_cells,
    :live_cells,
    :regenerated_cells,
    :apoptosis_chance,
    :starved_cell_death_chance,
    :mutation_chance,
    :regeneration_chance,
    :mycotoxin_fungicide_chance
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "players" do
    field :name, :string, null: false
    field :human, :boolean, default: false, null: false

    field :mutation_points, :integer, default: 0, null: false

    field :top_left_growth_chance, :float, default: 0.0, null: false
    field :top_growth_chance, :float, default: 0.0, null: false
    field :top_right_growth_chance, :float, default: 0.0, null: false
    field :right_growth_chance, :float, default: 0.0, null: false
    field :bottom_right_growth_chance, :float, default: 0.0, null: false
    field :bottom_growth_chance, :float, default: 0.0, null: false
    field :bottom_left_growth_chance, :float, default: 0.0, null: false
    field :left_growth_chance, :float, default: 0.0, null: false

    field :dead_cells, :integer, default: 0, null: false
    field :live_cells, :integer, default: 0, null: false
    field :regenerated_cells, :integer, default: 0, null: false

    field :apoptosis_chance, :float, default: 0.0, null: false
    field :starved_cell_death_chance, :float, default: 0.0, null: false
    field :mutation_chance, :float, default: 0.0, null: false
    field :regeneration_chance, :float, default: 0.0, null: false
    field :mycotoxin_fungicide_chance, :float, default: 0.0, null: false

    belongs_to :user, FungusToast.Accounts.User
    belongs_to :game, FungusToast.Games.Game

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
