defmodule FungusToast.Games.GridCell do
  import Ecto.Changeset
  use Ecto.Schema

  @required_attrs [
    :live,
    :empty,
    :out_of_grid
  ]

  @derive Jason.Encoder
  embedded_schema do
    field :index, :integer, null: true
    field :live, :boolean, null: false, default: false
    field :empty, :boolean, null: false, default: true
    field :out_of_grid, :boolean, null: false, default: false
    field :player_id, :integer, null: true
    field :killed_by, :integer, null: true
    field :previous_player_id, :integer, null: true
  end

  def changeset(grid_Cell, attrs) do
    grid_Cell
    |> change(attrs)
    |> validate_required(@required_attrs)
  end
end
