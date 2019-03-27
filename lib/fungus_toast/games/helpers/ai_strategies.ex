defmodule FungusToast.AiStrategies do

  @ai_type_random "Random"
  def ai_type_random, do:  @ai_type_random
  @ai_type_growth "Growth"
  def ai_type_growth, do:  @ai_type_growth
  @ai_type_toxic "Toxic"
  def ai_type_toxic, do:  @ai_type_toxic
  @ai_type_long_term "Long Term"
  def ai_type_long_term, do:  @ai_type_long_term
  @ai_types [@ai_type_random, @ai_type_growth, @ai_type_toxic, @ai_type_long_term]

  def get_ai_types, do: @ai_types

  @skill_name_anti_apoptosis "Anti-Apoptosis"
  @skill_name_budding "Budding"
  @skill_name_hypermutation "Hypermutation"
  @skill_name_regeneration "Regeneration"
  @skill_name_mycotoxicity "Mycotoxicity"

  @skill_name_to_player_attribute_map %{
    @skill_name_anti_apoptosis => [:apoptosis_chance],
    @skill_name_budding => [:top_left_growth_chance, :top_right_growth_chance, :bottom_right_growth_chance, :bottom_left_growth_chance],
    @skill_name_hypermutation => [:mutation_chance],
    @skill_name_regeneration => [:regeneration_chance],
    @skill_name_mycotoxicity => [:mycotoxin_fungicide_chance]
  }

  def skill_name_to_player_attribute_map, do: @skill_name_to_player_attribute_map

  def get_player_attributes_for_skill_name(skill_name) do
    Map.get(@skill_name_to_player_attribute_map, skill_name)
  end

  @candidate_skills_map %{
    "Random|EarlyGame" => [@skill_name_budding, @skill_name_hypermutation],
    "Random|MidGame" => [@skill_name_anti_apoptosis, @skill_name_budding, @skill_name_hypermutation],
    "Random|LateGame" => [@skill_name_anti_apoptosis, @skill_name_regeneration, @skill_name_mycotoxicity],
    "Growth|EarlyGame" => [@skill_name_budding],
    "Growth|MidGame" => [@skill_name_anti_apoptosis, @skill_name_budding],
    "Growth|LateGame" => [@skill_name_anti_apoptosis, @skill_name_budding, @skill_name_regeneration],
    "Toxic|EarlyGame" => [@skill_name_budding, @skill_name_hypermutation],
    "Toxic|MidGame" => [@skill_name_regeneration, @skill_name_mycotoxicity],
    "Toxic|LateGame" => [@skill_name_regeneration, @skill_name_mycotoxicity],
    "Long Term|EarlyGame" => [@skill_name_hypermutation],
    "Long Term|MidGame" => [@skill_name_hypermutation, @skill_name_budding],
    "Long Term|LateGame" => [@skill_name_anti_apoptosis, @skill_name_regeneration, @skill_name_mycotoxicity],
  }

  def candidate_skills_map, do: @candidate_skills_map

  @early_game_threshold 0.33
  @mid_game_threshold 0.66

  @doc """
  Returns a semi-random skill name that the AI can spend points on
  """
  @spec get_skill_choice(String.t(), integer(), integer()) :: String.t()
  def get_skill_choice(ai_type, total_cells, number_of_remaining_cells) do
    key = ai_type <> "|" <> case {number_of_remaining_cells / total_cells} do
      {x} when x < @early_game_threshold -> "EarlyGame"
      {x} when x < @mid_game_threshold -> "MidGame"
      _ -> "LateGame"
    end

    Map.get(candidate_skills_map(), key)
    |> Enum.random()
  end
end
