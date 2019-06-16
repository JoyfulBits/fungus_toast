defmodule FungusToast.Games.PointsEarned do
  import Ecto.Changeset
  use Ecto.Schema

  @starting_mutation_points 5
  def starting_mutation_points, do: @starting_mutation_points
  @default_action_points_per_round 1
  def default_action_points_per_round, do: @default_action_points_per_round

  @attrs [
    :player_id,
    :points
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :player_id, :integer, null: false
    field :points, :integer, null: false
  end

  def changeset(grid_cell, attrs) do
    grid_cell
    |> change(attrs)
    |> validate_required( @attrs)
  end
end
