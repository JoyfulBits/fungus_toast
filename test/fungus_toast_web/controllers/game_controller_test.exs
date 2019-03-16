defmodule FungusToastWeb.GameControllerTest do
  use FungusToastWeb.ConnCase
  alias FungusToast.Games.Game


  describe "GET" do
    test "renders game when data is valid", %{conn: conn} do
      %Game{id: id} = Fixtures.Game.create!()

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
        "grid_size" => 50
      }
    end

    test "valid params", %{conn: conn} do
      Fixtures.Accounts.User.create!()
      
      conn = post(conn, Routes.game_path(conn, :create), game_params())

      assert %{"id" => _} = json_response(conn, 201)
    end

    test "invalid params", %{conn: conn} do
      assert_raise Phoenix.ActionClauseError, fn ->
        conn = post(conn, Routes.game_path(conn, :create), %{"bad" => "params"})
        assert "Bad Request" = json_response(conn, 400)
      end
    end

    test "case transformation", %{conn: conn} do
      Fixtures.Accounts.User.create!()

      params = %{
        "userName" => "testUser",
        "numberOfHumanPlayers" => 2
      }

      conn = post(conn, Routes.game_path(conn, :create), params)

      assert %{
               "id" => id
             } = json_response(conn, 201)

      assert %Game{id: id, number_of_human_players: 2} = FungusToast.Games.get_game!(id)
    end
  end
end
