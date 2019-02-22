defmodule FungusToastWeb.RoundController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Games.Round

  action_fallback FungusToastWeb.FallbackController

  # TODO: move the preload into Games
  def create(conn, %{"game_id" => game_id, "round" => round_params}) do
    with {:ok, %Round{} = round} <- Games.create_round(game_id, round_params) do
      round = round |> FungusToast.Repo.preload(:game)

      conn
      |> put_status(:created)
      |> render("show.json", round: round)
    end
  end

  def show(conn, %{"id" => id}) do
    round = Games.get_round!(id)
    render(conn, "show.json", round: round)
  end
end
