defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view
  alias FungusToastWeb.GameView

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
    %{
      id: game.id,
      grid_size: game.grid_size,
      number_of_ai_players: game.number_of_ai_players,
      number_of_human_players: game.number_of_human_players,
      status: game.status,
      players: Enum.map(game.players, &player_json(&1)),
      starting_game_state: starting_game_state_json(latest_completed_round)
    }
  end

  defp player_json(player) do
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
      apoptosis_chance: player.apoptosis_chance,
      starved_cell_death_chance: player.starved_cell_death_chance,
      mutation_chance: player.mutation_chance,
      regeneration_chance: player.regeneration_chance,
      mycotoxin_fungicide_chance: player.mycotoxin_fungicide_chance
    }
  end

  defp starting_game_state_json(round) do
    if(round == nil) do
      nil
    else
      %{
        round_number: round.number,
        fungal_cells: Enum.map(round.game_state.cells, fn grid_cell ->
          %{cell_index: grid_cell.index, player_id: grid_cell.player_id, dead: !grid_cell.live, previous_player_id: grid_cell.previous_player_id}
        end)
      }
    end
  end
end
