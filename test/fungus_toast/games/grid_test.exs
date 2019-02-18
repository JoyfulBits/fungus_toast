defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid

  describe "create_starting_grid/3" do
    test "that each player gets a new cell" do
      new_grid = Grid.create_starting_grid(20, 20, [10, 20, 30])

      assert Enum.count(new_grid) == 3
    end

    defp find_grid_cell_for_player(grid, player_id) do
      tuple = Enum.find(grid, fn {_, v} -> v.player_id == player_id end)
      elem(tuple, 1)
    end

    defp assert_index_between(grid, player_id, start_value_inclusive, end_value_exclusive) do
      grid_cell = find_grid_cell_for_player(grid, player_id)
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

    test "that a starting cell is not empty, is alive, and is assigned to the player" do
      player1Id = 1

      new_grid = Grid.create_starting_grid(10, 10, [player1Id])

      player_cell = find_grid_cell_for_player(new_grid, player1Id)

      assert (player_cell.empty == false)
      assert (player_cell.live == true)
      assert (player_cell.player_id == player1Id)
      #make sure the map key is the same as the cell index
      start_index = hd(Map.keys(new_grid))
      assert (player_cell.index == start_index)
      refute (player_cell.previous_player_id)
    end
  end
end
