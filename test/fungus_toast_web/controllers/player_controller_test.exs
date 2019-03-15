defmodule FungusToastWeb.PlayerControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Games.{Game, Player}

  @user_name "testUser"

  @create_attrs %{
    human: true,
    name: @user_name,
    user_name: @user_name
  }
  @invalid_attrs %{human: nil}

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{user_name: @user_name, number_of_human_players: 1})
    game
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: @user_name, active: true})
    user
  end

  def fixture(:player, game) do
    {:ok, player} = Games.create_player(game, @create_attrs)
    player
  end

  defp create_game(_) do
    fixture(:user)
    game = fixture(:game)
    {:ok, game: game}
  end

  defp create_player(_) do
    fixture(:user)
    game = fixture(:game)
    player = fixture(:player, game)
    {:ok, game: game, player: player}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET" do
    setup [:create_player]

    test "lists all players", %{conn: conn, game: %Game{id: game_id}} do
      conn = get(conn, Routes.game_player_path(conn, :index, game_id))
      assert json_response(conn, 200)
    end

    test "lists players for the specified game", %{
      conn: conn,
      game: %Game{id: game_id},
      player: %Player{id: id}
    } do
      conn = get(conn, Routes.game_player_path(conn, :show, game_id, id))

      assert %{
               "id" => id,
               "name" => "testUser",
               "human" => true
             } = json_response(conn, 200)
    end
  end

  describe "POST" do
    setup [:create_game]

    test "renders player when data is valid", %{conn: conn, game: %Game{id: game_id}} do
      conn = post(conn, Routes.game_player_path(conn, :create, game_id), player: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.game_player_path(conn, :show, game_id, id))

      assert %{
               "id" => id,
               "human" => true
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, game: %Game{id: game_id}} do
      conn = post(conn, Routes.game_player_path(conn, :create, game_id), player: @invalid_attrs)
      assert "Bad Request" = json_response(conn, 400)
    end
  end
end
