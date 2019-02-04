defmodule FungusToastWeb.GameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id) |> FungusToast.Repo.preload(:rounds) |> FungusToast.Repo.preload(:players)
    render(conn, "show.json", game: game)
  end

  def create(conn, game) do
    with {:ok, game} <- Games.create_game(game) do
      game = game |> FungusToast.Repo.preload(:rounds)
      conn
      |> put_status(:created)
      |> render("show.json", game: game)
    end
  end
end
