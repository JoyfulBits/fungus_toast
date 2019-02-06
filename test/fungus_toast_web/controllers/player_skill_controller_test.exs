defmodule FungusToastWeb.PlayerSkillControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.{Accounts, Games}
  alias FungusToast.Games.PlayerSkill

  @create_attrs %{
    skill_level: 1
  }
  @update_attrs %{
    skill_level: 3
  }
  @invalid_attrs %{skill_level: nil}

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

  defp create_player_skill(_) do
    fixture(:user)
    game = fixture(:game) |> FungusToast.Repo.preload(:players)
    skill = fixture(:skill)
    player = List.first(game.players)
    player_skill = fixture(:player_skill, player, skill)

    {:ok, game: game, player: player, player_skill: player_skill}
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
    setup [:create_player_skill]

    test "renders skill when data is valid", %{conn: conn, game: game, player: player, player_skill: %PlayerSkill{id: id} = skill} do
      conn = put(conn, Routes.game_player_skill_path(conn, :update, game, player, skill), player_skill: @update_attrs)
      assert %{
               "id" => ^id,
               "skillLevel" => 3
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, game: game, player: player, player_skill: skill} do
      conn = put(conn, Routes.game_player_skill_path(conn, :update, game, player, skill), player_skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
