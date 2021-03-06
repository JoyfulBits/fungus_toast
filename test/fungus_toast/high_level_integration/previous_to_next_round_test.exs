defmodule FungusToast.Games.PreviousToNextRoundTest do
  use FungusToast.DataCase
  use Plug.Test
  alias FungusToast.{Games, Skills, Rounds}
  alias Fixtures.Accounts.User

  describe "tests for proving that the stats between two rounds make sense" do
    #this is a heavy duty integration test that runs most of a game to check stats
    @tag :skip
    test "that the previous round's starting player state plus state changes equals the next round's starting player state" do
      user = User.create!()
      game = Games.create_game(user.user_name,
        %{number_of_human_players: 1, number_of_ai_players: 0})
      game = spend_all_skill_points_to_trigger_next_round(game)
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()
      |> spend_all_skill_points_to_trigger_next_round()

      latest_completed_round = Rounds.get_latest_completed_round_for_game(game.id)
      latest_round = Rounds.get_latest_round_for_game(game.id)
      starting_player_stats = latest_completed_round.starting_player_stats
      ending_player_stats = latest_round.starting_player_stats

      player_stats_map = Enum.map(game.players, fn player ->
        {player.id,
          %{
            player_id: player.id,
            grown_cells: 0,
            perished_cells: 0,
            regenerated_cells: 0,
            fungicidal_kills: 0,
            lost_dead_cells: 0,
            stolen_dead_cells: 0
          }
        }
      end)
      |> Enum.into(%{})

      sum_of_stats_changes = Enum.reduce(latest_completed_round.growth_cycles, player_stats_map, fn growth_cycle, acc ->
        Enum.reduce(growth_cycle.player_stats_changes, acc, fn player_stats_change, acc ->
          update_in(acc, [player_stats_change.player_id, :grown_cells], &(&1 + player_stats_change.grown_cells))
          |> update_in([player_stats_change.player_id, :perished_cells], &(&1 + player_stats_change.perished_cells))
          |> update_in([player_stats_change.player_id, :regenerated_cells], &(&1 + player_stats_change.regenerated_cells))
          |> update_in([player_stats_change.player_id, :fungicidal_kills], &(&1 + player_stats_change.fungicidal_kills))
          |> update_in([player_stats_change.player_id, :lost_dead_cells], &(&1 + player_stats_change.lost_dead_cells))
          |> update_in([player_stats_change.player_id, :stolen_dead_cells], &(&1 + player_stats_change.stolen_dead_cells))
        end)
      end)

      sum_of_toast_changes = Enum.reduce(latest_completed_round.growth_cycles, player_stats_map, fn growth_cycle, acc ->
        Enum.reduce(growth_cycle.toast_changes, acc, fn grid_cell, inner_acc ->
          if(grid_cell.live) do
            if(grid_cell.previous_player_id == nil) do
              update_in(inner_acc, [grid_cell.player_id, :grown_cells], &(&1 + 1))
            else
              if(grid_cell.player_id != grid_cell.previous_player_id) do
                update_in(inner_acc, [grid_cell.previous_player_id, :lost_dead_cells], &(&1 + 1))
                |> update_in([grid_cell.player_id, :stolen_dead_cells], &(&1 + 1))
              else
                update_in(inner_acc, [grid_cell.player_id, :regenerated_cells], &(&1 + 1))
              end
            end
          else
            if(grid_cell.empty) do
              acc
            else
              map = update_in(inner_acc, [grid_cell.player_id, :perished_cells], &(&1 + 1))
              if(grid_cell.killed_by != nil) do
                update_in(map, [grid_cell.killed_by, :fungicidal_kills], &(&1 + 1))
              else
                map
              end
            end
          end
        end)
      end)
      IO.inspect "Sum of toast changes:"
      IO.inspect sum_of_toast_changes

      Enum.each(starting_player_stats, fn starting_player_stat ->
        IO.inspect "Starting player stats: "
        IO.inspect starting_player_stat
        IO.inspect "Summarized changes:"
        IO.inspect sum_of_stats_changes

        ending_stats_for_player = Enum.find(ending_player_stats, fn player_stats -> player_stats.player_id == starting_player_stat.player_id end)
        IO.inspect "Ending Stats:"
        IO.inspect ending_stats_for_player

        summarized_stats_for_player = sum_of_stats_changes[starting_player_stat.player_id]
        toast_changes_for_player = sum_of_toast_changes[starting_player_stat.player_id]

        #starting player stats plus player stats changes should be the starting player stats for the next round
        assert (starting_player_stat.grown_cells + summarized_stats_for_player.grown_cells) == ending_stats_for_player.grown_cells
        assert (starting_player_stat.perished_cells + summarized_stats_for_player.perished_cells) == ending_stats_for_player.perished_cells
        assert (starting_player_stat.regenerated_cells + summarized_stats_for_player.regenerated_cells) == ending_stats_for_player.regenerated_cells
        assert (starting_player_stat.fungicidal_kills + summarized_stats_for_player.fungicidal_kills) == ending_stats_for_player.fungicidal_kills
        assert (starting_player_stat.lost_dead_cells + summarized_stats_for_player.lost_dead_cells) == ending_stats_for_player.lost_dead_cells
        assert (starting_player_stat.stolen_dead_cells + summarized_stats_for_player.stolen_dead_cells) == ending_stats_for_player.stolen_dead_cells

        expected_total_live_cells = starting_player_stat.live_cells + summarized_stats_for_player.grown_cells + summarized_stats_for_player.regenerated_cells - summarized_stats_for_player.perished_cells
        IO.inspect "#{starting_player_stat.live_cells} + #{summarized_stats_for_player.grown_cells} + #{summarized_stats_for_player.regenerated_cells} - #{summarized_stats_for_player.perished_cells} = #{expected_total_live_cells}"
        IO.inspect "player id: #{starting_player_stat.player_id}"
        assert expected_total_live_cells == ending_stats_for_player.live_cells

        expected_total_dead_cells = starting_player_stat.dead_cells + summarized_stats_for_player.perished_cells - summarized_stats_for_player.regenerated_cells - summarized_stats_for_player.lost_dead_cells
        assert expected_total_dead_cells == ending_stats_for_player.dead_cells

        #also, starting player stats plus toast changes should be the starting player stats for the next round
        assert (starting_player_stat.grown_cells + toast_changes_for_player.grown_cells) == ending_stats_for_player.grown_cells
        assert (starting_player_stat.perished_cells + toast_changes_for_player.perished_cells) == ending_stats_for_player.perished_cells
        assert (starting_player_stat.regenerated_cells + toast_changes_for_player.regenerated_cells) == ending_stats_for_player.regenerated_cells
        assert (starting_player_stat.fungicidal_kills + toast_changes_for_player.fungicidal_kills) == ending_stats_for_player.fungicidal_kills
        assert (starting_player_stat.lost_dead_cells + toast_changes_for_player.lost_dead_cells) == ending_stats_for_player.lost_dead_cells
        assert (starting_player_stat.stolen_dead_cells + toast_changes_for_player.stolen_dead_cells) == ending_stats_for_player.stolen_dead_cells
      end)
    end

    defp spend_all_skill_points_to_trigger_next_round(game) do
      human_player = get_human_player(game)
      #trigger the next round by spending all points
      skill = Skills.get_skill!(Skills.skill_id_budding)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => [], "points_spent" => human_player.mutation_points}}
      {:ok, next_round_available: new_round, updated_player: _updated_player} = Games.spend_human_player_mutation_points(human_player.id, game.id, upgrade_attrs)
      assert new_round

      Games.get_game!(game.id)
    end

    defp get_human_player(game) do
      Enum.find(game.players, fn player -> player.human end)
    end
  end
end
