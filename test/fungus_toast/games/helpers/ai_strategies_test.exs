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

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == 0
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

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == 0
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

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == 0
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

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == 1
      assert hd(indexes) == expected_index
    end

    test "it places no more than the maximum number of water droplets" do
      player = %Player{id: 1}
      #create a grid with a live cell at index 1 so it has a chance for up to 5 adjacent cells
      toast = [

        %GridCell{index: 1, live: true, empty: false, player_id: player.id} #the player's one live cell
      ]

      toast_map = Enum.map(toast, fn grid_cell -> {grid_cell.index, grid_cell} end)
      |> Enum.into(%{})

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == ActiveSkills.number_of_toast_changes_for_eye_dropper()
      valid_indexes = [0, 2, 50, 51, 52]
      assert Enum.at(valid_indexes, 0) in valid_indexes
      assert Enum.at(valid_indexes, 1) in valid_indexes
      assert Enum.at(valid_indexes, 2) in valid_indexes
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

      indexes = AiStrategies.place_water_droplets(player, toast_map, 50, toast)

      assert length(indexes) == 3
      valid_indexes = [50, 51, 52]
      #index 50 would show up as an open space for both living cells
      assert Enum.at(valid_indexes, 0) in valid_indexes
      assert Enum.at(valid_indexes, 1) in valid_indexes
      assert Enum.at(valid_indexes, 2) in valid_indexes
    end
  end
end
