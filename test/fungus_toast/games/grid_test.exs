defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Grid
  alias FungusToast.Games.Player

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

  describe "generate_growth_cycles/5" do
    test "a single player game with no growth or mutation chance will generate 5 sequential growth cycles with no toast changes, and 1 mutation point per growth cycle" do
      player1 = %Player{id: 1, top_growth_chance: 0, right_growth_chance: 0, bottom_growth_chance: 0, left_growth_chance: 0, mutation_chance: 0}
      player_id_to_player_map = %{player1.id => player1}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player1.id])
      result = Grid.generate_growth_cycles(starting_grid, grid_size, player_id_to_player_map, 1, [])

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 5
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 1, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 2, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 3, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 4, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 5, player1.id)
      assert result.new_game_state
      assert (Map.keys(result.new_game_state) |> length) == 1
    end

    defp has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, generation_number, player_id) do
      growth_cycle = Enum.find(growth_cycles, fn growth_cycle -> growth_cycle.generation_number == generation_number end) 

      if(growth_cycle != nil and growth_cycle.mutation_points_earned[player_id] > 0) do
        true
      else
        false
      end
    end

    test "a multiplayer game where each player has max growth chance will generate an rapidly increasing number of growth cycles" do
      player_1 = make_maximum_growth_player(1)
      player_2 = make_maximum_growth_player(2)
      player_3 = make_maximum_growth_player(3)

      player_id_to_player_map = %{player_1.id => player_1, player_2.id => player_2, player_3.id => player_3}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player_1.id, player_2.id, player_3.id])
      result = Grid.generate_growth_cycles(starting_grid, grid_size, player_id_to_player_map, 1, [])

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 5
      
      growth_cycle_1 = Enum.at(growth_cycles, 0)
      number_of_toast_changes = Map.keys(growth_cycle_1.toast_changes) |> length
      # the least number of growths for a given cell would be 3 (if it's in the corner), therefore it should be impossible to have 
      # less than 3 players x 3 cells = 9 toast changesin the first round
      assert number_of_toast_changes >= 9

      growth_cycle_2 = Enum.at(growth_cycles, 1)
      number_of_toast_changes = Map.keys(growth_cycle_2.toast_changes) |> length
      # it should be impossible to generate less than 5 per player
      assert number_of_toast_changes >= 3 * 5

      growth_cycle_3 = Enum.at(growth_cycles, 2)
      number_of_toast_changes = Map.keys(growth_cycle_3.toast_changes) |> length
      # it should be impossible to generate less than 7 per player
      assert number_of_toast_changes >= 3 * 7

      growth_cycle_4 = Enum.at(growth_cycles, 3)
      number_of_toast_changes = Map.keys(growth_cycle_4.toast_changes) |> length
      # it should be impossible to generate less than 9 per player
      assert number_of_toast_changes >= 3 * 9
        
      growth_cycle_5 = Enum.at(growth_cycles, 4)
      number_of_toast_changes = Map.keys(growth_cycle_5.toast_changes) |> length
      # it should be impossible to generate less than 11 per player
      assert number_of_toast_changes >= 3 * 11

      minimum_possible_toast_changes = 3 * 5 + 3 * 7 + 3 * 9 + 3 * 11
      number_of_starting_cells = 3
      assert (Map.keys(result.new_game_state) |> length) > minimum_possible_toast_changes + number_of_starting_cells
    end

    test "it awards extra mutation points if your mutation chance hits" do
      player_1 = make_maximum_mutation_player(1)
      player_2 = make_maximum_mutation_player(2)
      player_3 = make_maximum_mutation_player(3)

      player_id_to_player_map = %{player_1.id => player_1, player_2.id => player_2, player_3.id => player_3}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player_1.id, player_2.id, player_3.id])
      #set the generation to 5 so it only does one cycle
      result = Grid.generate_growth_cycles(starting_grid, grid_size, player_id_to_player_map, 5, [])

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 1
      
      growth_cycle = Enum.at(growth_cycles, 0)
      assert growth_cycle.mutation_points_earned[player_1.id] > 1
      assert growth_cycle.mutation_points_earned[player_2.id] > 1
      assert growth_cycle.mutation_points_earned[player_3.id] > 1
    end

    defp make_maximum_growth_player(id) do
      %Player{id: id, 
        top_left_growth_chance: 100, 
        top_growth_chance: 100, 
        top_right_growth_chance: 100,
        right_growth_chance: 100,
        bottom_right_growth_chance: 100,
        bottom_growth_chance: 100, 
        bottom_left_growth_chance: 100,
        left_growth_chance: 100
      }
    end

    defp make_maximum_mutation_player(id) do
      %Player{id: id, mutation_chance: 100}
    end

  end

end
