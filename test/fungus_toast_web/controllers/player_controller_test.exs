defmodule FungusToastWeb.PlayerControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Players
  alias FungusToast.Players.Player

  @create_attrs %{
    active: true,
    human: true,
    user_name: "some user_name"
  }
  @update_attrs %{
    active: false,
    human: false,
    user_name: "some updated user_name"
  }
  @invalid_attrs %{active: nil, human: nil, user_name: nil}

  def fixture(:player) do
    {:ok, player} = Players.create_player(@create_attrs)
    player
  end

  defp create_player(_) do
    player = fixture(:player)
    {:ok, player: player}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all players", %{conn: conn} do
      conn = get(conn, Routes.player_path(conn, :index))
      assert json_response(conn, 200)
    end
  end

  describe "create player" do
    test "renders player when data is valid", %{conn: conn} do
      conn = post(conn, Routes.player_path(conn, :create), player: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.player_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => true,
               "human" => true,
                # TODO: Find a way to snake case this
               "userName" => "some user_name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.player_path(conn, :create), player: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update player" do
    setup [:create_player]

    test "renders player when data is valid", %{conn: conn, player: %Player{id: id} = player} do
      conn = put(conn, Routes.player_path(conn, :update, player), player: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.player_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => false,
               "human" => false,
                # TODO: Find a way to snake case this
               "userName" => "some updated user_name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, player: player} do
      conn = put(conn, Routes.player_path(conn, :update, player), player: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete player" do
    setup [:create_player]

    test "deactivates chosen player", %{conn: conn, player: player} do
      conn = delete(conn, Routes.player_path(conn, :delete, player))

      assert %{
               "id" => id,
               "active" => false,
             } = json_response(conn, 200)
    end
  end

end
