defmodule FungusToast.AiStrategies do
  alias FungusToast.Games.Player

  @ai_type_random "Random"
  def ai_type_random, do: @ai_type_random

  @ai_type_growth "Growth"
  def ai_type_growth, do: @ai_type_growth

  @ai_type_spores "Spores"
  def ai_type_spores, do: @ai_type_spores

  @ai_type_toxic "Toxic"
  def ai_type_toxic, do: @ai_type_toxic

  @ai_type_experimental_1 "Experimental 1"
  def ai_type_experimental_1, do: @ai_type_experimental_1

  @ai_type_long_term "Long Term"
  def ai_type_long_term, do: @ai_type_long_term

  @ai_types [@ai_type_random, @ai_type_growth, @ai_type_toxic, @ai_type_long_term, @ai_type_spores]

  def get_ai_types, do: @ai_types

  @skill_name_anti_apoptosis "Anti-Apoptosis"
  def skill_name_anti_apoptosis, do: @skill_name_anti_apoptosis
  @skill_name_budding "Budding"
  def skill_name_budding, do: @skill_name_budding
  @skill_name_hypermutation "Hypermutation"
  def skill_name_hypermutation, do: @skill_name_hypermutation
  @skill_name_regeneration "Regeneration"
  def skill_name_regeneration, do: @skill_name_regeneration
  @skill_name_mycotoxicity "Mycotoxicity"
  def skill_name_mycotoxicity, do: @skill_name_mycotoxicity
  @skill_name_hydrophilia "Hydrophilia"
  def skill_name_hydrophilia, do: @skill_name_hydrophilia
  @skill_name_spores "Spores"
  def skill_name_spores, do: @skill_name_spores
  @skill_name_eye_dropper "Eye Dropper"
  def skill_name_eye_dropper, do: @skill_name_eye_dropper

  @skill_name_to_player_attribute_map %{
    @skill_name_anti_apoptosis => [:apoptosis_chance],
    @skill_name_budding => [:top_left_growth_chance, :top_right_growth_chance, :bottom_right_growth_chance, :bottom_left_growth_chance],
    @skill_name_hypermutation => [:mutation_chance],
    @skill_name_regeneration => [:regeneration_chance],
    @skill_name_mycotoxicity => [:mycotoxin_fungicide_chance],
    @skill_name_hydrophilia => [:moisture_growth_boost],
    @skill_name_spores => [:spores_chance]
  }

  def skill_name_to_player_attribute_map, do: @skill_name_to_player_attribute_map

  @skills_that_max_out_at_100_percent [@skill_name_budding, @skill_name_hypermutation, @skill_name_regeneration, @skill_name_mycotoxicity, @skill_name_spores]
  def skills_that_max_out_at_100_percent, do: @skills_that_max_out_at_100_percent

  @skills_that_bottom_out_at_0_percent [@skill_name_anti_apoptosis]
  def skills_that_bottom_out_at_0_percent, do: @skills_that_bottom_out_at_0_percent

  def get_player_attributes_for_skill_name(skill_name) do
    attributes = Map.get(@skill_name_to_player_attribute_map, skill_name)
    if(attributes == nil) do
      []
    else
      attributes
    end
  end

  @candidate_skills_map %{
    "Random|EarlyGame" => [@skill_name_budding, @skill_name_hypermutation],
    "Random|MidGame" => [@skill_name_anti_apoptosis, @skill_name_budding, @skill_name_hypermutation],
    "Random|LateGame" => [@skill_name_anti_apoptosis, @skill_name_regeneration, @skill_name_mycotoxicity],
    "Growth|EarlyGame" => [@skill_name_budding],
    "Growth|MidGame" => [@skill_name_anti_apoptosis, @skill_name_budding],
    "Growth|LateGame" => [@skill_name_anti_apoptosis, @skill_name_budding, @skill_name_regeneration],
    "Spores|EarlyGame" => [@skill_name_spores, @skill_name_hypermutation],
    "Spores|MidGame" => [@skill_name_anti_apoptosis, @skill_name_spores],
    "Spores|LateGame" => [@skill_name_anti_apoptosis, @skill_name_regeneration, @skill_name_mycotoxicity],
    "Toxic|EarlyGame" => [@skill_name_budding, @skill_name_hypermutation],
    "Toxic|MidGame" => [@skill_name_regeneration, @skill_name_mycotoxicity],
    "Toxic|LateGame" => [@skill_name_regeneration, @skill_name_mycotoxicity],
    "Experimental 1|EarlyGame" => [@skill_name_budding],
    "Experimental 1|MidGame" => [@skill_name_regeneration, @skill_name_mycotoxicity],
    "Experimental 1|LateGame" => [@skill_name_mycotoxicity],
    "Long Term|EarlyGame" => [@skill_name_hypermutation],
    "Long Term|MidGame" => [@skill_name_hypermutation, @skill_name_budding],
    "Long Term|LateGame" => [@skill_name_anti_apoptosis, @skill_name_regeneration, @skill_name_mycotoxicity],
    "TEST|EarlyGame" => [@skill_name_anti_apoptosis],
    "TEST|MidGame" => [@skill_name_budding],
    "TEST|LateGame" => [@skill_name_regeneration]
  }

  def candidate_skills_map, do: @candidate_skills_map

  @early_game_threshold 0.35
  #TODO exposing this for tests... is there a better way?
  def early_game_treshhold, do: @early_game_threshold

  @mid_game_threshold 0.70
  def mid_game_threshold, do: @mid_game_threshold

  @doc """
  Returns a semi-random skill name that the AI can spend points on
  """
  @spec get_skill_choice(%Player{}, integer(), integer()) :: String.t()
  def get_skill_choice(ai_player, total_cells, number_of_remaining_cells) do
    get_candidate_skills(ai_player, total_cells, number_of_remaining_cells)
    |> Enum.random
  end

  def get_candidate_skills(ai_player, total_cells, number_of_remaining_cells) do
    key = ai_player.ai_type <> "|" <> case { ((total_cells - number_of_remaining_cells) / total_cells) } do
      {x} when x < @early_game_threshold -> "EarlyGame"
      {x} when x < @mid_game_threshold -> "MidGame"
      _ -> "LateGame"
    end

    candidate_skills = Map.get(candidate_skills_map(), key)
    |> Enum.filter(fn skill_name -> !maxed_out_skill?(skill_name, ai_player) end)

    if(length(candidate_skills) > 0) do
      candidate_skills
    else
      if(maxed_out_skill?(@skill_name_anti_apoptosis, ai_player)) do
        [@skill_name_mycotoxicity]
      else
        [@skill_name_anti_apoptosis]
      end
    end
  end

  @spec maxed_out_skill?(String.t(), %Player{}) :: boolean()
  def maxed_out_skill?(skill_name, player) do
    attributes = get_player_attributes_for_skill_name(skill_name)
    if(attributes == []) do
      false
    else
      attribute_to_check = hd(attributes)
    percentage_chance = Map.get(player, attribute_to_check)
    return_value = if(Enum.member?(@skills_that_bottom_out_at_0_percent, skill_name)) do
      if(percentage_chance <= 0) do
        true
      else
        false
      end
    else
      if(percentage_chance >= 100) do
        true
      else
        false
      end
    end

    return_value
    end
  end
end
