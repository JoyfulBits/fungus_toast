defmodule FungusToast.Games.SurroundingCells do
  alias FungusToast.Random
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.SurroundingCells
  alias FungusToast.Games.Player
  #defstruct top_left_cell: nil, top_cell: nil, top_right_cell: nil, right_cell: nil, bottom_right_cell: nil, bottom_cell: nil, bottom_left_cell: nil, left_cell: nil

  @spec get_new_cells(map(), %Player{}) :: [%GridCell{}]
  def get_new_cells(surrounding_cells, player) do
    # []
    #   ++ [grow_top_left(surrounding_cells.top_left_cell, player.top_left_growth_chance)]
  end

  @spec try_growing_cell(%GridCell{}, float()) :: [%GridCell{}]
  def try_growing_cell(grid_cell, growth_chance) do
    if(grid_cell.empty && Random.random_chance_hit(growth_chance)) do

    else

    end
  end
end
