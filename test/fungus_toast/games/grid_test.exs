defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid
  doctest FungusToast.Games.Grid 

  describe "create_starting_grid/3" do
    test "that each player gets a new cell" do
      player_ids = [10, 20, 30]
      new_grid = Grid.create_starting_grid(20, player_ids)

      assert Enum.count(new_grid) == length(player_ids)
    end

    test "that a large enough grid adequetly places the number of players" do
      player_ids = [1,2,3,4,5]
      grid = Grid.create_starting_grid(20, player_ids)

      assert Map.size(grid) == length(player_ids)
    end

    test "that an error is returned if the grid is too small" do
      player_ids = [1,2,3,4,5]

      error =
        Grid.create_starting_grid(2, player_ids)

      assert {:error, "A grid size of 2x2 is too small. The minimum grid size is 10x10."} = error
    end

    test "that an error is returned if there are too many players to allow for at least 100 empty spaces" do
      error =
        Grid.create_starting_grid(10, [1])

      assert {:error, "There needs to be at least 100 cells left over after placing starting cells, but there was only 99."} = error
    end

    test "that a starting cell is not empty, is alive, and is assigned to the player" do
      player1Id = 1

      new_grid = Grid.create_starting_grid(20, [player1Id])

      player_cell = find_grid_cell_for_player(new_grid, player1Id)

      assert player_cell.empty == false
      assert player_cell.live == true
      assert player_cell.player_id == player1Id
      # make sure the map key is the same as the cell index	      assert player_cell.index != nil
      start_index = hd(Map.keys(new_grid))	
      assert player_cell.index == start_index
      refute player_cell.previous_player_id
    end

    defp find_grid_cell_for_player(grid, player_id) do
      tuple = Enum.find(grid, fn {_, v} -> v.player_id == player_id end)
      elem(tuple, 1)
    end
  end

end
