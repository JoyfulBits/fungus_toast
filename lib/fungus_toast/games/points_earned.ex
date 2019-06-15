defmodule FungusToast.Games.PointsEarned do
  import Ecto.Changeset
  use Ecto.Schema

  @starting_mutation_points 5
  def starting_mutation_points, do: @starting_mutation_points
  @starting_action_points 1
  def starting_action_points, do: @starting_action_points

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
