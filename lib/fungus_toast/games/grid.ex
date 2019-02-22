defmodule FungusToast.Games.Grid do
  alias FungusToast.Games.GridCell
  import :math

  @spec create_starting_grid(any(), [any()]) :: any()
  def create_starting_grid(grid_size, player_ids) do
    number_of_players = length(player_ids)

    if(grid_size < 10) do
      {:error,
      "A grid size of #{grid_size}x#{grid_size} is too small. The minimum grid size is 10x10."}
    else
      number_of_empty_cells_after_placing_start_cells = grid_size * grid_size - number_of_players
      if(number_of_empty_cells_after_placing_start_cells < 100) do
        {:error,
        "There needs to be at least 100 cells left over after placing starting cells, but there was only #{number_of_empty_cells_after_placing_start_cells}."}
      else
        initial_grid_cells_map =
        Enum.into(
          1..number_of_players,
          %{},
          &{&1, get_start_cell_index(grid_size, number_of_players, &1)}
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

  def generate_growth_cycles(starting_grid, player_id_to_player_map, number_of_growth_cycles) do
    #TODO get the live cells
    #live_cells = :maps.filter fn _, v -> v.live end, v

    #TODO return a map of index => %GridCell{} 
    #Enum.each(live_cells, fn(x, y) -> {calculate_cell_growth(starting_grid, player_id_to_player_map, y) end)
  end

  def calculate_cell_growth(starting_grid, player_id_to_player_map, grid_cell) do
    #TODO get ALL surrounding cells (we'll need empty and live, dead, and empty ones)
    #surrounding_cells = get_surrounding_cells(starting_grid, grid_cell.index)

    #empty_surrounding_cells = :maps.filter(fn (_, v) -> v.empty end)

    #iterate over empty cells and calculate generate cells according ot the corresponding probabilities on player.*growth_chance. 
    #Return a list of newly generated GridCells

    #iterate over adjacent dead cells to calculate whether the cell is regenerated according to player.regeneration_chance

    #check if the cell dies from apoptosis, starvation, or mycotoxins
    #check_for_cell_death(grid_cell, surrounding_cells)

    #return a tuple which includes new split cells and regenerated cells, and and an indicator of whether the current cell died
  end

  def get_surrounding_cells(grid, cell_index) do
    #TODO
  end
end
