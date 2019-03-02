defmodule FungusToast.CellGrower do
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

  @spec try_growing_cell(atom(), integer(), %Player{}) :: [%GridCell{}]
  def try_growing_cell(position, cell_index, player) do
    {:ok, growth_attribute} = Map.fetch(Player.position_to_attribute_map, position)
    {:ok, growth_chance} = Map.fetch(player, growth_attribute)
    if(Random.random_chance_hit(growth_chance)) do
      %GridCell{index: cell_index, live: true, empty: false, out_of_grid: false, player_id: player.id}
    end
  end

  def check_for_mycotoxin_murder(grid_cell, mycotoxin_fungicide_chance) do
    if(Random.random_chance_hit(mycotoxin_fungicide_chance)) do
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
