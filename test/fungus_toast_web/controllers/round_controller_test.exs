defmodule FungusToastWeb.RoundControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Games.{Game, Round}

  @create_attrs %{
    starting_game_state: %{},
    state_change: %{}
  }
  @invalid_attrs %{starting_game_state: nil, state_change: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: "testUser", active: true})
    user
  end

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{user_name: "testUser", number_of_human_players: 2})
    game
  end

  def fixture(:round, game) do
    {:ok, round} = Games.create_round(game, @create_attrs)
    round
  end

  defp create_game(_) do
    fixture(:user)
    game = fixture(:game)
    {:ok, game: game}
  end

  defp create_round(_) do
    fixture(:user)
    game = fixture(:game)
    round = fixture(:round, game)
    {:ok, game: game, round: round}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET" do
    setup [:create_round]

    test "renders round when data is valid", %{
      conn: conn,
      game: %Game{id: game_id},
      round: %Round{id: id}
    } do
      conn = get(conn, Routes.game_round_path(conn, :show, game_id, id))

      assert %{"id" => id, "gameId" => game_id, "startingGameState" => %{}, "stateChange" => %{}} =
               json_response(conn, 200)
    end
  end

  describe "POST" do
    setup [:create_game]

    test "renders round when data is valid", %{conn: conn, game: %Game{id: game_id}} do
      conn = post(conn, Routes.game_round_path(conn, :create, game_id), round: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.game_round_path(conn, :show, game_id, id))

      assert %{
               "id" => id,
               "gameId" => game_id,
               "startingGameState" => %{},
               "stateChange" => %{}
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, game: %Game{id: game_id}} do
      conn = post(conn, Routes.game_round_path(conn, :create, game_id), round: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
