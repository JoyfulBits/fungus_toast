defmodule FungusToastWeb.PlayerController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Games.Player

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => game_id}) do
    players = Games.list_players_for_game(game_id) |> FungusToast.Repo.preload([:user, :game, :skills])
    render(conn, "index.json", players: players)
  end

  def create(conn, %{"game_id" => game_id, "player" => player_params}) do
    with {:ok, %Player{} = player} <- Games.create_player(game_id, player_params) do
      player = player |> FungusToast.Repo.preload([:user, :game, :skills])
      conn
      |> put_status(:created)
      |> render("show.json", player: player)
    end
  end

  def show(conn, %{"game_id" => game_id, "id" => id}) do
    player = Games.get_player_for_game(game_id, id)
    player = player |> FungusToast.Repo.preload([:user, :game, :skills])
    render(conn, "show.json", player: player)
  end
end
