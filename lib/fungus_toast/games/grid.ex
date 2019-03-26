defmodule FungusToast.Games.Grid do
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.CellGrower
  alias FungusToast.Games.GrowthCycle
  alias FungusToast.Random
  import :math

  @spec create_starting_grid(integer(), [integer()]) :: map()
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

  @spec get_start_cell_index(integer(), integer(), integer()) :: integer()
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

  # TODO: This doctest is flaky... look into this
  @doc ~S"""
  Returns the specified number of growth cycles, as well as the ending game state.
  
  ##Examples
  iex> Grid.generate_growth_summary(%{}, 50, %{1 => %Player{top_growth_chance: 100, id: 1, mutation_chance: 0}})
  %{
    growth_cycles: [
      %FungusToast.Games.GrowthCycle{
        generation_number: 1,
        mutation_points_earned: %{1 => 1},
        toast_changes: %{}
      },
      %FungusToast.Games.GrowthCycle{
        generation_number: 2,
        mutation_points_earned: %{1 => 1},
        toast_changes: %{}
      },
      %FungusToast.Games.GrowthCycle{
        generation_number: 3,
        mutation_points_earned: %{1 => 1},
        toast_changes: %{}
      },
      %FungusToast.Games.GrowthCycle{
        generation_number: 4,
        mutation_points_earned: %{1 => 1},
        toast_changes: %{}
      },
      %FungusToast.Games.GrowthCycle{
        generation_number: 5,
        mutation_points_earned: %{1 => 1},
        toast_changes: %{}
      }
    ],
    new_game_state: %{}
  }

  """
  def generate_growth_summary(starting_grid, grid_size, player_id_to_player_map, generation_number \\ 1, acc \\ [])
  @spec generate_growth_summary(map(), integer(), map(), integer(), list()) :: any()
  def generate_growth_summary(starting_grid, grid_size, player_id_to_player_map, generation_number, acc) when generation_number < 6 do
    live_cells = Enum.filter(starting_grid, fn {_, grid_cell} -> grid_cell.live end)
      |> Enum.into(%{})

    toast_changes = Enum.map(live_cells, fn{_, grid_cell} -> generate_toast_changes(starting_grid, grid_size, player_id_to_player_map, grid_cell) end)
      |> Enum.reduce(%{}, fn(x, acc) -> Map.merge(x, acc) end)

    mutation_points_earned = Enum.map(player_id_to_player_map, fn{player_id, player} -> {player_id, calculate_mutation_points(player)} end)
      |> Enum.into(%{})

    growth_cycle = %GrowthCycle{ generation_number: generation_number, toast_changes: toast_changes, mutation_points_earned: mutation_points_earned }

    #merge the maps together. The changes from the growth cycle replace what's in the grid if there are conflicts.
    Map.merge(starting_grid, toast_changes, fn _index, _grid_cell_1, grid_cell_2 -> grid_cell_2 end)
    |> generate_growth_summary(grid_size, player_id_to_player_map, generation_number + 1, acc ++ [growth_cycle])
  end

  def generate_growth_summary(ending_grid, _, _, _, acc), do: %{growth_cycles: acc, new_game_state: ending_grid}

  def generate_toast_changes(starting_grid, grid_size, player_id_to_player_map, grid_cell) do
    surrounding_cells = get_surrounding_cells(starting_grid, grid_size, grid_cell.index)

    player = player_id_to_player_map[grid_cell.player_id]
    cell_changes = CellGrower.calculate_cell_growth(surrounding_cells, player)
    #check if the cell dies from apoptosis or starvation
    Map.merge(cell_changes, CellGrower.check_for_cell_death(grid_cell, surrounding_cells, player))
  end

  def get_surrounding_cells(grid, grid_size, cell_index) do
    %{
      :top_left_cell => get_top_left_cell(grid, grid_size, cell_index),
      :top_cell => get_top_cell(grid, grid_size, cell_index),
      :top_right_cell => get_top_right_cell(grid, grid_size, cell_index),
      :right_cell => get_right_cell(grid, grid_size, cell_index),
      :bottom_right_cell => get_bottom_right_cell(grid, grid_size, cell_index),
      :bottom_cell => get_bottom_cell(grid, grid_size, cell_index),
      :bottom_left_cell => get_bottom_left_cell(grid, grid_size, cell_index),
      :left_cell => get_left_cell(grid, grid_size, cell_index)
    }
  end

  @doc ~S"""
  Returns the number of mutation points earned by the player during this growth cycle based on the player's mutation_chance + 1

  ## Examples

    iex(83)> Grid.calculate_mutation_points(%FungusToast.Games.Player{mutation_chance: 100})
    2

    iex(83)> Grid.calculate_mutation_points(%FungusToast.Games.Player{mutation_chance: 0})
    1

  """
  def calculate_mutation_points(player) do
    if(Random.random_chance_hit(player.mutation_chance)) do
      #for now, you generate one mutation point at a time
      2
    else
      1
    end
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
      CellGrower.make_out_of_grid_cell()
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
      CellGrower.make_out_of_grid_cell()
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
      CellGrower.make_out_of_grid_cell()
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
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the right column
    iex> Grid.get_bottom_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_right_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_right_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 51,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_right_cell(%{51 => %FungusToast.Games.GridCell{index: 51}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 51,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_bottom_right_cell(grid, grid_size, cell_index) do
    if(on_right_column(cell_index, grid_size) or on_bottom_row(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + grid_size + 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom of the specified cell

  ## Examples

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_cell(%{51 => %FungusToast.Games.GridCell{index: 50}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_bottom_cell(grid, grid_size, cell_index) do
    if(on_bottom_row(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + grid_size
      get_target_cell(grid, target_cell_index)
    end
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
      CellGrower.make_out_of_grid_cell()
    else
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is directly to the left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_left_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_left_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_left_cell(grid, grid_size, cell_index) do
    if(on_left_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index - 1
      get_target_cell(grid, target_cell_index)
    end
  end

  def get_target_cell(grid, target_cell_index) do
    if(Map.has_key?(grid, target_cell_index)) do
      Map.get(grid, target_cell_index)
    else
      CellGrower.make_empty_grid_cell(target_cell_index)
    end
  end
end
