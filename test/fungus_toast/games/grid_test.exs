defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid

  describe "create_starting_grid/3" do
    test "that each player gets a new cell" do
      new_grid = Grid.create_starting_grid(20, 20, [10, 20, 30])

      assert Enum.count(new_grid) == 3
    end

    defp assert_index_between(grid, player_id, start_value_inclusive, end_value_exclusive) do
      tuple = Enum.find(grid, fn {k, v} -> v.player_id == player_id end)
      grid_cell = elem(tuple, 1)
      assert (grid_cell.index >= start_value_inclusive)
      assert(grid_cell.index < end_value_exclusive)
    end

    test "that each player's designated cell is in the correct section of the grid" do
      player1Id = 1
      player2Id = 2
      player3Id = 3
      player4Id = 4
      player5Id = 5

      new_grid = Grid.create_starting_grid(10, 10, [player1Id, player2Id, player3Id, player4Id, player5Id])

      assert_index_between(new_grid, player1Id, 0, 20)
      assert_index_between(new_grid, player2Id, 21, 40)
      assert_index_between(new_grid, player3Id, 41, 60)
      assert_index_between(new_grid, player4Id, 61, 80)
      assert_index_between(new_grid, player5Id, 81, 100)
      
      # Enum.each(new_grid, fn {k, v} -> case k.player_id do
      #   ^player1 -> assert v < 20
      #   ^player2 -> assert v > 20 and v < 40
      #   ^player3 -> assert v > 40 and v < 60
      #   ^player4 -> assert v > 60 and v < 80
      #   ^player5 -> assert v > 80 and v < 100
      #   end
      # end
      # )
    end
  end
end
