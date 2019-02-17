defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid

  describe "create_starting_grid/3" do
    test "that each player gets a new cell" do
      new_grid = Grid.create_starting_grid(20, 20, [10, 20, 30])

      assert Enum.count(new_grid) == 3
    end

    test "that each player's designated cell is in the correct section of the grid" do
      player1 = 1
      player2 = 2
      player3 = 3
      player4 = 4
      player5 = 5
      
      
      new_grid = Grid.create_starting_grid(10, 10, [player1, player2, player3, player4, player5])

      #TODO
    end
  end
end
