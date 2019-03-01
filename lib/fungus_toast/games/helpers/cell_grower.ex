defmodule FungusToast.CellGrower do
  alias FungusToast.Random
  alias FungusToast.Games.GridCell
  alias FungusToast.Games.Player
  alias FungusToast.Games.GridCell

  @spec grow_new_cells(integer(), map(), %Player{}) :: [%GridCell{}]
  def grow_new_cells(cell_index, surrounding_cells, player) do
    Enum.map(surrounding_cells, fn {k,v} -> try_growing_cell(k, v.index, player) end)
      |> Enum.filter(fn x -> x != nil end)
  end

  @spec try_growing_cell(atom(), integer(), %Player{}) :: [%GridCell{}]
  def try_growing_cell(position, cell_index, player) do
    {:ok, growth_attribute} = Map.fetch(Player.position_to_attribute_map, position)
    {:ok, growth_chance} = Map.fetch(player, growth_attribute)
    if(Random.random_chance_hit(growth_chance)) do
      %GridCell{index: cell_index, live: true, empty: false, out_of_grid: false, player_id: player.id}
    end
  end

  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
