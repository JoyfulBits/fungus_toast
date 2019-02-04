defmodule FungusToast.PlayersTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Players

  describe "players" do
    alias FungusToast.Players.Player

    @valid_attrs %{human: true}
    @update_attrs %{human: false}
    @invalid_attrs %{human: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{active: true, user_name: "some user_name"})
        |> Accounts.create_user()

      user
    end

    def player_fixture(attrs \\ %{}) do
      user = user_fixture()
      adjusted_attrs = attrs
                       |> Enum.into(@valid_attrs)

      {:ok, player} = Players.create_player(user, adjusted_attrs)
      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Players.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player!(player.id) == player
    end

    test "create_player/1 with valid data and a %User{} creates a player" do
      user = user_fixture()
      assert {:ok, %Player{} = player} = Players.create_player(user, @valid_attrs)
      player = player |> Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with valid data and a user ID creates a player" do
      user = user_fixture()
      assert {:ok, %Player{} = player} = Players.create_player(user.id, @valid_attrs)
      # TODO: find a better place to do this
      player = player |> FungusToast.Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.create_player(user, @invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Players.update_player(player, @update_attrs)
      assert player.human == false
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Players.change_player(player)
    end
  end
end
