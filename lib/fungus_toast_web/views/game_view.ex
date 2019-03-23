defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view
  alias FungusToastWeb.GameView

  def render("index.json", %{games: games}) do
    render_many(games, GameView, "game.json")
  end

  def render("show.json", %{game: game}) do
    render_one(game, GameView, "game.json")
  end

  def render("game.json", %{game: game}) do
    game
    |> map_from()
    |> transform_player_fields()
    |> Map.drop([:inserted_at, :rounds, :updated_at])
  end

  @player_json_fields [
    :name,
    :id,
    :mutation_points,
    :human,
    :top_left_growth_chance,
    :top_growth_chance,
    :top_right_growth_chance,
    :right_growth_chance,
    :bottom_right_growth_chance,
    :bottom_growth_chance,
    :bottom_left_growth_chance,
    :left_growth_chance,
    :dead_cells,
    :live_cells,
    :regenerated_cells,
    :hyperMutation_skill_level,
    :anti_apoptosis_skill_level,
    :regeneration_skill_level,
    :budding_skill_level,
    :mycotoxins_skill_level,
    :apoptosis_chance,
    :starved_cell_death_chance,
    :mutation_chance,
    :regeneration_chance,
    :mycotoxin_fungicide_chance,
    :status
  ]
  defp transform_player_fields(%{players: players} = game) do
    p =
      Enum.map(players, &map_from(&1))
      |> Enum.map(&Map.take(&1, @player_json_fields))

    Map.put(game, :players, p)
  end
end
