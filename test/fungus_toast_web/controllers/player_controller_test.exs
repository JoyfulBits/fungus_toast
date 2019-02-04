defmodule FungusToastWeb.PlayerControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts
  alias FungusToast.Players

  @create_attrs %{
    human: true
  }
  @invalid_attrs %{human: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: "some user_name", active: true})
    user
  end

  def fixture(:player, user) do
    {:ok, player} = Players.create_player(user, @create_attrs)
    player
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # TODO: scope /players to list all players, /user/:user_id/players to get all players for user
  # describe "GET" do
  #   test "lists all players", %{conn: conn} do
  #     conn = get(conn, Routes.player_path(conn, :index))
  #     assert json_response(conn, 200)
  #   end
  # end

  describe "POST" do
    test "renders player when data is valid", %{conn: conn} do
      user = fixture(:user)
      conn = post(conn, Routes.player_path(conn, :create), user_id: user.id, player: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.player_path(conn, :show, id))

      assert %{
               "id" => id,
               "human" => true
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = fixture(:user)
      conn = post(conn, Routes.player_path(conn, :create), user_id: user.id, player: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
