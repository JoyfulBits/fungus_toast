defmodule FungusToast.AiStrategies do
  alias FungusToast.Games.{Player, Grid, ActiveCellChange}
  alias FungusToast.ActiveSkills

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
    "Random|EarlyGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_budding => 1, @skill_name_hypermutation => 1, @skill_name_spores => 1, @skill_name_hydrophilia => 1},
    "Random|MidGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_budding => 1, @skill_name_hypermutation => 1, @skill_name_spores => 1},
    "Random|LateGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_regeneration => 1, @skill_name_mycotoxicity => 1},
    "Growth|EarlyGame" => %{@skill_name_budding => 4, @skill_name_spores => 2, @skill_name_hypermutation => 1, @skill_name_hydrophilia => 1},
    "Growth|MidGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_budding => 2},
    "Growth|LateGame" => %{@skill_name_anti_apoptosis => 2, @skill_name_budding => 1, @skill_name_regeneration => 4},
    "Spores|EarlyGame" => %{@skill_name_hydrophilia => 1, @skill_name_spores => 4, @skill_name_hypermutation => 1, @skill_name_budding => 1},
    "Spores|MidGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_spores => 1},
    "Spores|LateGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_regeneration => 1},
    "Toxic|EarlyGame" => %{@skill_name_hypermutation => 3, @skill_name_budding => 2, @skill_name_spores => 1},
    "Toxic|MidGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_regeneration => 1, @skill_name_mycotoxicity => 2},
    "Toxic|LateGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_regeneration => 2, @skill_name_mycotoxicity => 4},
    "Experimental 1|EarlyGame" => %{@skill_name_budding => 1},
    "Experimental 1|MidGame" => %{@skill_name_budding => 1},
    "Experimental 1|LateGame" => %{@skill_name_budding => 1},
    "Long Term|EarlyGame" => %{@skill_name_hypermutation => 4, @skill_name_budding => 1, @skill_name_spores => 1},
    "Long Term|MidGame" => %{@skill_name_hypermutation => 2, @skill_name_anti_apoptosis => 1, @skill_name_regeneration => 2},
    "Long Term|LateGame" => %{ @skill_name_anti_apoptosis => 1, @skill_name_regeneration => 2, @skill_name_mycotoxicity => 2},
    "TEST|EarlyGame" => %{@skill_name_anti_apoptosis => 1},
    "TEST|MidGame" => %{@skill_name_budding => 1},
    "TEST|LateGame" => %{@skill_name_regeneration => 1},
    "TEST2|EarlyGame" => %{@skill_name_anti_apoptosis => 1, @skill_name_budding => 2}
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

  @doc """
  Returns a list of candidate skill names, with repetitions corresponding to the weight (i.e. chance that the skill should be selected)
  """
  def get_candidate_skills(ai_player, total_cells, number_of_remaining_cells) do
    key = ai_player.ai_type <> "|" <> case { ((total_cells - number_of_remaining_cells) / total_cells) } do
      {x} when x < @early_game_threshold -> "EarlyGame"
      {x} when x < @mid_game_threshold -> "MidGame"
      _ -> "LateGame"
    end

    candidate_skills_with_weights = Map.get(candidate_skills_map(), key)

    list_of_skill_names_with_duplicates = Enum.reduce(candidate_skills_with_weights, [], fn {skill_name, weight}, acc ->
      if(!maxed_out_skill?(skill_name, ai_player)) do
        acc ++ Enum.map(1..weight, fn _ -> skill_name end)
      else
        acc
      end
    end)

    if(length(list_of_skill_names_with_duplicates) == 0) do
      if(maxed_out_skill?(@skill_name_anti_apoptosis, ai_player)) do
        [@skill_name_mycotoxicity]
      else
        [@skill_name_anti_apoptosis]
      end
    else
      list_of_skill_names_with_duplicates
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
        #TODO this should be changed to be more scalable.
        if(skill_name == skill_name_hydrophilia() and percentage_chance > 50) do
          true
        else
          if(percentage_chance >= 100) do
            true
          else
            false
          end
        end
      end
    return_value
    end
  end

  def use_active_skills(%Player{action_points: action_points} = ai_player, toast_grid, grid_size, remaining_cells, round_number) do
    toast_grid_map = Enum.map(toast_grid, fn grid_cell -> {grid_cell.index, grid_cell} end)
    |> Enum.into(%{})
    toast_changes = Enum.reduce(1..action_points, [], fn _, acc ->
      candidate_skills = get_candidate_active_skills(grid_size, remaining_cells, round_number)

      if(length(candidate_skills) > 0) do
        chosen_active_skill_id = Enum.random(candidate_skills)

        if(chosen_active_skill_id == ActiveSkills.skill_id_eye_dropper()) do
          acc ++ place_water_droplets(ai_player, toast_grid_map, grid_size, toast_grid)
        else
          if(chosen_active_skill_id == ActiveSkills.skill_id_dead_cell()) do
            acc ++ [place_dead_cell(ai_player, toast_grid_map, grid_size, toast_grid)]
          else
            acc
          end
        end
      else
        acc
      end
    end)

    #for now, all action points are always spent by the AI
    {toast_changes, ai_player.action_points}
  end

  @minimum_remaining_cells_for_eye_dropper 100
  def minimum_remaining_cells_for_eye_dropper, do: @minimum_remaining_cells_for_eye_dropper

  @doc """
  Gets the active skills that the AI player could potentially use
  """
  def get_candidate_active_skills(grid_size, remaining_cells, round_number) do
    candidate_skills = if(remaining_cells >= @minimum_remaining_cells_for_eye_dropper) do
      [ActiveSkills.skill_id_eye_dropper()]
    else
      []
    end

    candidate_skills ++ if(remaining_cells >= grid_size * grid_size / 2 and round_number >= ActiveSkills.minimum_number_of_rounds_for_dead_cell) do
      [ActiveSkills.skill_id_dead_cell()]
    else
      []
    end
  end

  @doc """
  Attempts to place water droplets only in adjacent empty cells. Could place less than the max if it doesn't found enough adjacent.
  """
  def place_water_droplets(ai_player, original_toast_grid_map, grid_size, toast_grid_list, droplet_indexes \\ [], got_all_droplets \\ false)
  def place_water_droplets(ai_player, original_toast_grid_map, grid_size, [grid_cell | remaining_toast], droplet_indexes, got_all_droplets) when got_all_droplets == false do
    new_droplet_indexes = if(grid_cell.live and grid_cell.player_id == ai_player.id) do
     Grid.get_surrounding_cells(original_toast_grid_map, grid_size, grid_cell.index)
      |> Enum.reduce([], fn {_location, adjacent_grid_cell}, acc ->
        if(adjacent_grid_cell.empty and !adjacent_grid_cell.moist) do
          acc ++ [adjacent_grid_cell.index]
        else
          acc
        end
      end)
    else
      []
    end
    unique_water_droplets = droplet_indexes ++ new_droplet_indexes
    |> Enum.uniq

    got_enough_droplets = length(unique_water_droplets) >= ActiveSkills.number_of_toast_changes_for_eye_dropper() or remaining_toast == []
    place_water_droplets(ai_player, original_toast_grid_map, grid_size, remaining_toast, unique_water_droplets, got_enough_droplets)
  end

  def place_water_droplets(ai_player, _original_toast_grid_map, _grid_size, _empty_list, droplet_indexes, got_all_droplets) when got_all_droplets == true do
    cell_indexes = Enum.take(droplet_indexes, ActiveSkills.number_of_toast_changes_for_eye_dropper())
    if(cell_indexes == []) do
      []
    else
      [%ActiveCellChange{player_id: ai_player.id, active_skill_id: ActiveSkills.skill_id_eye_dropper(), cell_indexes: cell_indexes}]
    end
  end

  def place_dead_cell(ai_player, original_toast_grid_map, grid_size, toast_grid_list, candidate_cells \\ [])
  def place_dead_cell(ai_player, original_toast_grid_map, grid_size, [grid_cell | remaining_toast], candidate_cells) when candidate_cells == [] and remaining_toast != [] do
    candidate_cells = if(grid_cell.live and grid_cell.player_id != ai_player.id) do
      Grid.get_surrounding_cells(original_toast_grid_map, grid_size, grid_cell.index)
       |> Enum.reduce([], fn {_location, adjacent_grid_cell}, acc ->
         if(adjacent_grid_cell.empty and !adjacent_grid_cell.moist) do
           acc ++ [adjacent_grid_cell.index]
         else
           acc
         end
       end)
    else
      []
    end

    place_dead_cell(ai_player, original_toast_grid_map, grid_size, remaining_toast, candidate_cells)
  end

  def place_dead_cell(ai_player, original_toast_grid_map, grid_size, [_grid_cell | remaining_toast], candidate_cells) when candidate_cells != [] or remaining_toast == [] do
    cell_index = if(candidate_cells == []) do
      #find the first index that has nothing (since this will be empty)
      Enum.find(0..grid_size-1, fn x -> !Map.has_key?(original_toast_grid_map, x) end)
    else
      Enum.random(candidate_cells)
    end

    %ActiveCellChange{player_id: ai_player.id, active_skill_id: ActiveSkills.skill_id_dead_cell(), cell_indexes: [cell_index]}
  end
end
