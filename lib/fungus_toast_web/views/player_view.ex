defmodule FungusToastWeb.PlayerView do
  use FungusToastWeb, :view
  alias FungusToastWeb.PlayerView

  def render("index.json", %{players: players}) do
    render_many(players, PlayerView, "player.json")
  end

  def render("show.json", %{player: player}) do
    render_one(player, PlayerView, "player.json")
  end

  def render("player.json", %{player: player}) do
    # TODO: Move this into a helper that accepts a struct
    Map.from_struct(player)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
