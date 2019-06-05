defmodule FungusToast.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @position_to_attribute_map %{
    :top_left_cell => :top_left_growth_chance,
    :top_cell => :top_growth_chance,
    :top_right_cell => :top_right_growth_chance,
    :right_cell => :right_growth_chance,
    :bottom_right_cell => :bottom_right_growth_chance,
    :bottom_cell => :bottom_growth_chance,
    :bottom_left_cell => :bottom_left_growth_chance,
    :left_cell => :left_growth_chance
  }

  def position_to_attribute_map, do: @position_to_attribute_map

  @default_top_right_bottom_left_growth_chance 6.0
  @default_mutation_chance 10.0
  @default_apoptosis_chance 5.0
  @default_starved_cell_death_chance 10.0
  @default_moisture_boost 2.0

  @default_starting_mutation_points 5
  def default_starting_mutation_points, do: @default_starting_mutation_points

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
    :perished_cells,
    :grown_cells,
    :fungicidal_kills,
    :lost_dead_cells,
    :apoptosis_chance,
    :starved_cell_death_chance,
    :mutation_chance,
    :regeneration_chance,
    :mycotoxin_fungicide_chance,
    :moisture_growth_boost,
    :spent_mutation_points,
    :user_id
  ]

  @required_attrs [
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
    :perished_cells,
    :grown_cells,
    :fungicidal_kills,
    :lost_dead_cells,
    :apoptosis_chance,
    :starved_cell_death_chance,
    :mutation_chance,
    :regeneration_chance,
    :mycotoxin_fungicide_chance,
    :moisture_growth_boost,
    :spent_mutation_points
  ]

  @derive {Jason.Encoder, only: [:id, :skills] ++ @attrs}

  schema "players" do
    field :name, :string, null: false
    field :human, :boolean, default: false, null: false
    field :ai_type, :string, null: true

    field :mutation_points, :integer, default: @default_starting_mutation_points, null: false

    field :top_left_growth_chance, :float, default: 0.0, null: false
    field :top_growth_chance, :float, default: @default_top_right_bottom_left_growth_chance, null: false
    field :top_right_growth_chance, :float, default: 0.0, null: false
    field :right_growth_chance, :float, default: @default_top_right_bottom_left_growth_chance, null: false
    field :bottom_right_growth_chance, :float, default: 0.0, null: false
    field :bottom_growth_chance, :float, default: @default_top_right_bottom_left_growth_chance, null: false
    field :bottom_left_growth_chance, :float, default: 0.0, null: false
    field :left_growth_chance, :float, default: @default_top_right_bottom_left_growth_chance, null: false

    field :dead_cells, :integer, default: 0, null: false
    field :live_cells, :integer, default: 0, null: false

    field :regenerated_cells, :integer, default: 0, null: false
    field :grown_cells, :integer, default: 0, null: false
    field :perished_cells, :integer, default: 0, null: false
    field :fungicidal_kills, :integer, default: 0, null: false
    field :lost_dead_cells, :integer, default: 0, null: false

    field :spent_mutation_points, :integer, default: 0, null: false

    field :apoptosis_chance, :float, default: @default_apoptosis_chance, null: false
    field :starved_cell_death_chance, :float, default: @default_starved_cell_death_chance, null: false
    field :mutation_chance, :float, default: @default_mutation_chance, null: false
    field :regeneration_chance, :float, default: 0.0, null: false
    field :mycotoxin_fungicide_chance, :float, default: 0.0, null: false
    field :moisture_growth_boost, :float, default: @default_moisture_boost, null: false

    has_many :skills, FungusToast.Games.PlayerSkill

    belongs_to :user, FungusToast.Accounts.User
    belongs_to :game, FungusToast.Games.Game

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
  end
end
