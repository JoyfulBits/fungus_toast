defmodule FungusToast.Games.CellGrower do
  alias FungusToast.Random
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.Player
  alias FungusToast.Games.GridCell

  @doc ~S"""
    Iterates over surrounding cells calculating new growths, regenerations, and deaths. Returns GridCells that changed
  """
  @spec calculate_cell_growth(map(), %Player{}) :: [%GridCell{}]
  def calculate_cell_growth(surrounding_cells, player) do
    Enum.map(surrounding_cells, fn {k,v} -> process_cell(k, v, player) end)
      |> Enum.filter(fn x -> x != nil end)
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
  Returns a %GridCell{} if the growth chance corresponding to the cell position hits

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
  Returns a murdered %GridCell{} if the target cell is an enemy's live cell and the mycotoxin fungicide chance hits

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

  def check_for_regeneration(grid_cell, player) do
    if(Random.random_chance_hit(player.regeneration_chance)) do
      %{grid_cell | live: true, previous_player_id: grid_cell.player_id, player_id: player.id}
    end
  end

  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
