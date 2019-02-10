defmodule FungusToastWeb.PlayerView do
  use FungusToastWeb, :view
  alias FungusToastWeb.PlayerView

  def render("index.json", %{players: players}) do
    render_many(players, PlayerView, "player.json")
  end

  def render("show.json", %{player: player}) do
    render_one(player, PlayerView, "player.json")
  end

  def render("player.json", %{player: player}), do: map_from(player)
end
