defmodule FungusToast.Games.GridCell do
  @derive Jason.Encoder
  defstruct index: nil, live: false, empty: true, out_of_grid: false, player_id: nil, previous_player_id: nil
end
