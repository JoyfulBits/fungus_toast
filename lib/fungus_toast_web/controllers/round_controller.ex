defmodule FungusToastWeb.RoundController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Games.Round

  action_fallback FungusToastWeb.FallbackController

  def show(conn, %{"id" => id}) do
    round = Games.get_round!(id)
    render(conn, "show.json", round: round)
  end
end
