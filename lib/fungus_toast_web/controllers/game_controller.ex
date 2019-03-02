defmodule FungusToastWeb.GameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, params) do
    user_id = Map.get(params, "user_id")
    active? = Map.get(params, "active") in ["true"]

    # TODO: list_games_for_user should preload and decorate
    with {:ok, games} <- Games.list_games_for_user(user_id, active?) do
      games =
        games
        |> Games.preload_for_games()
        |> Games.decorate_games()

      render(conn, "index.json", games: games)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id) |> Games.preload_for_games()
    render(conn, "show.json", game: game)
  end

  def create(conn, game) do
    with {:ok, game} <- Games.create_game(game) do
      game = game |> Games.preload_for_games()

      conn
      |> put_status(:created)
      |> render("show.json", game: game)
    end
  end
end
