defmodule FungusToastWeb.PlayerController do
  use FungusToastWeb, :controller

  alias FungusToast.Players
  alias FungusToast.Players.Player

  action_fallback FungusToastWeb.FallbackController

  # def index(conn, _params) do
  #   players = Players.list_players()
  #   render(conn, "index.json", players: players)
  # end

  def create(conn, %{"game_id" => game_id, "user_id" => user_id, "player" => player_params}) do
    with {:ok, %Player{} = player} <- Players.create_player(game_id, user_id, player_params) do
      player = player |> FungusToast.Repo.preload(:user) |> FungusToast.Repo.preload(:game)
      conn
      |> put_status(:created)
      |> render("show.json", player: player)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    player = player |> FungusToast.Repo.preload(:user) |> FungusToast.Repo.preload(:game)
    render(conn, "show.json", player: player)
  end
end
