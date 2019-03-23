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
  end

  defp transform_player_fields(%{players: players} = game) do
    p = Enum.map(players, &map_from(&1))
    |> Enum.map(&Map.drop(&1, [:skills, :user, :game]))
    Map.put(game, :players, p)
  end
end
