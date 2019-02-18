defmodule FungusToast.Games.Grid do
    alias FungusToast.Games.GridCell

def create_starting_grid(number_of_rows, number_of_columns, player_ids) do
    initial_grid_cells_map = map_of_player_id_to_random_grid_index(number_of_rows, number_of_columns, player_ids)

    Enum.reduce(initial_grid_cells_map, %{}, fn {player_id, position}, map ->
      Map.put(map, position, %GridCell{
        index: position,
        player_id: player_id,
        live: true,
        empty: false
      })
    end)
  end

  defp map_of_player_id_to_random_grid_index(number_of_rows, number_of_columns, player_ids) do
    number_of_players = length(player_ids)
    number_of_cells_to_choose_from = number_of_columns * number_of_rows / number_of_players
    Enum.into(
      0..number_of_players - 1,
      %{},
      &{Enum.at(player_ids, &1),
       Enum.random(
         Kernel.trunc((&1) * (number_of_cells_to_choose_from))..Kernel.trunc(
           (&1 + 1) * (number_of_cells_to_choose_from) - 1
         )
       )}
    )
  end

end