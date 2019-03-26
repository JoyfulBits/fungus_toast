defmodule FungusToast.Games.GameState do
  @derive Jason.Encoder
  defstruct cells: %{}, round_number: 0
end
