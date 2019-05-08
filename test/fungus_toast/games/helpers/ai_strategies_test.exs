defmodule FungusToast.Games.AiStrategiesTest do
  use ExUnit.Case, async: true
  alias FungusToast.AiStrategies
  alias FungusToast.Games.Player

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
end
