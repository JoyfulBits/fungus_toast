defmodule FungusToastWeb.RoundControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Games
  alias FungusToast.Games.{Game, Round}

  @create_attrs %{
    game_state: %{},
    state_change: %{}
  }
  @invalid_attrs %{game_state: nil, state_change: nil}

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{number_of_human_players: 2})
    game
  end

  def fixture(:round, game_id) do
    {:ok, round} = Games.create_round(game_id, @create_attrs)
    round
  end

  defp create_round(_) do
    game = fixture(:game)
    round = fixture(:round, game.id)
    {:ok, game: game, round: round}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET" do
    setup [:create_round]

    test "renders round when data is valid", %{conn: conn, game: %Game{id: game_id}, round: %Round{id: id}} do
      conn = get(conn, Routes.game_round_path(conn, :show, game_id, id))
      assert %{"id" => id, "gameId" => game_id, "gameState" => %{}, "stateChange" => %{}} = json_response(conn, 200)
      # Why aren't we using the SnakeCase formatter here?
      # assert %{"id" => id, "game_id" => game_id, "game_state" => %{}, "state_change" => %{}} = json_response(conn, 200)
    end
  end

  describe "POST" do
    test "renders errors when data is invalid", %{conn: conn} do
      game = fixture(:game)
      conn = post(conn, Routes.game_round_path(conn, :create, game.id), round: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

end