defmodule FungusToast.Games.GridTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.{Grid, GridCell, Player, GrowthCycle, ActiveCellChange}
  alias FungusToast.Skills

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

      assert length(grid) == length(player_ids)
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
    end

    defp find_grid_cell_for_player(grid, player_id) do
      Enum.find(grid, fn grid_cell -> grid_cell.player_id == player_id end)
    end
  end

  describe "generate_growth_summary/4" do
    test "that a single player game with no growth or mutation chance will generate 6 sequential growth cycles with no toast changes, and 1 mutation point per growth cycle" do
      player1 = %Player{id: 1, top_growth_chance: 0, right_growth_chance: 0, bottom_growth_chance: 0, left_growth_chance: 0, mutation_chance: 0}
      player_id_to_player_map = %{player1.id => player1}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player1.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)

      result = Grid.generate_growth_summary(starting_grid_map, [], grid_size, player_id_to_player_map)

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 6

      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 1, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 2, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 3, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 4, player1.id)
      assert has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, 5, player1.id)
      assert result.new_game_state
      assert length(result.new_game_state) == 1
    end

    defp has_growth_cycle_with_specified_generation_number_and_at_least_one_mutation_point(growth_cycles, generation_number, player_id) do
      growth_cycle = Enum.find(growth_cycles, fn growth_cycle -> growth_cycle.generation_number == generation_number end)

      points_earned_map = Enum.into(growth_cycle.mutation_points_earned, %{},
        fn mutation_points_earned -> {mutation_points_earned.player_id, mutation_points_earned.mutation_points} end)
      if(growth_cycle != nil and points_earned_map[player_id] > 0) do
        true
      else
        false
      end
    end

    test "that a multiplayer game where each player has max growth chance will generate a rapidly increasing number of growth cycles" do
      player_1 = make_maximum_growth_player(1)
      player_2 = make_maximum_growth_player(2)
      player_3 = make_maximum_growth_player(3)

      player_id_to_player_map = %{player_1.id => player_1, player_2.id => player_2, player_3.id => player_3}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player_1.id, player_2.id, player_3.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      result = Grid.generate_growth_summary(starting_grid_map, [], grid_size, player_id_to_player_map)

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 6

      growth_cycle_1 = Enum.at(growth_cycles, 1)
      number_of_toast_changes = length(growth_cycle_1.toast_changes)
      # the least number of growths for a given cell would be 3 (if it's in the corner), therefore it should be impossible to have
      # less than 3 players x 3 cells = 9 toast changesin the first round
      assert number_of_toast_changes >= 9

      growth_cycle_2 = Enum.at(growth_cycles, 1)
      number_of_toast_changes = length(growth_cycle_2.toast_changes)
      # it should be impossible to generate less than 5 per player
      assert number_of_toast_changes >= 3 * 5

      growth_cycle_3 = Enum.at(growth_cycles, 2)
      number_of_toast_changes = length(growth_cycle_3.toast_changes)
      # it should be impossible to generate less than 7 per player
      assert number_of_toast_changes >= 3 * 7

      growth_cycle_4 = Enum.at(growth_cycles, 3)
      number_of_toast_changes = length(growth_cycle_4.toast_changes)
      # it should be impossible to generate less than 9 per player
      assert number_of_toast_changes >= 3 * 9

      growth_cycle_5 = Enum.at(growth_cycles, 4)
      number_of_toast_changes = length(growth_cycle_5.toast_changes)
      # it should be impossible to generate less than 11 per player
      assert number_of_toast_changes >= 3 * 11

      minimum_possible_toast_changes = 3 * 5 + 3 * 7 + 3 * 9 + 3 * 11
      number_of_starting_cells = 3
      assert length(result.new_game_state) > minimum_possible_toast_changes + number_of_starting_cells
    end

    test "that you cannot have more than the grid_size * grid_size number of cells in the new game state" do
      player_1 = make_maximum_growth_player(1)
      # player_2 = make_maximum_growth_player(2)
      # player_3 = make_maximum_growth_player(3)
      # player_4 = make_maximum_growth_player(4)
      # player_5 = make_maximum_growth_player(5)

      player_id_to_player_map = %{player_1.id => player_1}#, player_2.id => player_2, player_3.id => player_3, player_4.id => player_4, player_5.id => player_5}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player_1.id])#, player_2.id, player_3.id, player_4.id, player_5.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      #set the growth_cycle number to -43 so that we get a full 50 growth cycles (43 + 6 + empty active cell canges to get up to +5) -- more than enough to fill the entire grid
      result = Grid.generate_growth_summary(starting_grid_map, [], grid_size, player_id_to_player_map, -43)

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 50

      assert length(result.new_game_state) == grid_size * grid_size

      last_growth_cycle = Enum.at(growth_cycles, 49)
      number_of_live_cell_toast_changes = Enum.count(last_growth_cycle.toast_changes, fn grid_cell -> grid_cell.live end)
      assert number_of_live_cell_toast_changes == 0
    end

    test "it awards extra mutation points if your mutation chance hits" do
      player_1 = make_maximum_mutation_player(1)
      player_2 = make_maximum_mutation_player(2)
      player_3 = make_maximum_mutation_player(3)

      player_id_to_player_map = %{player_1.id => player_1, player_2.id => player_2, player_3.id => player_3}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player_1.id, player_2.id, player_3.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      #set the generation to 5 so it only does one cycle (plus empty active cell changes)
      result = Grid.generate_growth_summary(starting_grid_map, [], grid_size, player_id_to_player_map, 5)

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 2

      growth_cycle = Enum.at(growth_cycles, 1)

      points_earned_map = Enum.into(growth_cycle.mutation_points_earned, %{},
        fn mutation_points_earned -> {mutation_points_earned.player_id, mutation_points_earned.mutation_points} end)
      assert points_earned_map[player_1.id] > 1
      assert points_earned_map[player_2.id] > 1
      assert points_earned_map[player_3.id] > 1
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

    test "that it applies hydrophilia active cell changes to the starting game state before applying additional growth" do
      player1 = %Player{id: 1, top_growth_chance: 0, right_growth_chance: 0, bottom_growth_chance: 0, left_growth_chance: 0, mutation_chance: 0}
      player_id_to_player_map = %{player1.id => player1}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player1.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      expected_cell_indexes = [0, 1, 2]
      active_cell_changes = [%ActiveCellChange{skill_id: Skills.skill_id_hydrophilia(), cell_indexes: expected_cell_indexes}]

      result = Grid.generate_growth_summary(starting_grid_map, active_cell_changes, grid_size, player_id_to_player_map)

      assert result.growth_cycles
      growth_cycles = result.growth_cycles
      assert Enum.count(growth_cycles) == 6
      active_cell_changes_growth_cycle = hd(result.growth_cycles)
      assert active_cell_changes_growth_cycle.generation_number == 0
      #make sure the 3 active cell changes are accounted for in toast changes
      Enum.each(expected_cell_indexes, fn cell_index ->
        matching_cell = hd(Enum.filter(active_cell_changes_growth_cycle.toast_changes, fn grid_cell -> grid_cell.index == cell_index end))
        assert matching_cell
        assert matching_cell.moist
      end)

      #make sure the 3 active cell changes are accounted for in the updated game state
      Enum.each(expected_cell_indexes, fn cell_index ->
        matching_cell = hd(Enum.filter(result.new_game_state, fn grid_cell -> grid_cell.index == cell_index end))
        assert matching_cell
        assert matching_cell.moist
      end)
    end

    test "that it raises if an active cell change is for a skill that doesn't support active changes" do
      player1 = %Player{id: 1, top_growth_chance: 0, right_growth_chance: 0, bottom_growth_chance: 0, left_growth_chance: 0, mutation_chance: 0}
      player_id_to_player_map = %{player1.id => player1}
      grid_size = 50
      starting_grid = Grid.create_starting_grid(grid_size, [player1.id])
      starting_grid_map = Enum.into(starting_grid, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      active_cell_changes = [%ActiveCellChange{skill_id: Skills.skill_id_budding(), cell_indexes: [0]}]

      assert_raise RuntimeError, fn -> Grid.generate_growth_summary(starting_grid_map, active_cell_changes, grid_size, player_id_to_player_map) end
    end
  end

  describe "get_player_growth_cycles_stats/2" do
    test "that it returns an empty map for each player if there are no growth_cycles" do
      player_id_1 = 1
      player_id_2 = 2
      growth_cycles = []

      result = Grid.get_player_growth_cycles_stats([player_id_1, player_id_2], growth_cycles)

      assert map_size(result) == 2

      assert Map.has_key?(result, player_id_1)
      player_map = result[player_id_1]
      assert player_map[:grown_cells] == 0
      assert player_map[:regenerated_cells] == 0
      assert player_map[:perished_cells] == 0
      assert player_map[:fungicidal_kills] == 0

      assert Map.has_key?(result, player_id_2)
      player_map = result[player_id_2]
      assert player_map[:grown_cells] == 0
      assert player_map[:regenerated_cells] == 0
      assert player_map[:perished_cells] == 0
      assert player_map[:fungicidal_kills] == 0
    end

    test "that it totals the cells that died" do
      player_id_1 = 1
      dead_cell = %GridCell{live: false, empty: false, player_id: player_id_1}
      growth_cycle_1 = %GrowthCycle{toast_changes: [dead_cell, dead_cell]}
      growth_cycle_2 = %GrowthCycle{toast_changes: [dead_cell]}
      growth_cycles = [growth_cycle_1, growth_cycle_2]

      result = Grid.get_player_growth_cycles_stats([player_id_1], growth_cycles)

      assert map_size(result) == 1

      assert Map.has_key?(result, player_id_1)
      player_map = result[player_id_1]
      assert player_map[:perished_cells] == 3
    end

    test "that it totals the fungicidal kills" do
      killing_player_id_1 = 1
      dead_player_id = 2
      dead_cell = %GridCell{live: false, empty: false, killed_by: killing_player_id_1, player_id: dead_player_id}
      growth_cycle_1 = %GrowthCycle{toast_changes: [dead_cell, dead_cell]}
      growth_cycle_2 = %GrowthCycle{toast_changes: [dead_cell]}
      growth_cycles = [growth_cycle_1, growth_cycle_2]

      result = Grid.get_player_growth_cycles_stats([killing_player_id_1, dead_player_id], growth_cycles)

      assert map_size(result) == 2

      assert Map.has_key?(result, killing_player_id_1)
      player_map = result[killing_player_id_1]
      assert player_map[:fungicidal_kills] == 3
    end

    test "that it totals the cells that were grown" do
      player_id_1 = 1
      live_cell = %GridCell{live: true, player_id: player_id_1}
      growth_cycle_1 = %GrowthCycle{toast_changes: [live_cell, live_cell]}
      growth_cycle_2 = %GrowthCycle{toast_changes: [live_cell]}
      growth_cycles = [growth_cycle_1, growth_cycle_2]

      result = Grid.get_player_growth_cycles_stats([player_id_1], growth_cycles)

      assert map_size(result) == 1

      assert Map.has_key?(result, player_id_1)
      player_map = result[player_id_1]
      assert player_map[:grown_cells] == 3
    end

    test "that it totals the cells that were regenerated" do
      player_id_1 = 1
      regenerated_cell = %GridCell{live: true, previous_player_id: 1, player_id: player_id_1}
      growth_cycle_1 = %GrowthCycle{toast_changes: [regenerated_cell, regenerated_cell]}
      growth_cycle_2 = %GrowthCycle{toast_changes: [regenerated_cell]}
      growth_cycles = [growth_cycle_1, growth_cycle_2]

      result = Grid.get_player_growth_cycles_stats([player_id_1], growth_cycles)

      assert map_size(result) == 1

      assert Map.has_key?(result, player_id_1)
      player_map = result[player_id_1]
      assert player_map[:regenerated_cells] == 3
    end

    test "that it ignores cells that were empty" do
      player_id_1 = 1
      empty_cell = %GridCell{live: false, empty: true, moist: true}
      growth_cycle_1 = %GrowthCycle{toast_changes: [empty_cell]}
      growth_cycles = [growth_cycle_1]

      result = Grid.get_player_growth_cycles_stats([player_id_1], growth_cycles)

      assert map_size(result) == 1
      assert Map.has_key?(result, player_id_1)
    end
  end

  #%{player_id: player_id, regenerated_cells: 0, grown_cells: 0, perished_cells: 0, fungicidal_kills: 0}}
  describe "get_toast_changes_stats/2" do
    test "that it totals regenerated_cells" do
      player_id = 1
      regenerated_cell = %GridCell{player_id: player_id, previous_player_id: 2, live: true, empty: false}

      player_stats_change = hd(Grid.get_toast_changes_stats([player_id], [regenerated_cell]))

      assert player_stats_change.regenerated_cells == 1
    end

    test "that it totals grown cells" do
      player_id = 1
      grown_cell = %GridCell{player_id: player_id, live: true, empty: false}

      player_stats_change = hd(Grid.get_toast_changes_stats([player_id], [grown_cell]))

      assert player_stats_change.grown_cells == 1
    end

    test "that it totals perished cells" do
      player_id = 1
      perished_cell = %GridCell{player_id: player_id, live: false, empty: false}

      player_stats_change = hd(Grid.get_toast_changes_stats([player_id], [perished_cell]))

      assert player_stats_change.perished_cells == 1
    end

    test "that it totals perished cells and fungicidal kills when a cell is murdered" do
      player_id = 1
      murderous_player_id = 2
      perished_cell = %GridCell{player_id: player_id, live: false, empty: false, killed_by: murderous_player_id}

      player_stats_changes = Grid.get_toast_changes_stats([player_id, murderous_player_id], [perished_cell])

      player_1_stats_change = Enum.find(player_stats_changes, fn player_stats_change -> player_stats_change.player_id == player_id end)
      assert player_1_stats_change.perished_cells == 1

      murderous_player_stats_change = Enum.find(player_stats_changes, fn player_stats_change -> player_stats_change.player_id == murderous_player_id end)
      assert murderous_player_stats_change.fungicidal_kills == 1
    end
  end

end
