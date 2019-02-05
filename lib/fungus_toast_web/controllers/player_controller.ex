defmodule FungusToastWeb.PlayerController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Games.Player

  action_fallback FungusToastWeb.FallbackController

  # def index(conn, _params) do
  #   players = Games.list_players()
  #   render(conn, "index.json", players: players)
  # end

  def create(conn, %{"game_id" => game_id, "user_id" => user_id, "player" => player_params}) do
    with {:ok, %Player{} = player} <- Games.create_player(game_id, user_id, player_params) do
      player = player
               |> FungusToast.Repo.preload(:user)
               |> FungusToast.Repo.preload(:game)
               |> FungusToast.Repo.preload(:player_skills)
               |> FungusToast.Repo.preload(:skills)
      conn
      |> put_status(:created)
      |> render("show.json", player: player)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Games.get_player!(id)
    player = player
             |> FungusToast.Repo.preload(:user)
             |> FungusToast.Repo.preload(:game)
             |> FungusToast.Repo.preload(:player_skills)
             |> FungusToast.Repo.preload(:skills)
    render(conn, "show.json", player: player)
  end
end
