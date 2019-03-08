defmodule FungusToast.Games.CellGrower do
  alias FungusToast.Random
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.Player
  alias FungusToast.Games.GridCell

  @starvation_death_chance 10.0

  @doc ~S"""
    Iterates over surrounding cells calculating new growths, regenerations, and deaths. Returns GridCells that changed
  """
  @spec calculate_cell_growth(map(), %Player{}) :: [%GridCell{}]
  def calculate_cell_growth(surrounding_cells, player) do
    Enum.map(surrounding_cells, fn {k,v} -> process_cell(k, v, player) end)
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.into(%{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
  end

  def process_cell(position, grid_cell, player) do
    if(grid_cell.empty) do
      try_growing_cell(position, grid_cell.index, player)
    else
      if(grid_cell.live) do
        check_for_mycotoxin_murder(grid_cell, player.mycotoxin_fungicide_chance)
      else
        if(!grid_cell.out_of_grid) do
          check_for_regeneration(grid_cell, player)
        end
      end
    end
  end

  @doc ~S"""
  Returns a %GridCell{} if the growth chance corresponding to the cell position hits. Returns nil otherwise.

  ## Examples

  #it generates a new live cell with that player's id if the growth percentage hits
  iex> CellGrower.try_growing_cell(:right_cell, 0, %FungusToast.Games.Player{right_growth_chance: 100, id: 1})
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: true,
    out_of_grid: false,
    player_id: 1,
    previous_player_id: nil
  }

  #it returns nil if the growth chance didn't hit
  iex> CellGrower.try_growing_cell(:right_cell, 0, %FungusToast.Games.Player{right_growth_chance: 0, id: 1})
  nil
  
  """
  @spec try_growing_cell(atom(), integer(), %Player{}) :: [%GridCell{}]
  def try_growing_cell(position, cell_index, player) do
    {:ok, growth_attribute} = Map.fetch(Player.position_to_attribute_map, position)
    {:ok, growth_chance} = Map.fetch(player, growth_attribute)
    if(Random.random_chance_hit(growth_chance)) do
      %GridCell{index: cell_index, live: true, empty: false, out_of_grid: false, player_id: player.id}
    end
  end

  @doc ~S"""
  Returns a murdered %GridCell{} if the target cell is an enemy's live cell and the mycotoxin fungicide chance hits. Returns nil otherwise.

  ## Examples

  #it kills the cell if the target cell is an enemy's live cell and the mycotoxin fungicide chance hits
  iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, empty: false, index: 0, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 100, id: 2})
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: false,
    out_of_grid: false,
    player_id: 1,
    previous_player_id: nil
  }

    #it returns nil if the cell is the current player's cell
    iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 100, id: 1})
    nil

    #it returns nil if the mycotoxin_fungicide_chance chance doesn't hit
    iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 0, id: 2})
    nil
  
  """
  def check_for_mycotoxin_murder(grid_cell, player) do
    if(grid_cell.player_id != player.id and Random.random_chance_hit(player.mycotoxin_fungicide_chance)) do
      %{grid_cell | live: false}
    end
  end

  @doc ~S"""
  Returns a live %GridCell{} with the player's id and previous player id set if the regeneration chance hits. Returns nil otherwise.

  ## Examples

  #it revives the dead cell and sets the new player_id while shifting the old one to the previous_player_id
  iex> CellGrower.check_for_regeneration(%GridCell{live: false, empty: false, player_id: 1, index: 0}, %FungusToast.Games.Player{regeneration_chance: 100, id: 2})
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: true,
    out_of_grid: false,
    player_id: 2,
    previous_player_id: 1
  }

  #it returns nil if the regeneration chance didn't hit
  iex> CellGrower.check_for_regeneration(%GridCell{}, %FungusToast.Games.Player{regeneration_chance: 0, id: 2})
  nil
  
  """
  def check_for_regeneration(grid_cell, player) do
    if(Random.random_chance_hit(player.regeneration_chance)) do
      %{grid_cell | live: true, previous_player_id: grid_cell.player_id, player_id: player.id}
    end
  end

  
  @doc ~S"""
  Returns %{} if the cell does not die, otherwise returns a killed %GridCell{}

  ## Examples

  #it returns %{} if the cell doesn't die
  iex>CellGrower.check_for_cell_death(%FungusToast.Games.GridCell{}, %{top_cell: %FungusToast.Games.GridCell{}}, %FungusToast.Games.Player{apoptosis_chance: 0})
  %{}

  """
  def check_for_cell_death(grid_cell, surrounding_cells, player) do
    if(dies_from_starvation(surrounding_cells) or dies_from_apoptosis(player)) do
      %{ grid_cell.index => %{grid_cell | live: false} }
    else
      %{}
    end
  end

  @doc ~S"""
  Returns true if the cell dies from starvation (when surrounding by live cells), false otherwise

  ## Examples

  #it dies if the cell is surrounded and the starvation chance hits
  iex> surrounding_cells = 
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 100)
  true

  #it does not die if the starvation chance misses
  iex> surrounding_cells = 
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 0)
  false

  #it does not die if not all of the surrounding cells are alive
  iex> surrounding_cells = 
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: false
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 100)
  false
  
  """
  def dies_from_starvation(surrounding_cells, starvation_chance \\ @starvation_death_chance) do
    Enum.all?(surrounding_cells, fn {k, v} -> v.live and Random.random_chance_hit(starvation_chance) end)
  end

  @doc ~S"""
  Returns true if the cell dies from apoptosis, false otherwise

  ## Examples

  #it dies if the apoptosis chance hits
  iex> CellGrower.dies_from_apoptosis(%FungusToast.Games.Player{apoptosis_chance: 100})
  true

  #it does not die if the apoptosis chance misses
  iex> CellGrower.dies_from_apoptosis(%FungusToast.Games.Player{apoptosis_chance: 0})
  false
  
  """
  def dies_from_apoptosis(player) do
    Random.random_chance_hit(player.apoptosis_chance)
  end

  @doc ~S"""
  Returns an out of grid cell

  ## Examples

  iex> CellGrower.make_out_of_grid_cell()
  %FungusToast.Games.GridCell{
    empty: false,
    index: nil,
    live: false,
    out_of_grid: true,
    player_id: nil,
    previous_player_id: nil
  }
  
  """
  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  @doc ~S"""
  Returns an empty cell at the specified cell_index

  ## Examples

  iex> CellGrower.make_empty_grid_cell(1)
  %FungusToast.Games.GridCell{
    empty: true,
    index: 1,
    live: false,
    out_of_grid: false,
    player_id: nil,
    previous_player_id: nil
  }
  
  """
  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
