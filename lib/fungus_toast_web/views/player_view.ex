defmodule FungusToastWeb.PlayerView do
  use FungusToastWeb, :view
  alias FungusToastWeb.PlayerView

  def render("index.json", %{players: players}) do
    %{data: render_many(players, PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{id: player.id,
      user_name: player.user_name,
      active: player.active,
      human: player.human}
  end
end
