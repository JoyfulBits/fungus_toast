defmodule FungusToastWeb.GameControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Games.Game

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: "testUser", active: true})
    user
  end

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{user_name: "testUser", number_of_human_players: 2})
    game
  end

  defp create_game(_) do
    fixture(:user)
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

      assert %{"id" => id} = json_response(conn, 200)
    end
  end

  describe "POST" do
    def game_params() do
      %{
        "user_name" => "testUser",
        "number_of_human_players" => 2,
        "number_of_ai_players" => 2,
        "number_of_columns" => 100,
        "number_of_rows" => 100
      }
    end

    test "valid params", %{conn: conn} do
      fixture(:user)
      conn = post(conn, Routes.game_path(conn, :create), game_params())

      assert %{"id" => _} = json_response(conn, 201)
    end

    test "invalid params", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), %{"bad" => "params"})

      assert %{"errors" => _} = json_response(conn, 422)
    end

    test "case transformation", %{conn: conn} do
      fixture(:user)

      params = %{
        "userName" => "testUser",
        "numberOfHumanPlayers" => 2
      }

      conn = post(conn, Routes.game_path(conn, :create), params)

      assert %{
               "id" => id
             } = json_response(conn, 201)

      assert %Games.Game{id: id, number_of_human_players: 2} =
               Games.get_game!(id)
    end
  end
end
