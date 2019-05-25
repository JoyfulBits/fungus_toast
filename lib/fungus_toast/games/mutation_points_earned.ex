defmodule FungusToast.Games.MutationPointsEarned do
  import Ecto.Changeset
  use Ecto.Schema

  @attrs [
    :player_id,
    :mutation_points
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :player_id, :integer, null: false
    field :mutation_points, :integer, null: false
  end

  def changeset(grid_cell, attrs) do
    grid_cell
    |> change(attrs)
    |> validate_required( @attrs)
  end
end
