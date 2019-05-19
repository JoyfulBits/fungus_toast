defmodule FungusToastWeb.GameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Rounds

  action_fallback FungusToastWeb.FallbackController

  #TODO this isn't in router.ex -- perhaps we should delete it?
  def index(conn, %{"user_id" => user_id}) do
    with {:ok, games} <- Games.list_active_games_for_user(user_id) do
      render(conn, "index.json", games: games)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    latest_completed_round = Rounds.get_latest_completed_round_for_game(game.id)
    render(conn, "show.json", game: %{game: game, latest_completed_round: latest_completed_round})
  end

  def create(conn, %{"user_name" => user_name} = game) do
    #TODO should the user id be passed in or the user name?
    #TODO return a better error code when the user can't be found
    game = Games.create_game(user_name, game)
    latest_completed_round = Rounds.get_latest_completed_round_for_game(game.id)
    game_with_round = %{game: game, latest_completed_round: latest_completed_round}
    conn
    |> put_status(:created)
    |> render("show.json", game: game_with_round)
  end
end
