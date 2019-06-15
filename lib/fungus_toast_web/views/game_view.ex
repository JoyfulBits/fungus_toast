defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view
  alias FungusToastWeb.GameView
  alias FungusToast.Games.Game

  def render("index.json", %{games: games}) do
    render_many(games, GameView, "game.json")
  end

  def render("show.json", %{game: game_with_round}) do
    render_one(game_with_round, GameView, "game.json")
  end

  def render("game.json",  %{game: game_with_round}), do: game_json(game_with_round)

  defp game_json(game_with_round) do
    game = game_with_round.game
    latest_completed_round = game_with_round.latest_completed_round
    game_totals = get_game_totals(game.players)
    %{
      id: game.id,
      grid_size: game.grid_size,
      number_of_ai_players: game.number_of_ai_players,
      number_of_human_players: game.number_of_human_players,
      status: game.status,
      round_number: if(latest_completed_round == nil) do 0 else latest_completed_round.number + 1 end,
      players: Enum.map(game.players, &player_json(&1)),
      starting_game_state: starting_game_state_json(latest_completed_round),
      starting_player_stats: starting_player_stats_json(latest_completed_round),
      growth_cycles: growth_cycles_json(latest_completed_round),
      total_live_cells: game_totals.total_live_cells,
      total_dead_cells: game_totals.total_dead_cells,
      total_regenerated_cells: game_totals.total_regenerated_cells,
      total_empty_cells: Game.number_of_empty_cells(game),
      end_of_game_count_down: game.end_of_game_count_down
    }
  end

  defp get_game_totals(players) do
    Enum.reduce(players, %{total_live_cells: 0, total_dead_cells: 0, total_regenerated_cells: 0}, fn player, acc ->
      update_in(acc, [:total_live_cells], &(&1 + player.live_cells))
      |> update_in([:total_dead_cells], &(&1 + player.dead_cells))
      |> update_in([:total_regenerated_cells], &(&1 + player.regenerated_cells))
    end)
  end

  #TODO where should this go since it's referenced in player_skill_view as well?
  def player_json(player) do
    status = if(!player.human or ((player.human and player.user_id != nil))) do
      "Joined"
    else
      "Not Joined"
    end
    %{
      id: player.id,
      name: player.name,
      mutation_points: player.mutation_points,
      human: player.human,
      top_left_growth_chance: player.top_left_growth_chance,
      top_growth_chance: player.top_growth_chance,
      top_right_growth_chance: player.top_right_growth_chance,
      right_growth_chance: player.right_growth_chance,
      bottom_right_growth_chance: player.bottom_right_growth_chance,
      bottom_growth_chance: player.bottom_growth_chance,
      bottom_left_growth_chance: player.bottom_left_growth_chance,
      left_growth_chance: player.left_growth_chance,
      dead_cells: player.dead_cells,
      live_cells: player.live_cells,
      regenerated_cells: player.regenerated_cells,
      perished_cells: player.perished_cells,
      grown_cells: player.grown_cells,
      spent_mutation_points: player.spent_mutation_points,
      fungicidal_kills: player.fungicidal_kills,
      lost_dead_cells: player.lost_dead_cells,
      stolen_dead_cells: player.stolen_dead_cells,
      apoptosis_chance: player.apoptosis_chance,
      starved_cell_death_chance: player.starved_cell_death_chance,
      mutation_chance: player.mutation_chance,
      regeneration_chance: player.regeneration_chance,
      mycotoxin_fungicide_chance: player.mycotoxin_fungicide_chance,
      moisture_growth_boost: player.moisture_growth_boost,
      spores_chance: player.spores_chance,
      status: status
    }
  end

  defp starting_game_state_json(round) do
    if(round == nil) do
      nil
    else
      %{
        round_number: round.number,
        fungal_cells: Enum.map(round.starting_game_state.cells, fn grid_cell -> make_api_fungal_cell(grid_cell) end)
      }
    end
  end

  defp starting_player_stats_json(round) do
    if(round == nil) do
      nil
    else
        round.starting_player_stats
        |> Enum.map(fn player_stats ->
          { player_stats.player_id, player_stats} end)
        |> Enum.into(%{})
    end
  end

  defp make_api_fungal_cell(grid_cell) do
    %{index: grid_cell.index, player_id: grid_cell.player_id, live: grid_cell.live, moist: grid_cell.moist, previous_player_id: grid_cell.previous_player_id}
  end

  defp growth_cycles_json(round) do
    if(round == nil) do
      []
    else
      Enum.map(round.growth_cycles, fn growth_cycle ->
        toast_changes = Enum.map(growth_cycle.toast_changes, fn grid_cell -> make_api_fungal_cell(grid_cell) end)

        player_stats_changes = Enum.map(growth_cycle.player_stats_changes, fn player_stats_changes ->
          {player_stats_changes.player_id, player_stats_changes} end)
        |> Enum.into(%{})

        mutation_points_earned = Enum.map(growth_cycle.mutation_points_earned, fn mutation_points_earned ->
          {mutation_points_earned.player_id, mutation_points_earned.points} end)
        |> Enum.into(%{})

        action_points_earned = Enum.map(growth_cycle.action_points_earned, fn action_points_earned ->
          {action_points_earned.player_id, action_points_earned.points} end)
        |> Enum.into(%{})

        %{toast_changes: toast_changes, player_stats_changes: player_stats_changes, mutation_points_earned: mutation_points_earned, action_points_earned: action_points_earned}
      end)
    end
  end
end
