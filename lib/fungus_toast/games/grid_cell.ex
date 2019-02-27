defmodule FungusToast.Games.GridCell do
  defstruct index: nil, live: false, empty: true, out_of_grid: false, player_id: nil, previous_player_id: nil
end
