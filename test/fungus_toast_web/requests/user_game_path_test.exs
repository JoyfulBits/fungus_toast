defmodule FungusToastWeb.Requests.UserGamePathTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: "testUser", active: true})
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  describe "GET  /api/users/:user_id/games " do
    setup [:create_user]

    test "a successful request", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_game_path(conn, :index, user))

      assert [] = json_response(conn, 200)
    end
  end
end
