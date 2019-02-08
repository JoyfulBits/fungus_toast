defmodule FungusToastWeb.GameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, params) do
    user_id = Map.get(params, "user_id")
    active = Map.get(params, "active", "false") |> active?()

    with {:ok, games} <- Games.list_games_for_user(user_id, active) do
      games = games
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

  defp active?("1"), do: true
  defp active?("true"), do: true
  defp active?("false"), do: false
  defp active?(_), do: :error
end
