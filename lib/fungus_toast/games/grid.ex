defmodule FungusToast.Games.Grid do
    alias FungusToast.Games.GridCell

  def create_starting_grid(number_of_rows_and_columns, player_ids) do
    number_of_players = length(player_ids)

    initial_grid_cells_map = Enum.into(
      1..number_of_players,
      %{},
      &{&1, get_start_cell_index(number_of_rows_and_columns, number_of_players, &1)}
    )

    Enum.reduce(initial_grid_cells_map, %{}, fn {player_id, position}, map ->
      Map.put(map, position, %GridCell{
        index: position,
        player_id: player_id,
        live: true,
        empty: false
      })
    end)
  end

  def get_start_cell_index(grid_height_and_width, number_of_players, player_number) do
    grid_radius = grid_height_and_width / 2
    ten_percent_of_grid = grid_height_and_width / 10
    x_coordinate = (grid_radius - ten_percent_of_grid) * :math.cos(2 * :math.pi() * player_number / number_of_players) + grid_radius
    y_coordinate = (grid_radius - ten_percent_of_grid) * :math.sin(2 * :math.pi() * player_number / number_of_players) + grid_radius
    trunc(x_coordinate + grid_height_and_width * y_coordinate)
  end
end