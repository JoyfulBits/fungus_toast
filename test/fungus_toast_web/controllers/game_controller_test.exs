defmodule FungusToastWeb.GameControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Games
  alias FungusToast.Games.Game

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{})
    game
  end

  defp create_game(_) do
    game = fixture(:game)
    {:ok, game: game}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET active game details" do
    setup [:create_game]

    test "renders game when data is valid", %{conn: conn, game: %Game{id: id}} do
      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{ "id" => id } = json_response(conn, 200)
    end
  end
end
