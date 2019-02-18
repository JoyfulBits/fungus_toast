defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid

  describe "create_starting_grid/3" do
    test "that each player gets a new cell" do
      new_grid = Grid.create_starting_grid(20, 20, [10, 20, 30])

      assert Enum.count(new_grid) == 3
    end

    defp assert_index_between(grid, player_id, start_value_inclusive, end_value_exclusive) do
      tuple = Enum.find(grid, fn {_, v} -> v.player_id == player_id end)
      grid_cell = elem(tuple, 1)
      assert(grid_cell.index >= start_value_inclusive)
      assert(grid_cell.index < end_value_exclusive)
    end

    test "that each player's designated cell is in the correct section of the grid" do
      player1Id = 1
      player2Id = 2
      player3Id = 3
      player4Id = 4
      player5Id = 5

      new_grid = Grid.create_starting_grid(10, 10, [player1Id, player2Id, player3Id, player4Id, player5Id])

      assert_index_between(new_grid, player1Id, 0, 19)
      assert_index_between(new_grid, player2Id, 20, 39)
      assert_index_between(new_grid, player3Id, 40, 59)
      assert_index_between(new_grid, player4Id, 60, 79)
      assert_index_between(new_grid, player5Id, 80, 99)
    end

    # test "that a starting cell is not empty, is alive, and is assigned to the player" do
    #   player1Id = 1

    #   new_grid = Grid.create_starting_grid(10, 10, [player1Id])

    #   grid_cell = new_grid[player1Id]

    #   assert (grid_cell.empty == false)
    # end
  end
end
