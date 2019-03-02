defmodule FungusToastWeb.Requests.UserGamePathTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts
  alias FungusToast.Accounts.User

  describe "GET  /api/users/:user_id/games " do

    test "a successful request", %{conn: conn} do
      conn = get(conn, Routes.user_game_path(conn, :index, "foo"))

      assert %{} = json_response(conn, 200)
    end
  end
end
