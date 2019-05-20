defmodule FungusToastWeb.JoinedGameController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def create(conn, %{"game_id" => game_id, "user_name" => user_name}) do
    #TODO should the user id be passed in or the user name?
    join_result = Games.join_game(game_id, user_name)

    case join_result do
      {:error, :no_open_slots} ->
        conn
        |> put_status(:conflict)
        |> render("game_full.json", %{})
      {:error, :user_already_joined} ->
        conn
        |> put_status(:bad_request)
        |> render("user_already_joined.json", %{})
      {:ok, next_round_available} ->
        conn
        |> put_status(:ok)
        |> render("show.json", result: next_round_available)
      _ ->
        conn
        |> put_status(:internal_server_error )
        |> render("fail.json", result: nil)
    end
  end
end
