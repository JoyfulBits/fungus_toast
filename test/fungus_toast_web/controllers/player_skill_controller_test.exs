defmodule FungusToastWeb.PlayerSkillControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.{Accounts, Games}

  @create_attrs %{
    skill_level: 1
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(%{user_name: "testUser", active: true})
    user
  end

  def fixture(:game) do
    {:ok, game} = Games.create_game(%{user_name: "testUser", number_of_human_players: 1})
    game
  end

  def fixture(:skill) do
    {:ok, skill} = Games.create_skill(%{name: "Skill", description: "Description", increase_per_point: 1})
    skill
  end

  def fixture(:player_skill, player, skill) do
    {:ok, player_skill} = Games.create_player_skill(player, skill, @create_attrs)
    player_skill
  end

  defp create_game_player(_) do
    fixture(:user)
    game = fixture(:game) |> FungusToast.Repo.preload(:players)
    player = List.first(game.players)

    {:ok, game: game, player: player}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET" do
    setup [:create_game_player]

    test "lists all skills", %{conn: conn, game: game, player: player} do
      conn = get(conn, Routes.game_player_skill_path(conn, :index, game, player))
      assert json_response(conn, 200) == []
    end
  end

  describe "POST" do
    setup [:create_game_player]

    test "renders player skills when data is valid", %{conn: conn, game: game, player: player} do
      skill_id = fixture(:skill).id
      skill_params = %{
                        "skill_upgrades" => [
                          %{"id" => skill_id, "points_spent" => 1}
                        ]
                      }
      conn = post(conn, Routes.game_player_skill_path(conn, :update, game, player), skill_params)
      player_skill = List.first(json_response(conn, 200))
      assert %{
        "skillId" => skill_id,
        "skillLevel" => 1
      } = player_skill
    end

    test "renders errors when data is invalid", %{conn: conn, game: game, player: player} do
      bad_attrs = %{
        "skill_upgrades" => [
          %{"id" => 3, "points_spent" => -1}
        ]
      }

      conn = post(conn, Routes.game_player_skill_path(conn, :update, game, player), bad_attrs)
      assert "Bad Request" = json_response(conn, 400)
    end
  end
end
