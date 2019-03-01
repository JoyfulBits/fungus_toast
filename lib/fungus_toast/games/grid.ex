defmodule FungusToast.Games.Grid do
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.SurroundingCells
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

  def generate_growth_cycles(starting_grid, grid_size, player_id_to_player_map, number_of_growth_cycles) do
    live_cells = :maps.filter(fn _, grid_cell -> grid_cell.live end, starting_grid)

    #TODO return a map of index => %GridCell{} for newly grown and newly perished cells ONLY (i.e. changes only)
    Enum.map(live_cells, fn{x, y} -> {x, calculate_cell_growth(starting_grid, grid_size, player_id_to_player_map, y)} end)
  end

  def calculate_cell_growth(starting_grid, grid_size, player_id_to_player_map, grid_cell) do
    #TODO get ALL surrounding cells (we'll need empty and live, dead, and empty ones)
    #surrounding_cells = get_surrounding_cells(starting_grid, grid_size, grid_cell.index)

    #empty_surrounding_cells = :maps.filter(fn (_, v) -> v.empty end)

    #iterate over empty cells and calculate generate cells according ot the corresponding probabilities on player.*growth_chance. 
    #Return a list of newly generated GridCells

    #iterate over adjacent dead cells to calculate whether the cell is regenerated according to player.regeneration_chance
    #add to the map of live cells if the cell was regenerated
    #dead_surrounding_cells = :maps.filter(fn (_, v) -> !v.live end)

    #check if the cell dies from apoptosis, starvation, or mycotoxins
    #check_for_cell_death(grid_cell, surrounding_cells)

    #return a tuple which includes new split cells and regenerated cells, and and an indicator of whether the current cell died
  end

  def get_surrounding_cells(grid, grid_size, cell_index) do
    %SurroundingCells{
      top_left_cell: get_top_left_cell(grid, grid_size, cell_index), 
      top_cell: get_top_cell(grid, grid_size, cell_index), 
      top_right_cell: get_top_right_cell(grid, grid_size, cell_index), 
      right_cell: get_right_cell(grid, grid_size, cell_index), 
      bottom_right_cell: get_bottom_right_cell(grid, grid_size, cell_index), 
      bottom_cell: get_bottom_cell(grid, grid_size, cell_index), 
      bottom_left_cell: get_bottom_left_cell(grid, grid_size, cell_index), 
      left_cell: get_left_cell(grid, grid_size, cell_index)}
  end

  @doc ~S"""
  Returns true if the given cell_index is on the top row of the grid

  ## Examples

    iex> Grid.on_top_row(0, 50)
    true

    iex> Grid.on_top_row(49, 50)
    true

    iex> Grid.on_top_row(50, 50)
    false
  
  """
  def on_top_row(cell_index, grid_size) do
    cell_index in 0..(grid_size - 1)
  end

 @doc ~S"""
  Returns true if the given cell_index is on the right column of the grid

  ## Examples

    #first row, last column
    iex> Grid.on_right_column(49, 50)
    true

    #second row, last column
    iex> Grid.on_right_column(99, 50)
    true

    #first row, 2nd to last column
    iex> Grid.on_right_column(48, 50)
    false
  
  """
  def on_right_column(cell_index, grid_size) do
    rem(cell_index + 1, grid_size) == 0
  end

 @doc ~S"""
  Returns true if the given cell_index is on the bottom row of the grid

  ## Examples

    iex> Grid.on_bottom_row(2450, 50)
    true

    iex> Grid.on_bottom_row(2499, 50)
    true
    
    iex> Grid.on_bottom_row(2449, 50)
    false
  
  """
  def on_bottom_row(cell_index, grid_size) do
    cell_index >= grid_size*grid_size - grid_size
  end

  @doc ~S"""
  Returns true if the given cell_index is on the left column of the grid

  ## Examples

    iex> Grid.on_left_column(0, 50)
    true

    iex> Grid.on_left_column(2450, 50)
    true
    
    iex> Grid.on_left_column(1, 50)
    false
  
  """
  def on_left_column(cell_index, grid_size) do
    rem(cell_index, grid_size) == 0
  end


  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_top_left_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_left_cell(%{}, 50, 51)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_left_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 51)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }
  
  """
  def get_top_left_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size) or on_left_column(cell_index, grid_size)) do
      make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size - 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is directly above of the specified cell

  ## Examples

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }
  
  """
  def get_top_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size)) do
      make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the top right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_right_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the right column
    iex> Grid.get_top_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }


    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_right_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_right_cell(%{1 => %FungusToast.Games.GridCell{index: 1}}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }
  
  """
  def get_top_right_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size) or on_right_column(cell_index, grid_size)) do
      make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size + 1
      get_target_cell(grid, target_cell_index)
    end
  end

@doc ~S"""
  Returns a %GridCell{} for the position that is directly to the right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the right column
    iex> Grid.get_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_right_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_right_cell(%{1 => %FungusToast.Games.GridCell{index: 1}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }
  
  """
  def get_right_cell(grid, grid_size, cell_index) do
    if(on_right_column(cell_index, grid_size)) do
      make_out_of_grid_cell()
    else
      target_cell_index = cell_index + 1
      get_target_cell(grid, target_cell_index)
    end
  end

  def get_bottom_right_cell(grid, grid_size, cell_index) do

  end

  def get_bottom_cell(grid, grid_size, cell_index) do

  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_bottom_left_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_left_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_left_cell(%{50 => %FungusToast.Games.GridCell{index: 50}}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }
  
  """
  def get_bottom_left_cell(grid, grid_size, cell_index) do
    target_cell_index = cell_index + grid_size - 1
    if(on_bottom_row(cell_index, grid_size) or on_left_column(cell_index, grid_size)) do
      make_out_of_grid_cell()
    else
      get_target_cell(grid, target_cell_index)
    end
  end

  def get_left_cell(grid, grid_size, cell_index) do

  end

  defp get_target_cell(grid, target_cell_index) do
    if(Map.has_key?(grid, target_cell_index)) do
      Map.get(grid, target_cell_index)
    else
      make_empty_grid_cell(target_cell_index)
    end
  end

  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
