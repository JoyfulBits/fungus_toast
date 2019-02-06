defmodule FungusToast.PlayerSkillsTest do
  use FungusToast.DataCase

  alias FungusToast.{Accounts, Games}

  describe "player_skills" do
    alias FungusToast.Games.PlayerSkill

    @valid_attrs %{skill_level: 1}
    @update_attrs %{skill_level: 3}
    @invalid_attrs %{skill_level: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(%{user_name: "testUser", number_of_human_players: 1})
        |> Games.create_game()

      game |> FungusToast.Repo.preload(:players)
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{active: true, user_name: "testUser"})
        |> Accounts.create_user()

      user
    end

    def skill_fixture(attrs \\ %{}) do
      {:ok, skill} =
        attrs
        |> Enum.into(%{name: "Skill", description: "Description", increase_per_point: 1})
        |> Games.create_skill()

      skill
    end

    def player_skill_fixture(game, skill, attrs \\ %{}) do
      player = List.first(game.players)

      adjusted_attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, player_skill} = Games.create_player_skill(player, skill, adjusted_attrs)
      player_skill
    end

    test "get_player_skills/1 returns the skills with for the given player" do
      user_fixture()
      game = game_fixture()
      skill = skill_fixture()
      player_skill = player_skill_fixture(game, skill)
      player = List.first(game.players)
      assert Games.get_player_skills(player) == [player_skill]
    end

    test "create_player_skill/1 with valid data creates a skill" do
      user_fixture()
      game = game_fixture()
      skill = skill_fixture()
      player = List.first(game.players)
      assert {:ok, %PlayerSkill{} = player_skill} = Games.create_player_skill(player, skill, @valid_attrs)
      assert player_skill.skill_level == 1
    end

    test "create_player_skill/1 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      skill = skill_fixture()
      player = List.first(game.players)
      assert {:error, %Ecto.Changeset{}} = Games.create_player_skill(player, skill, @invalid_attrs)
    end

    test "update_player_skill/2 with valid data updates the skill" do
      user_fixture()
      game = game_fixture()
      skill = skill_fixture()
      player_skill = player_skill_fixture(game, skill)
      assert {:ok, %PlayerSkill{} = player_skill} = Games.update_player_skill(player_skill, @update_attrs)
      assert player_skill.skill_level == 3
    end

    test "update_player_skill/2 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      skill = skill_fixture()
      player_skill = player_skill_fixture(game, skill)
      player = List.first(game.players)
      assert {:error, %Ecto.Changeset{}} = Games.update_player_skill(player_skill, @invalid_attrs)
      assert [player_skill] == Games.get_player_skills(player)
    end
  end
end
