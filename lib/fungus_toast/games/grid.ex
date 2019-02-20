defmodule FungusToast.Games.Grid do
  alias FungusToast.Games.GridCell
  import :math

  @spec create_starting_grid(any(), [any()]) :: any()
  def create_starting_grid(number_of_rows_and_columns, player_ids) do
    number_of_players = length(player_ids)

    if(number_of_rows_and_columns < 10) do
      {:error,
      "A grid size of #{number_of_rows_and_columns}x#{number_of_rows_and_columns} is too small. The minimum grid size is 10x10."}
    else
      number_of_empty_cells_after_placing_start_cells = number_of_rows_and_columns * number_of_rows_and_columns - number_of_players
      if(number_of_empty_cells_after_placing_start_cells < 100) do
        {:error,
        "There needs to be at least 100 cells left over after placing starting cells, but there was only #{number_of_empty_cells_after_placing_start_cells}."}
      else
        initial_grid_cells_map =
        Enum.into(
          1..number_of_players,
          %{},
          &{&1, get_start_cell_index(number_of_rows_and_columns, number_of_players, &1)}
        )

        starting_grid =
          Enum.reduce(initial_grid_cells_map, %{}, fn {player_id, position}, map ->
            Map.put(map, position, %GridCell{
              index: position,
              player_id: player_id,
              live: true,
              empty: false
            })
          end)
      end
    end
  end

  def get_start_cell_index(grid_height_and_width, number_of_players, player_number) do
    grid_radius = grid_height_and_width / 2
    ten_percent_of_grid = grid_height_and_width / 10

    x_coordinate =
      (grid_radius - ten_percent_of_grid) * cos(2 * pi() * player_number / number_of_players) +
        grid_radius

    y_coordinate =
      (grid_radius - ten_percent_of_grid) * sin(2 * pi() * player_number / number_of_players) +
        grid_radius

    trunc(x_coordinate + grid_height_and_width * y_coordinate)
  end
end
