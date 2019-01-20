defmodule FungusToastWeb.GameControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Games
  alias FungusToast.Games.Game

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{number_of_human_players: 2})
    game
  end

  defp create_game(_) do
    game = fixture(:game)
    {:ok, game: game}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET" do
    setup [:create_game]

    test "renders game when data is valid", %{conn: conn, game: %Game{id: id}} do
      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{ "id" => id } = json_response(conn, 200)
    end
  end

  describe "POST" do
    def game_params() do
      %{
        "number_of_human_players" => 2,
        "number_of_ai_players" => 2,
        "number_of_columns" => 100,
        "number_of_rows" => 100,
      }
    end

    test "valid params", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game_params())

      assert %{"id" => _} = json_response(conn, 201)
    end

    test "invalid params", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), %{"bad" => "params"})

      assert %{"errors" => _} = json_response(conn, 422)
    end
  end
end
