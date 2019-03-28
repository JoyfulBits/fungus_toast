defmodule FungusToast.Games.GameState do
  import Ecto.Changeset
  use Ecto.Schema

  @derive Jason.Encoder
  embedded_schema do
    field :round_number, :integer
    field :cells, :map
  end

  def changeset(growth_cycle, %__MODULE__{} = attrs) do
    changeset(growth_cycle, Map.from_struct(attrs))
  end

  def changeset(growth_cycle, attrs) do
    growth_cycle
    |> change(attrs)
    |> validate_required([:round_number, :cells])
  end
end
