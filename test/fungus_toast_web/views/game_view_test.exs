defmodule FungusToastWeb.GameViewTest do
  use FungusToastWeb.ConnCase, async: true
  use Plug.Test
  alias FungusToastWeb.GameView
  alias FungusToast.Games.{Game, Player, GridCell, GameState, Round, GrowthCycle, PointsEarned, PlayerStatsChange, PlayerStats}
  alias FungusToast.Game.Status

  import FungusToast.Factory

  @default_player_id 1

  describe "game.json" do
    test "that the game and player information gets added to the model" do
      game = insert(:game)
      player_1 = %Player{
        name: "player name",
        id: 1,
        mutation_points: 2,
        action_points: 20,
        human: true,
        top_left_growth_chance: 3,
        top_growth_chance: 4,
        top_right_growth_chance: 5,
        right_growth_chance: 6,
        bottom_right_growth_chance: 7,
        bottom_growth_chance: 8,
        bottom_left_growth_chance: 9,
        left_growth_chance: 10,
        dead_cells: 11,
        live_cells: 12,
        regenerated_cells: 13,
        perished_cells: 14,
        grown_cells: 15,
        fungicidal_kills: 16,
        lost_dead_cells: 17,
        stolen_dead_cells: 18,
        apoptosis_chance: 19,
        starved_cell_death_chance: 20,
        mutation_chance: 21,
        regeneration_chance: 22,
        mycotoxin_fungicide_chance: 23,
        spores_chance: 24,
        user_id: 25,
        spent_mutation_points: 26
      }

      player_2 = %Player{
        id: 2,
        dead_cells: 50,
        live_cells: 51,
        regenerated_cells: 52
      }

      game = Map.put(game, :players, [player_1, player_2])
      game = Map.put(game, :end_of_game_count_down, 5)
      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.id == game.id
      assert result.number_of_human_players == game.number_of_human_players
      assert result.number_of_ai_players == game.number_of_ai_players
      assert result.grid_size == game.grid_size
      assert result.status == Status.status_not_started
      assert result.end_of_game_count_down == game.end_of_game_count_down

      assert length(result.players) == 2
      actual_player_1_info = Enum.filter(result.players, fn player -> player.id == player_1.id end) |> hd

      assert actual_player_1_info.id == player_1.id
      assert actual_player_1_info.mutation_points == player_1.mutation_points
      assert actual_player_1_info.action_points == player_1.action_points
      assert actual_player_1_info.top_left_growth_chance == player_1.top_left_growth_chance
      assert actual_player_1_info.top_growth_chance == player_1.top_growth_chance
      assert actual_player_1_info.top_right_growth_chance == player_1.top_right_growth_chance
      assert actual_player_1_info.right_growth_chance == player_1.right_growth_chance
      assert actual_player_1_info.bottom_right_growth_chance == player_1.bottom_right_growth_chance
      assert actual_player_1_info.bottom_growth_chance == player_1.bottom_growth_chance
      assert actual_player_1_info.bottom_left_growth_chance == player_1.bottom_left_growth_chance
      assert actual_player_1_info.dead_cells == player_1.dead_cells
      assert actual_player_1_info.live_cells == player_1.live_cells
      assert actual_player_1_info.regenerated_cells == player_1.regenerated_cells
      assert actual_player_1_info.perished_cells == player_1.perished_cells
      assert actual_player_1_info.grown_cells == player_1.grown_cells
      assert actual_player_1_info.fungicidal_kills == player_1.fungicidal_kills
      assert actual_player_1_info.lost_dead_cells == player_1.lost_dead_cells
      assert actual_player_1_info.stolen_dead_cells == player_1.stolen_dead_cells
      assert actual_player_1_info.spent_mutation_points == player_1.spent_mutation_points
      assert actual_player_1_info.apoptosis_chance == player_1.apoptosis_chance
      assert actual_player_1_info.starved_cell_death_chance == player_1.starved_cell_death_chance
      assert actual_player_1_info.mutation_chance == player_1.mutation_chance
      assert actual_player_1_info.regeneration_chance == player_1.regeneration_chance
      assert actual_player_1_info.mycotoxin_fungicide_chance == player_1.mycotoxin_fungicide_chance
      assert actual_player_1_info.spores_chance == player_1.spores_chance

      #make sure that the game totals are the sum of the player info
      assert result.total_dead_cells == player_1.dead_cells + player_2.dead_cells
      assert result.total_live_cells == player_1.live_cells + player_2.live_cells
      assert result.total_empty_cells == Game.number_of_empty_cells(game)
      assert result.total_regenerated_cells  == player_1.regenerated_cells + player_2.regenerated_cells
    end

    test "that AI players and players with user ids have a status of Joined and humans without user ids are Not Joined" do
      ai_player = %Player{id: 1, human: false, user_id: nil }
      not_joined_human_player = %Player{id: 2, human: true, user_id: nil}
      joined_human_player = %Player{id: 3, human: true, user_id: 1}

      game = %Game{players: [ai_player, not_joined_human_player, joined_human_player]}
      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert length(result.players) == 3

      transformed_ai_player = Enum.filter(result.players, fn player -> player.id == ai_player.id end) |> hd
      assert transformed_ai_player.status == "Joined"

      not_joined_human_player = Enum.filter(result.players, fn player -> player.id == not_joined_human_player.id end) |> hd
      assert not_joined_human_player.status == "Not Joined"

      not_joined_human_player = Enum.filter(result.players, fn player -> player.id == joined_human_player.id end) |> hd
      assert not_joined_human_player.status == "Joined"
    end

    test "that the starting game state gets added" do
      game = %Game{players: []}

      player_id = @default_player_id
      cells_map = get_all_cell_types()
      live_cell = cells_map.live_cell
      dead_cell = cells_map.dead_cell
      regenerated_cell = cells_map.regenerated_cell
      moist_cell = cells_map.moist_cell
      murdered_cell = cells_map.murdered_cell
      lost_dead_cell = cells_map.lost_dead_cell
      cells = [live_cell, dead_cell, regenerated_cell, moist_cell, murdered_cell, lost_dead_cell]

      starting_game_state = %GameState{round_number: 1, cells: cells}

      starting_player_stats = [%PlayerStats{player_id: player_id}]
      latest_completed_round = %Round{starting_game_state: starting_game_state, starting_player_stats: starting_player_stats}

      game_with_round = %{game: game, latest_completed_round: latest_completed_round}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.starting_game_state != nil
      actual_starting_game_state = result.starting_game_state
      assert actual_starting_game_state.round_number == starting_game_state.round_number
      assert length(actual_starting_game_state.fungal_cells) == length(cells)

      assert result.starting_player_stats != nil
      actual_player_stats = Map.get(result.starting_player_stats, player_id)
      assert actual_player_stats.player_id == player_id

      actual_live_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == live_cell.index end) |> hd
      assert_cells_match(actual_live_cell, live_cell)

      actual_dead_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == dead_cell.index end) |> hd
      assert_cells_match(actual_dead_cell, dead_cell)

      #TODO Looking at this code I'm not sure why I bothered putting in each cell type and looking for them specifically. Seems irrelevant to the test? Need to check with
      #someone who's brain isn't fried.
      actual_regenerated_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == regenerated_cell.index end) |> hd
      assert_cells_match(actual_regenerated_cell, regenerated_cell)

      actual_moist_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == moist_cell.index end) |> hd
      assert_cells_match(actual_moist_cell, moist_cell)

      actual_murdered_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == murdered_cell.index end) |> hd
      assert_cells_match(actual_murdered_cell, murdered_cell)

      actual_lost_dead_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == lost_dead_cell.index end) |> hd
      assert_cells_match(actual_lost_dead_cell, lost_dead_cell)
    end

    test "that growth cycles are returned" do
      game = %Game{players: []}

      player_1_id = @default_player_id
      player_2_id = 2

      cells_map = get_all_cell_types(player_1_id, 2, player_1_id)
      live_cell = cells_map.live_cell
      dead_cell = cells_map.dead_cell
      regenerated_cell = cells_map.regenerated_cell
      murdered_cell = cells_map.murdered_cell
      lost_dead_cell = cells_map.lost_dead_cell

      growth_cycle_1_toast_changes = [
        live_cell,
        dead_cell,
        regenerated_cell,
        murdered_cell,
        lost_dead_cell
      ]

      player_1_player_stats_change = %PlayerStatsChange{ player_id: player_1_id, grown_cells: 1, perished_cells: 1, regenerated_cells: 1, lost_dead_cells: 1 }
      player_2_player_stats_change = %PlayerStatsChange{ player_id: player_2_id }
      player_stats_changes = [player_1_player_stats_change, player_2_player_stats_change]

      player_1_mutation_points_earned = %PointsEarned{player_id: player_1_id, points: 20}
      player_2_mutation_points_earned = %PointsEarned{player_id: player_2_id, points: 30}
      mutation_points_earned = [player_1_mutation_points_earned, player_2_mutation_points_earned]

      player_1_action_points_earned = %PointsEarned{player_id: player_1_id, points: 40}
      player_2_action_points_earned = %PointsEarned{player_id: player_2_id, points: 50}
      action_points_earned = [player_1_action_points_earned, player_2_action_points_earned]

      growth_cycle_1 = %GrowthCycle
      {
        generation_number: 1,
        toast_changes: growth_cycle_1_toast_changes,
        mutation_points_earned: mutation_points_earned,
        action_points_earned: action_points_earned,
        player_stats_changes: player_stats_changes
      }

      #just have one additional growth cycle to make sure it works with multiple growth cycles
      growth_cycle_2_toast_changes = [
        %GridCell{}
      ]

      growth_cycle_2 = %GrowthCycle{generation_number: 2, toast_changes: growth_cycle_2_toast_changes, mutation_points_earned: mutation_points_earned}

      growth_cycles = [growth_cycle_1, growth_cycle_2]
      latest_completed_round = %Round{starting_game_state: %GameState{cells: []}, growth_cycles: growth_cycles}
      game_with_round = %{game: game, latest_completed_round: latest_completed_round}

      result = GameView.render("game.json", %{game: game_with_round})

      actual_growth_cycles = result.growth_cycles
      assert length(actual_growth_cycles) == length(growth_cycles)

      actual_growth_cycle_1 = Enum.at(actual_growth_cycles, 0)
      actual_growth_cycle_1_toast_changes = actual_growth_cycle_1.toast_changes
      assert length(actual_growth_cycle_1_toast_changes) == length(growth_cycle_1_toast_changes)

      actual_newly_grown_cell = Enum.filter(actual_growth_cycle_1_toast_changes, fn cell -> cell.index == live_cell.index end) |> hd
      assert_cells_match(actual_newly_grown_cell, live_cell)

      #TODO Looking at this code I'm not sure why I bothered putting in each cell type and looking for them specifically. Seems irrelevant to the test? Need to check with
      #someone who's brain isn't fried.
      actual_newly_dead_cell = Enum.filter(actual_growth_cycle_1_toast_changes, fn cell -> cell.index == dead_cell.index end) |> hd
      assert_cells_match(actual_newly_dead_cell, dead_cell)

      actual_newly_regenerated_cell = Enum.filter(actual_growth_cycle_1_toast_changes, fn cell -> cell.index == regenerated_cell.index end) |> hd
      assert_cells_match(actual_newly_regenerated_cell, regenerated_cell)

      actual_murdered_cell = Enum.filter(actual_growth_cycle_1_toast_changes, fn cell -> cell.index == murdered_cell.index end) |> hd
      assert_cells_match(actual_murdered_cell, murdered_cell)

      actual_lost_dead_cell = Enum.filter(actual_growth_cycle_1_toast_changes, fn cell -> cell.index == lost_dead_cell.index end) |> hd
      assert_cells_match(actual_lost_dead_cell, lost_dead_cell)

      actual_player_stats_changes = actual_growth_cycle_1.player_stats_changes
      assert actual_player_stats_changes[player_1_player_stats_change.player_id] == player_1_player_stats_change
      assert actual_player_stats_changes[player_2_player_stats_change.player_id] == player_2_player_stats_change

      actual_mutation_points_earned = actual_growth_cycle_1.mutation_points_earned
      assert actual_mutation_points_earned[player_1_mutation_points_earned.player_id] == player_1_mutation_points_earned.points
      assert actual_mutation_points_earned[player_2_mutation_points_earned.player_id] == player_2_mutation_points_earned.points

      actual_action_points_earned = actual_growth_cycle_1.action_points_earned
      assert actual_action_points_earned[player_1_action_points_earned.player_id] == player_1_action_points_earned.points
      assert actual_action_points_earned[player_2_action_points_earned.player_id] == player_2_action_points_earned.points

      actual_growth_cycle_2 = Enum.at(actual_growth_cycles, 1)
      actual_growth_cycle_2_toast_changes = actual_growth_cycle_2.toast_changes
      assert length(actual_growth_cycle_2_toast_changes) == length(growth_cycle_2_toast_changes)
    end

    test "that growth cycles are empty and round number is 0 if the game has not started" do
      game = %Game{players: []}

      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.growth_cycles == []
      assert result.round_number == 0
    end

    test "that the round number is one higher than the latest completed round" do
      game = %Game{players: []}

      last_completed_round_number = 2
      latest_completed_round = %Round{starting_game_state: %GameState{cells: []}, growth_cycles: [%GrowthCycle{}], number: last_completed_round_number}
      game_with_round = %{game: game, latest_completed_round: latest_completed_round}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.round_number == last_completed_round_number + 1
    end

    test "that starting game state and starting player stats are nil if there hasn't been a completed round yet" do
      game = %Game{players: []}

      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.starting_game_state == nil
      assert result.starting_player_stats == nil
    end

    defp get_all_cell_types(player_id \\ @default_player_id, previous_player_id \\ @default_player_id, killed_by_player_id \\ @default_player_id) do
      live_cell =  %GridCell{
        index: 1,
        player_id: player_id,
        live: true
      }

      dead_cell =  %GridCell{
        index: 2,
        player_id: player_id,
        live: false
      }

      regenerated_cell =  %GridCell{
        index: 3,
        player_id: player_id,
        live: true,
        previous_player_id: previous_player_id
      }

      moist_cell =  %GridCell{
        index: 4,
        live: false,
        empty: true,
        moist: true
      }

      murdered_cell =  %GridCell{
        index: 5,
        player_id: player_id,
        live: false,
        killed_by: killed_by_player_id
      }

      lost_dead_cell =  %GridCell{
        index: 6,
        player_id: player_id,
        live: true,
        previous_player_id: previous_player_id
      }

      %{live_cell: live_cell, dead_cell: dead_cell, regenerated_cell: regenerated_cell, moist_cell: moist_cell, murdered_cell: murdered_cell, lost_dead_cell: lost_dead_cell}
    end

    defp assert_cells_match(actual_cell, expected_cell) do
      assert actual_cell.index == expected_cell.index
      assert actual_cell.player_id == expected_cell.player_id
      assert actual_cell.live == expected_cell.live
      assert actual_cell.previous_player_id == expected_cell.previous_player_id
    end
  end
end
