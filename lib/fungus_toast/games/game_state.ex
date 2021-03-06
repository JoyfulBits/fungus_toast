defmodule FungusToast.Games.GameState do
  import Ecto.Changeset
  use Ecto.Schema

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    #TODO remove round_number here. It is redundant with Round.round_number
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
