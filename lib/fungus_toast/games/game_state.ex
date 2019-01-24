defmodule FungusToast.Games.Game.State do
  @derive Jason.Encoder
  defstruct cells: []

  defmodule Cell do
    @derive Jason.Encoder
    defstruct [:index, :player_id, :cell_type]
  end
end
