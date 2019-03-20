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
    transform_game_fields(game)
    |> transform_player_fields()
  end

  defp transform_game_fields(game) do
    {value, map} = map_from(game) |> Map.pop(:grid_size)
    Map.put_new(map, :number_of_rows, value)
    |> Map.put_new(:number_of_columns, value)
    |> Map.put_new(:number_of_cells, trunc(:math.pow(value, 2)))
  end

  defp transform_player_fields(%{players: _players} = game) do
    game # TODO: tansform
  end
end
