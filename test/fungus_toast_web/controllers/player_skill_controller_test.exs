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
    Games.create_game("testUser", %{number_of_human_players: 1})
  end

  def fixture(:skill) do
    {:ok, skill} =
      Games.create_skill(%{name: "Skill", description: "Description", increase_per_point: 1})

    skill
  end

  def fixture(:player_skill, player, skill) do
    {:ok, player_skill} = Games.create_player_skill(player, skill, @create_attrs)
    player_skill
  end

  def fixture(:skill_params, skill, points_spent) do
    %{
      "skill_upgrades" => [
        %{"id" => skill.id, "points_spent" => points_spent}
      ]
    }
  end

  defp create_game_player(_) do
    fixture(:user)
    game = fixture(:game) |> FungusToast.Repo.preload(:players)
    player = List.first(game.players)

    {:ok, game: game, player: player}
  end

  describe "GET" do
    setup [:create_game_player]

    test "lists all skills", %{conn: conn, game: game, player: player} do
      conn = get(conn, Routes.game_player_skill_path(conn, :index, game, player))
      assert json_response(conn, 200) != []
    end
  end
end
