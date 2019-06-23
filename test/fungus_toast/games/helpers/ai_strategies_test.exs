defmodule FungusToast.Games.AiStrategiesTest do
  use ExUnit.Case, async: true
  alias FungusToast.{AiStrategies, ActiveSkills}
  alias FungusToast.Games.{GridCell, Player}

  describe "maxed_out_skill/2" do
    test "that it returns true when skills that bottom out at 0 are at 0" do
      Enum.each(AiStrategies.skills_that_bottom_out_at_0_percent, fn skill_name ->
        player = AiStrategies.get_player_attributes_for_skill_name(skill_name)
        |> Enum.reduce(%Player{}, fn attribute, acc ->
          Map.put(acc, attribute, 0)
        end)

        assert AiStrategies.maxed_out_skill?(skill_name, player)
      end)
    end

    test "that it returns false if the skill can't max out (i.e. doesn't map to a player attribute)" do
        refute AiStrategies.maxed_out_skill?(AiStrategies.skill_name_eye_dropper, %Player{})
    end

    test "that it returns false when skills that bottom out at 0 are above 0" do
      Enum.each(AiStrategies.skills_that_bottom_out_at_0_percent, fn skill_name ->
        player = AiStrategies.get_player_attributes_for_skill_name(skill_name)
        |> Enum.reduce(%Player{}, fn attribute, acc ->
          Map.put(acc, attribute, 1.0)
        end)

        refute AiStrategies.maxed_out_skill?(skill_name, player)
      end)
    end

    test "that it returns true when skills that max out at 100 are at 100" do
      Enum.each(AiStrategies.skills_that_max_out_at_100_percent, fn skill_name ->
        player = AiStrategies.get_player_attributes_for_skill_name(skill_name)
        |> Enum.reduce(%Player{}, fn attribute, acc ->
          Map.put(acc, attribute, 100)
        end)

        assert AiStrategies.maxed_out_skill?(skill_name, player)
      end)
    end

    test "that it returns false when skills that max out at 100 are below 100" do
      Enum.each(AiStrategies.skills_that_max_out_at_100_percent, fn skill_name ->
        player = AiStrategies.get_player_attributes_for_skill_name(skill_name)
        |> Enum.reduce(%Player{}, fn attribute, acc ->
          Map.put(acc, attribute, 99)
        end)

        refute AiStrategies.maxed_out_skill?(skill_name, player)
      end)
    end
  end

  #there are test values in the AiStrategies.@candidate_skills_map to accomodate these tests
  describe "get_candidate_skills/3" do
    test "that it returns Anti-Apoptosis for the test player in the early game when little of the grid is occupied" do
      player = %Player{ai_type: "TEST"}
      total_cells = 100
      #force mid game so Anti-Apoptosis would be picked for the test player
      remaining_cells = total_cells - 100 * AiStrategies.early_game_treshhold + 1
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)
      assert length(candidate_skills) == 1
      assert hd(candidate_skills) == "Anti-Apoptosis"
    end

    test "that it returns Budding for the test player in the mid game when some of the grid is occupied" do
      player = %Player{ai_type: "TEST"}
      total_cells = 100
      remaining_cells = total_cells - 100 * AiStrategies.mid_game_threshold + 1
      #force mid game so Budding would be picked for the test player
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)

      assert length(candidate_skills) == 1
      assert hd(candidate_skills) == "Budding"
    end

    test "that it returns Regeneration for the test player in the late game when most of the grid is occupied" do
      player = %Player{ai_type: "TEST"}
      total_cells = 100
      #force late game so Regeneration would be picked for the test player
      remaining_cells = total_cells - 100 * AiStrategies.mid_game_threshold - 1
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)

      assert length(candidate_skills) == 1
      assert hd(candidate_skills) == "Regeneration"
    end

    test "that it returns duplicates of the same skills in accordance to their weights" do
      player = %Player{ai_type: "TEST2"}
      total_cells = 100
      #force early game so Anti-Apoptosis and Budding would be picked for the TEST2 player
      remaining_cells = total_cells
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)

      assert length(candidate_skills) == 3

      skill_to_occurrences_map = Enum.reduce(candidate_skills, %{}, fn skill_name, acc ->
        Map.update(acc, skill_name, 1, &(&1 + 1))
      end)
      assert skill_to_occurrences_map[AiStrategies.skill_name_budding] == 2
      assert skill_to_occurrences_map[AiStrategies.skill_name_anti_apoptosis] == 1
    end

    test "that it defaults to Anti-Apoptosis when the player has already maxed out the candidate skills" do
      player = %Player{ai_type: "TEST", regeneration_chance: 100}
      total_cells = 100
      #force late game so Regeneration would be picked for the test player
      remaining_cells = total_cells - 100 * AiStrategies.mid_game_threshold - 1
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)

      assert length(candidate_skills) == 1
      assert hd(candidate_skills) == "Anti-Apoptosis"
    end

    test "that it defaults to mycotoxicity when the player has already maxed out the candidate skills and anti-apoptosis" do
      player = %Player{ai_type: "TEST", regeneration_chance: 100, apoptosis_chance: 0}
      total_cells = 100
      #force late game so Regeneration would be picked for the test player
      remaining_cells = total_cells - 100 * AiStrategies.mid_game_threshold - 1
      candidate_skills = AiStrategies.get_candidate_skills(player, total_cells, remaining_cells)

      assert length(candidate_skills) == 1
      assert hd(candidate_skills) == AiStrategies.skill_name_mycotoxicity
    end
  end

  describe "place_water_droplets/6" do
    test "it places 0 droplets if there are no live cells for the player" do
      player = %Player{id: 1}
      toast = Enum.map(1..5, fn x -> %GridCell{index: 500 + x, live: false, player_id: player.id} end)
      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 0
    end

    test "it places 0 droplets if there are no empty cells surrounding the player's live cells" do
      player = %Player{id: 1}
      #create a grid with a live cell at index 0 so we need to place less surrounding cells
      toast = [
        %GridCell{index: 0, live: true, empty: false, player_id: player.id},
        %GridCell{index: 1, live: false, empty: false, player_id: player.id},
        %GridCell{index: 50, live: false, empty: false, player_id: player.id},
        %GridCell{index: 51, live: false, empty: false, player_id: player.id}
      ]
      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 0
    end

    test "it doesn't place droplets on cells that are already moist" do
      player = %Player{id: 1}
      #create a grid with a live cell at index 0 so we need to place less surrounding cells
      toast = [
        %GridCell{index: 0, live: true, player_id: player.id},
        %GridCell{index: 1, live: false, empty: false, player_id: player.id},
        %GridCell{index: 50, live: false, empty: false, player_id: player.id},
        %GridCell{index: 51, live: false, empty: true, moist: true}
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 0
    end

    test "it places droplets on empty surrounding cells" do
      player = %Player{id: 1}
      expected_index = 2
      #create a grid with a live cell at index 1 so we can have live, moist, dead, and empty cells
      toast = [
        %GridCell{index: 0, live: false, empty: false, player_id: player.id},
        %GridCell{index: 1, live: true, empty: false, player_id: player.id}, #the player's one live cell
        %GridCell{index: expected_index, empty: true }, #empty space that should get moisture drop
        %GridCell{index: 3, live: false, empty: false, player_id: player.id},
        %GridCell{index: 50, live: false, empty: false, player_id: player.id},
        %GridCell{index: 51, live: false, empty: false, player_id: player.id},
        %GridCell{index: 52, live: false, empty: true, moist: true}
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 1
      active_cell_changes = hd(active_cell_changes)
      assert hd(active_cell_changes.cell_indexes) == expected_index
    end

    test "it places no more than the maximum number of water droplets" do
      player = %Player{id: 1}
      #create a grid with a live cell at index 1 so it has a chance for up to 5 adjacent cells
      toast = [

        %GridCell{index: 1, live: true, empty: false, player_id: player.id} #the player's one live cell
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 1
      active_cell_change = hd(active_cell_changes)
      assert length(active_cell_change.cell_indexes) == ActiveSkills.number_of_toast_changes_for_eye_dropper()
      valid_indexes = [0, 2, 50, 51, 52]
      assert Enum.at(active_cell_change.cell_indexes, 0) in valid_indexes
      assert Enum.at(active_cell_change.cell_indexes, 1) in valid_indexes
      assert Enum.at(active_cell_change.cell_indexes, 2) in valid_indexes
    end


    test "it doesn't duplicate the same index" do
      player = %Player{id: 1}
      #create a grid with a live cell at index 0 and 1 so they have overlapping adjacent empty spaces
      toast = [
        %GridCell{index: 0, live: true, empty: false, player_id: player.id},
        %GridCell{index: 1, live: true, empty: false, player_id: player.id},
        %GridCell{index: 2, live: false, empty: false, player_id: player.id}
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_changes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(active_cell_changes) == 1
      active_cell_change = hd(active_cell_changes)
      assert length(active_cell_change.cell_indexes) == ActiveSkills.number_of_toast_changes_for_eye_dropper()

      valid_indexes = [50, 51, 52]
      #index 50 would show up as an open space for both living cells
      assert Enum.at(active_cell_change.cell_indexes, 0) in valid_indexes
      assert Enum.at(active_cell_change.cell_indexes, 1) in valid_indexes
      assert Enum.at(active_cell_change.cell_indexes, 2) in valid_indexes
    end
  end

  describe "place_dead_cell/5" do
    test "it returns a cell index adjacent to an enemy live cell" do
      player_1 = %Player{id: 1}
      player_2 = %Player{id: 2}

      empty_cell_index = 51
      #create a grid with a live cell at index 0 and leave only one empty spot
      toast = [
        %GridCell{index: 0, live: true, empty: false, player_id: player_2.id},
        %GridCell{index: 1, live: false, empty: false, player_id: player_2.id},
        %GridCell{index: 50, live: false, empty: false, player_id: player_2.id},
        %GridCell{index: empty_cell_index, empty: true}
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_change = AiStrategies.place_dead_cell(player_1, toast_map, 50, toast)

      assert length(active_cell_change.cell_indexes) == ActiveSkills.number_of_toast_changes_for_dead_cell()

      #index 50 would show up as an open space for both living cells
      assert hd(active_cell_change.cell_indexes) == empty_cell_index
    end

    test "it returns any empty cell if there are no cells open adjacent to enemies" do
      player_1 = %Player{id: 1}
      player_2 = %Player{id: 2}

      #create a grid with a live cell at index 0 and leave only one empty spot
      toast = [
        %GridCell{index: 0, live: true, empty: false, player_id: player_2.id},
        %GridCell{index: 1, live: false, empty: false, player_id: player_2.id},
        %GridCell{index: 50, live: false, empty: false, player_id: player_2.id},
        %GridCell{index: 51, live: false, empty: false, player_id: player_2.id},
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      active_cell_change = AiStrategies.place_dead_cell(player_1, toast_map, 50, toast)

      cell_index = hd(active_cell_change.cell_indexes)

      #make sure this is an empty cell
      refute Map.has_key?(toast_map, cell_index)
    end
  end

  describe "get_candidate_active_skills/2" do
    test "that it returns eye dropper if there are the minimum number of cells open" do
      grid_size = 50
      remaining_cells = AiStrategies.minimum_remaining_cells_for_eye_dropper
      candidate_skills = AiStrategies.get_candidate_active_skills(grid_size, remaining_cells, 0)

      assert Enum.member?(candidate_skills, ActiveSkills.skill_id_eye_dropper())
    end

    test "that it doesn't return eye dropper if there are less than the minimum number of cells open" do
      grid_size = 50
      remaining_cells = AiStrategies.minimum_remaining_cells_for_eye_dropper - 1
      candidate_skills = AiStrategies.get_candidate_active_skills(grid_size, remaining_cells, 0)

      refute Enum.member?(candidate_skills, ActiveSkills.skill_id_eye_dropper())
    end

    test "that it returns dead cell if at least half of the grid is still empty and it's at the minimum round" do
      grid_size = 50
      remaining_cells = grid_size * grid_size / 2
      candidate_skills = AiStrategies.get_candidate_active_skills(grid_size, remaining_cells, ActiveSkills.minimum_number_of_rounds_for_dead_cell)

      assert Enum.member?(candidate_skills, ActiveSkills.skill_id_dead_cell())
    end

    test "that it does not return dead cell if less than half of the grid is still empty" do
      grid_size = 50
      remaining_cells = (grid_size * grid_size / 2) - 1
      candidate_skills = AiStrategies.get_candidate_active_skills(grid_size, remaining_cells, ActiveSkills.minimum_number_of_rounds_for_dead_cell)

      refute Enum.member?(candidate_skills, ActiveSkills.skill_id_dead_cell())
    end

    test "that it does not return dead cell if less than the minimum round" do
      grid_size = 50
      remaining_cells = (grid_size * grid_size / 2)
      too_early_round_number = ActiveSkills.minimum_number_of_rounds_for_dead_cell - 1
      candidate_skills = AiStrategies.get_candidate_active_skills(grid_size, remaining_cells, too_early_round_number)

      refute Enum.member?(candidate_skills, ActiveSkills.skill_id_dead_cell())
    end
  end
end
