defmodule FungusToastWeb.GameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"user_id" => user_id} = params) do
    active = Map.get(params, "active") in ["true", "1"]

    with {:ok, games} <- Games.list_games_for_user(user_id, active) do
      render(conn, "index.json", games: games)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id) 
    render(conn, "show.json", game: game)
  end

  def create(conn, %{"user_name" => user_name} = game) do
    #TODO should the user id be passed in or the user name?
    #TODO return a better error code when the user can't be found
    with {:ok, game} <- Games.create_game(user_name, game) do
      conn
      |> put_status(:created)
      |> render("show.json", game: game)
    end
  end
end
