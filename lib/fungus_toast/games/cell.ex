defmodule FungusToast.Games.Cell do
  @derive Jason.Encoder
  defstruct [:player_id, :cell_type]
end

