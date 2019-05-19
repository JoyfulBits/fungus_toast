defmodule FungusToastWeb.JoinedGameControllerTest do
  use FungusToastWeb.ConnCase
  alias FungusToast.Games

  describe "POST" do
    test "that it returns a 200 OK with joined but not started status if there were multiple slots available and the user joined the game", %{conn: conn} do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 3})

      user2 = Fixtures.Accounts.User.create!(%{user_name: "testUser2", active: true})
      m = %{"game_id" => game.id, "user_name" => user2.user_name}
      conn = post(conn, Routes.joined_game_path(conn, :create), m)

      assert %{"resultType" => 1} = json_response(conn, 200)
    end

    test "that it returns a 200 OK with joined/started status if there was only one slot available and the user joined the game", %{conn: conn} do
      user = Fixtures.Accounts.User.create!()
      user2 = Fixtures.Accounts.User.create!(%{user_name: "testUser2", active: true})
      game = Games.create_game(user.user_name, %{number_of_human_players: 2})

      m = %{"game_id" => game.id, "user_name" => user2.user_name}
      conn = post(conn, Routes.joined_game_path(conn, :create), m)

      assert %{"resultType" => 2} = json_response(conn, 200)
    end

    test "that it returns a 409 conflict if there are no open slots", %{conn: conn} do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})

      m = %{"game_id" => game.id, "user_name" => "anything"}
      conn = post(conn, Routes.joined_game_path(conn, :create), m)

      assert %{"resultType" => 3} = json_response(conn, 409)
    end

    test "that it returns a 400 bad request if a user is trying to join a game they are already in", %{conn: conn} do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 2})

      m = %{"game_id" => game.id, "user_name" => user.user_name}
      conn = post(conn, Routes.joined_game_path(conn, :create), m)

      assert %{"resultType" => 4} = json_response(conn, 400)
    end

    test "invalid params", %{conn: conn} do
      assert_raise Phoenix.ActionClauseError, fn ->
        conn = post(conn, Routes.joined_game_path(conn, :create), %{"bad" => "params"})
        assert "Bad Request" = json_response(conn, 400)
      end
    end

    # test "case transformation", %{conn: conn} do
    #   Fixtures.Accounts.User.create!()

    #   params = %{
    #     "userName" => "testUser",
    #     "numberOfHumanPlayers" => 2
    #   }

    #   conn = post(conn, Routes.game_path(conn, :create), params)

    #   assert %{
    #            "id" => id
    #          } = json_response(conn, 201)

    #   assert %Game{id: id, number_of_human_players: 2} = FungusToast.Games.get_game!(id)
    # end
  end
end
