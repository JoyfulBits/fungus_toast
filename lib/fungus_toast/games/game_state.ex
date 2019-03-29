defmodule FungusToast.Games.GameState do
  import Ecto.Changeset
  use Ecto.Schema

  @derive Jason.Encoder
  embedded_schema do
    field :round_number, :integer
    embeds_many :cells, FungusToast.Games.GridCell, on_replace: :delete
  end

  def changeset(growth_cycle, %__MODULE__{} = attrs) do
    changeset(growth_cycle, Map.from_struct(attrs))
  end

  def changeset(growth_cycle, attrs) do
    growth_cycle
    |> change(attrs)
    |> cast_embed(:cells)
    |> validate_required([:round_number, :cells])
  end
end
