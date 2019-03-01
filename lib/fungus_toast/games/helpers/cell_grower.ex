defmodule FungusToast.CellGrower do
  alias FungusToast.Random
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.Player
  alias FungusToast.Games.GridCell

  @spec grow_new_cells(integer(), map(), %Player{}) :: [%GridCell{}]
  def grow_new_cells(cell_index, surrounding_cells, player) do
    # []
    #   ++ [grow_top_left(surrounding_cells.top_left_cell, player.top_left_growth_chance)]
  end

  @spec try_growing_cell(integer(), integer(), float()) :: [%GridCell{}]
  def try_growing_cell(cell_index, player_id, growth_chance) do
    if(Random.random_chance_hit(growth_chance)) do
      %GridCell{index: cell_index, live: true, empty: false, out_of_grid: false, player_id: player_id}
    end
  end

  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
