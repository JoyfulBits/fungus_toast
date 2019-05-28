defmodule FungusToast.Games.ActiveCellChange do
  import Ecto.Changeset
  use Ecto.Schema

  @required_attrs [
    :player_id,
    :skill_id,
    :cell_indexes
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :player_id, :integer, null: false
    field :skill_id, :integer, null: false
    field :cell_indexes, {:array, :integer}, on_replace: :delete
  end

  def changeset(active_cell_change, attrs) do
    active_cell_change
    |> change(attrs)
    |> validate_required(@required_attrs)
  end
end
