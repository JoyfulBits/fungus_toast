defmodule FungusToast.Games.Grid do
  alias FungusToast.Games.{CellGrower, GridCell, GrowthCycle, PointsEarned, PlayerStatsChange}
  alias FungusToast.{ActiveSkills, Random}

  @spec create_starting_grid(integer(), [integer()]) :: any()
  def create_starting_grid(grid_size, player_ids) do
    number_of_players = length(player_ids)

    if(grid_size < 10) do
      {:error,
      "A grid size of #{grid_size}x#{grid_size} is too small. The minimum grid size is 10x10."}
    else
      number_of_empty_cells_after_placing_start_cells = grid_size * grid_size - number_of_players
      if(number_of_empty_cells_after_placing_start_cells < 100) do
        {:error,
        "There needs to be at least 100 cells left over after placing starting cells, but there was only #{number_of_empty_cells_after_placing_start_cells}."}
      else
        #get a random number of radians that is less than 1/number_of_players of a circle
        random_radians_offset = Enum.random(0..360)
        Enum.map(
          1..number_of_players,
          fn player_number ->
            %GridCell{
              index: get_start_cell_index(grid_size, number_of_players, player_number, random_radians_offset),
              player_id: Enum.at(player_ids, player_number - 1),
              live: true,
              empty: false
            }
        end)
      end
    end
  end

  @spec get_start_cell_index(integer(), integer(), integer(), integer()) :: integer()
  def get_start_cell_index(grid_size, number_of_players, player_number, random_0_to_360_offset) do
    guaranteed_margin = 8
    radius = (grid_size - 2 * guaranteed_margin)/2
    tau = 2 * :math.pi()
    radians_between_players = tau/number_of_players
    random_radians_offset = tau * random_0_to_360_offset / 360
    player_radians = radians_between_players * player_number + random_radians_offset

    x = radius * :math.cos(player_radians)
    half_of_grid = trunc(grid_size/2)
    gx = trunc(x + half_of_grid)
    y = radius * :math.sin(player_radians)
    gy = trunc(y + half_of_grid)
    trunc(gx + grid_size * gy)
  end

  @doc ~S"""
  Returns the specified number of growth cycles, as well as the ending game state.

  ##Examples
  iex> Grid.generate_growth_summary(%{}, [], 50, %{1 => %Player{top_growth_chance: 100, id: 1, mutation_chance: 0}}, 50)
  %{
    growth_cycles: [
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        generation_number: 0,
        mutation_points_earned: [],
        player_stats_changes: [],
        toast_changes: []
      },
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [],
        generation_number: 1,
        mutation_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        player_stats_changes: [
          %FungusToast.Games.PlayerStatsChange{
            fungicidal_kills: 0,
            grown_cells: 0,
            lost_dead_cells: 0,
            perished_cells: 0,
            player_id: 1,
            regenerated_cells: 0,
            stolen_dead_cells: 0
          }
        ],
        toast_changes: []
      },
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [],
        generation_number: 2,
        mutation_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        player_stats_changes: [
          %FungusToast.Games.PlayerStatsChange{
            fungicidal_kills: 0,
            grown_cells: 0,
            lost_dead_cells: 0,
            perished_cells: 0,
            player_id: 1,
            regenerated_cells: 0,
            stolen_dead_cells: 0
          }
        ],
        toast_changes: []
      },
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [],
        generation_number: 3,
        mutation_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        player_stats_changes: [
          %FungusToast.Games.PlayerStatsChange{
            fungicidal_kills: 0,
            grown_cells: 0,
            lost_dead_cells: 0,
            perished_cells: 0,
            player_id: 1,
            regenerated_cells: 0,
            stolen_dead_cells: 0
          }
        ],
        toast_changes: []
      },
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [],
        generation_number: 4,
        mutation_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        player_stats_changes: [
          %FungusToast.Games.PlayerStatsChange{
            fungicidal_kills: 0,
            grown_cells: 0,
            lost_dead_cells: 0,
            perished_cells: 0,
            player_id: 1,
            regenerated_cells: 0,
            stolen_dead_cells: 0
          }
        ],
        toast_changes: []
      },
      %FungusToast.Games.GrowthCycle{
        action_points_earned: [],
        generation_number: 5,
        mutation_points_earned: [
          %FungusToast.Games.PointsEarned{player_id: 1, points: 1}
        ],
        player_stats_changes: [
          %FungusToast.Games.PlayerStatsChange{
            fungicidal_kills: 0,
            grown_cells: 0,
            lost_dead_cells: 0,
            perished_cells: 0,
            player_id: 1,
            regenerated_cells: 0,
            stolen_dead_cells: 0
          }
        ],
        toast_changes: []
      }
    ],
    light_level: 50,
    new_game_state: []
  }
  """
  def generate_growth_summary(starting_grid_map, active_cell_changes, grid_size, player_id_to_player_map, light_level, generation_number \\ 1) do
    active_cell_changes = if(active_cell_changes == nil) do
      []
    else
      active_cell_changes
    end
    active_skills_result = Enum.reduce(active_cell_changes, %{active_cell_changes: [], lighting_level_change: 0}, fn active_cell_change, acc ->
      result = get_grid_cells_and_lighting_level_change_from_active_cell_change(active_cell_change)

      update_in(acc, [:active_cell_changes], &(&1 ++ result.active_cell_changes))
      |> update_in([:lighting_level_change], &(&1 + result.lighting_level_change))
    end)

    updated_light_level = light_level + active_skills_result.lighting_level_change

    pre_generation_number = generation_number - 1

    #each player gets one action point each round
    action_points = Enum.map(player_id_to_player_map, fn{player_id, _player}
      -> %PointsEarned{player_id: player_id, points: PointsEarned.default_action_points_per_round()}
    end)

    active_cell_changes_growth_cycle = %GrowthCycle{
      generation_number: pre_generation_number,
      toast_changes: active_skills_result.active_cell_changes,
      mutation_points_earned: [],
      action_points_earned: action_points
    }

    active_toast_changes_map = Enum.into(active_skills_result.active_cell_changes, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
    #merge the maps together. Active cell changes do not take precedence (to avoid chicanery from the API)
    updated_grid = Map.merge(starting_grid_map, active_toast_changes_map, fn _index, grid_cell_1, _grid_cell_2 -> grid_cell_1 end)

    #pass along updated light level so it can be updated on game and used in cell growth calculations
    generate_growth_summary_after_active_cell_changes(updated_grid, grid_size, player_id_to_player_map, updated_light_level, generation_number, [active_cell_changes_growth_cycle])
  end

  def get_grid_cells_and_lighting_level_change_from_active_cell_change(active_cell_change) do
    max_toast_changes = ActiveSkills.get_allowed_number_of_active_changes(active_cell_change.active_skill_id)
    if(max_toast_changes > 0 and active_cell_change.cell_indexes != nil and length(active_cell_change.cell_indexes) == 0) do
      raise "You attemped to use active skill with id #{active_cell_change.active_skill_id}, but placed no toast changes!"
    else
        # def skill_id_eye_dropper, do: 1
        # def skill_id_dead_cell, do: 2
        # def skill_id_increase_lighting, do: 3
        # def skill_id_decrease_lighting, do: 4
        skill_id_eye_dropper = ActiveSkills.skill_id_eye_dropper()
        skill_id_dead_cell = ActiveSkills.skill_id_dead_cell()
        skill_id_increase_lighting = ActiveSkills.skill_id_increase_lighting()
        skill_id_decrease_lighting = ActiveSkills.skill_id_decrease_lighting()

      case active_cell_change.active_skill_id do
        ^skill_id_eye_dropper ->
          active_cell_changes = Enum.map(active_cell_change.cell_indexes, fn index ->
            %GridCell{index: index, moist: true}
          end)

          %{active_cell_changes: active_cell_changes, lighting_level_change: 0}

        ^skill_id_dead_cell ->
          active_cell_changes = Enum.map(active_cell_change.cell_indexes, fn index ->
            %GridCell{index: index, empty: false, player_id: active_cell_change.player_id}
          end)

          %{active_cell_changes: active_cell_changes, lighting_level_change: 0}

        ^skill_id_increase_lighting ->
          %{active_cell_changes: [], lighting_level_change: ActiveSkills.lighting_points_per_lighting_skill_use()}

        ^skill_id_decrease_lighting ->
          %{active_cell_changes: [], lighting_level_change: -1.0 * ActiveSkills.lighting_points_per_lighting_skill_use()}

        _ ->
          raise "You attemped to place active cell changes for skill with id #{active_cell_change.active_skill_id}, which is not a valid active skill!"

      end
    end
  end

  @spec generate_growth_summary_after_active_cell_changes(map(), integer(), map(), integer(), integer(), list()) :: any()
  defp generate_growth_summary_after_active_cell_changes(starting_grid_map, grid_size, player_id_to_player_map, light_level, generation_number, acc) when generation_number < 6 do
    live_cells = Enum.filter(starting_grid_map, fn {_, grid_cell} -> grid_cell.live end)
    |> Enum.into(%{})

    toast_changes = Enum.map(live_cells, fn{_, grid_cell} -> generate_toast_changes(starting_grid_map, grid_size, player_id_to_player_map, grid_cell, light_level) end)
      |> Enum.reduce(%{}, fn(x, acc) -> Map.merge(x, acc) end)

    mutation_points = Enum.map(player_id_to_player_map,
      fn{player_id, player}
        -> %PointsEarned{player_id: player_id, points: calculate_mutation_points(player)}
      end)

    toast_changes_grid_cell_list = Enum.map(toast_changes, fn {_k, grid_cell} -> grid_cell end)
    player_ids = Enum.map(player_id_to_player_map, fn {player_id, _} -> player_id end)
    player_stats_map = get_toast_changes_stats(player_ids, toast_changes_grid_cell_list)
    growth_cycle = %GrowthCycle{
      generation_number: generation_number,
      toast_changes: toast_changes_grid_cell_list,
      player_stats_changes: player_stats_map,
      mutation_points_earned: mutation_points,
      action_points_earned: []
    }

    #merge the maps together. The changes from the growth cycle replace what's in the grid if there are conflicts.
    Map.merge(starting_grid_map, toast_changes, fn _index, _grid_cell_1, grid_cell_2 -> grid_cell_2 end)
    |> generate_growth_summary_after_active_cell_changes(grid_size, player_id_to_player_map, light_level, generation_number + 1, acc ++ [growth_cycle])
  end

  defp generate_growth_summary_after_active_cell_changes(ending_grid, _, _, light_level, _, acc) do
    cells_list = Enum.map(ending_grid, fn {_k, grid_cell} -> grid_cell end)
    %{growth_cycles: acc, new_game_state: cells_list, light_level: light_level}
  end

  def generate_toast_changes(starting_grid, grid_size, player_id_to_player_map, grid_cell, light_level) do
    surrounding_cells = get_surrounding_cells(starting_grid, grid_size, grid_cell.index)

    player = player_id_to_player_map[grid_cell.player_id]
    cell_changes = CellGrower.calculate_cell_growth(starting_grid, grid_size * grid_size, surrounding_cells, player, light_level)
    #check if the cell dies from apoptosis or starvation
    Map.merge(cell_changes, CellGrower.check_for_cell_death(grid_cell, surrounding_cells, player))
  end

  def get_toast_changes_stats(player_ids, toast_changes_grid_cell_list) do
    acc = Enum.map(player_ids,  fn player_id ->
    {
      player_id, %{
        player_id: player_id,
        regenerated_cells: 0,
        grown_cells: 0,
        perished_cells: 0,
        fungicidal_kills: 0,
        lost_dead_cells: 0,
        stolen_dead_cells: 0
      }
    } end)
    |> Enum.into(%{})

    Enum.reduce(toast_changes_grid_cell_list, acc, fn grid_cell, acc ->
      if(grid_cell.live) do
        if(grid_cell.previous_player_id) do
          #only call it a lost dead cell if the dead cell went to another player
          if(grid_cell.player_id != grid_cell.previous_player_id) do
            #give a lost dead cell to the player who lost the cell
            update_in(acc, [grid_cell.previous_player_id, :lost_dead_cells], &(&1 + 1))
            #give a stolen dead cell to the player who took the cell
            |> update_in([grid_cell.player_id, :stolen_dead_cells], &(&1 + 1))
          else
            #only call it a regenerated cell if the player regenerated their own cell
            update_in(acc, [grid_cell.player_id, :regenerated_cells], &(&1 + 1))
          end
        else
          update_in(acc, [grid_cell.player_id, :grown_cells], &(&1 + 1))
        end
      else
        if(grid_cell.empty) do
          acc
        else
          map = update_in(acc, [grid_cell.player_id, :perished_cells], &(&1 + 1))

          if(grid_cell.killed_by != nil) do
            update_in(map, [grid_cell.killed_by, :fungicidal_kills], &(&1 + 1))
          else
            map
          end
        end
      end
    end)
    |> Enum.map(fn {_player_id, map} -> %PlayerStatsChange
    {
      player_id: map.player_id,
      regenerated_cells: map.regenerated_cells,
      grown_cells: map.grown_cells,
      perished_cells: map.perished_cells,
      fungicidal_kills: map.fungicidal_kills,
      lost_dead_cells: map.lost_dead_cells,
      stolen_dead_cells: map.stolen_dead_cells
    } end)
  end

  @doc ~S"""
  Returns a map of player id to a map of number of grown, regenerated, and perished cells

  ## Examples

    iex(83)> Grid.get_player_growth_cycles_stats([1], [])
    %{1 => %{grown_cells: 0, perished_cells: 0, regenerated_cells: 0, fungicidal_kills: 0, lost_dead_cells: 0, stolen_dead_cells: 0}}

  """
  @spec get_player_growth_cycles_stats(list(), [%GrowthCycle{}]) :: any()
  def get_player_growth_cycles_stats(player_ids, growth_cycles) do
    acc = Enum.map(player_ids,  fn player_id -> {player_id, %{regenerated_cells: 0, grown_cells: 0, perished_cells: 0, fungicidal_kills: 0, lost_dead_cells: 0, stolen_dead_cells: 0}} end)
    |> Enum.into(%{})

    Enum.reduce(growth_cycles, acc, fn growth_cycle, acc ->
      toast_changes_stats = get_toast_changes_stats(player_ids, growth_cycle.toast_changes)
      |> Enum.map(fn player_stats_change -> {player_stats_change.player_id, player_stats_change} end)
      |> Enum.into(%{})

      Enum.reduce(toast_changes_stats, acc, fn {player_id, map}, inner_acc ->
        inner_acc
        |> update_in([player_id, :regenerated_cells], &(&1 + map.regenerated_cells))
        |> update_in([player_id, :grown_cells], &(&1 + map.grown_cells))
        |> update_in([player_id, :perished_cells], &(&1 + map.perished_cells))
        |> update_in([player_id, :fungicidal_kills], &(&1 + map.fungicidal_kills))
        |> update_in([player_id, :lost_dead_cells], &(&1 + map.lost_dead_cells))
        |> update_in([player_id, :stolen_dead_cells], &(&1 + map.stolen_dead_cells))
      end)
    end)
  end

  def get_surrounding_cells(grid, grid_size, cell_index) do
    %{
      :top_left_cell => get_top_left_cell(grid, grid_size, cell_index),
      :top_cell => get_top_cell(grid, grid_size, cell_index),
      :top_right_cell => get_top_right_cell(grid, grid_size, cell_index),
      :right_cell => get_right_cell(grid, grid_size, cell_index),
      :bottom_right_cell => get_bottom_right_cell(grid, grid_size, cell_index),
      :bottom_cell => get_bottom_cell(grid, grid_size, cell_index),
      :bottom_left_cell => get_bottom_left_cell(grid, grid_size, cell_index),
      :left_cell => get_left_cell(grid, grid_size, cell_index)
    }
  end

  @doc ~S"""
  Returns the number of mutation points earned by the player during this growth cycle based on the player's mutation_chance + 1

  ## Examples

    iex(83)> Grid.calculate_mutation_points(%FungusToast.Games.Player{mutation_chance: 100})
    2

    iex(83)> Grid.calculate_mutation_points(%FungusToast.Games.Player{mutation_chance: 0})
    1

  """
  def calculate_mutation_points(player) do
    if(Random.random_chance_hit(player.mutation_chance)) do
      #for now, you generate one mutation point at a time
      2
    else
      1
    end
  end

  @doc ~S"""
  Returns true if the given cell_index is on the top row of the grid

  ## Examples

    iex> Grid.on_top_row(0, 50)
    true

    iex> Grid.on_top_row(49, 50)
    true

    iex> Grid.on_top_row(50, 50)
    false

  """
  def on_top_row(cell_index, grid_size) do
    cell_index in 0..(grid_size - 1)
  end

  @doc ~S"""
  Returns true if the given cell_index is on the right column of the grid

  ## Examples

    #first row, last column
    iex> Grid.on_right_column(49, 50)
    true

    #second row, last column
    iex> Grid.on_right_column(99, 50)
    true

    #first row, 2nd to last column
    iex> Grid.on_right_column(48, 50)
    false

  """
  def on_right_column(cell_index, grid_size) do
    rem(cell_index + 1, grid_size) == 0
  end

  @doc ~S"""
  Returns true if the given cell_index is on the bottom row of the grid

  ## Examples

    iex> Grid.on_bottom_row(2450, 50)
    true

    iex> Grid.on_bottom_row(2499, 50)
    true

    iex> Grid.on_bottom_row(2449, 50)
    false

  """
  def on_bottom_row(cell_index, grid_size) do
    cell_index >= grid_size*grid_size - grid_size
  end

  @doc ~S"""
  Returns true if the given cell_index is on the left column of the grid

  ## Examples

    iex> Grid.on_left_column(0, 50)
    true

    iex> Grid.on_left_column(2450, 50)
    true

    iex> Grid.on_left_column(1, 50)
    false

  """
  def on_left_column(cell_index, grid_size) do
    rem(cell_index, grid_size) == 0
  end


  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_top_left_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_left_cell(%{}, 50, 51)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_left_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 51)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_top_left_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size) or on_left_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size - 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is directly above of the specified cell

  ## Examples

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_top_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the top right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the top row
    iex> Grid.get_top_right_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the right column
    iex> Grid.get_top_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }


    #it returns an empty cell if the cell is empty
    iex> Grid.get_top_right_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_top_right_cell(%{1 => %FungusToast.Games.GridCell{index: 1}}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_top_right_cell(grid, grid_size, cell_index) do
    if(on_top_row(cell_index, grid_size) or on_right_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index - grid_size + 1
      get_target_cell(grid, target_cell_index)
    end
  end

@doc ~S"""
  Returns a %GridCell{} for the position that is directly to the right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the right column
    iex> Grid.get_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_right_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_right_cell(%{1 => %FungusToast.Games.GridCell{index: 1}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 1,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_right_cell(grid, grid_size, cell_index) do
    if(on_right_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom right of the specified cell

  ## Examples

    #it returns an out of grid cell when on the right column
    iex> Grid.get_bottom_right_cell(%{}, 50, 49)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_right_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_right_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 51,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_right_cell(%{51 => %FungusToast.Games.GridCell{index: 51}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 51,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_bottom_right_cell(grid, grid_size, cell_index) do
    if(on_right_column(cell_index, grid_size) or on_bottom_row(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + grid_size + 1
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom of the specified cell

  ## Examples

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_cell(%{51 => %FungusToast.Games.GridCell{index: 50}}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_bottom_cell(grid, grid_size, cell_index) do
    if(on_bottom_row(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index + grid_size
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is to the bottom left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_bottom_left_cell(%{}, 50, 0)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an out of grid cell when on the bottom row
    iex> Grid.get_bottom_left_cell(%{}, 50, 2499)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_bottom_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_bottom_left_cell(%{50 => %FungusToast.Games.GridCell{index: 50}}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 50,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_bottom_left_cell(grid, grid_size, cell_index) do
    target_cell_index = cell_index + grid_size - 1
    if(on_bottom_row(cell_index, grid_size) or on_left_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      get_target_cell(grid, target_cell_index)
    end
  end

  @doc ~S"""
  Returns a %GridCell{} for the position that is directly to the left of the specified cell

  ## Examples

    #it returns an out of grid cell when on the left column
    iex> Grid.get_left_cell(%{}, 50, 50)
    %FungusToast.Games.GridCell{
      empty: false,
      index: nil,
      live: false,
      out_of_grid: true,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns an empty cell if the cell is empty
    iex> Grid.get_left_cell(%{}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

    #it returns the cell if the cell is occupied
    iex> Grid.get_left_cell(%{0 => %FungusToast.Games.GridCell{index: 0}}, 50, 1)
    %FungusToast.Games.GridCell{
      empty: true,
      index: 0,
      live: false,
      out_of_grid: false,
      player_id: nil,
      previous_player_id: nil
    }

  """
  def get_left_cell(grid, grid_size, cell_index) do
    if(on_left_column(cell_index, grid_size)) do
      CellGrower.make_out_of_grid_cell()
    else
      target_cell_index = cell_index - 1
      get_target_cell(grid, target_cell_index)
    end
  end

  def get_target_cell(grid, target_cell_index) do
    if(Map.has_key?(grid, target_cell_index)) do
      Map.get(grid, target_cell_index)
    else
      CellGrower.make_empty_grid_cell(target_cell_index)
    end
  end
end
