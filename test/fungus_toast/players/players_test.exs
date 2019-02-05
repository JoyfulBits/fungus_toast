defmodule FungusToast.PlayersTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Players

  describe "players" do
    alias FungusToast.Players.Player

    @valid_attrs %{human: true, name: "testUser"}
    @update_attrs %{human: false}
    @invalid_attrs %{human: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(%{user_name: "testUser", number_of_human_players: 1})
        |> Games.create_game()

      game
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{active: true, user_name: "testUser"})
        |> Accounts.create_user()

      user
    end

    def player_fixture(attrs \\ %{}) do
      user = user_fixture()
      game = game_fixture()
      adjusted_attrs = attrs
                       |> Enum.into(@valid_attrs)

      {:ok, player} = Players.create_player(game, user, adjusted_attrs)
      player
    end

    test "list_players/0 returns all players" do
      # Creating a game always creates a player from the supplied user
      user_fixture()
      game = game_fixture() |> FungusToast.Repo.preload(:players)
      assert Players.list_players() == game.players
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player!(player.id) == player
    end

    test "create_player/1 with valid data and a %Game{} and %User{} creates a player" do
      user = user_fixture()
      game = game_fixture()
      assert {:ok, %Player{} = player} = Players.create_player(game, user, @valid_attrs)
      player = player |> Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with valid data and a game ID and user ID creates a player" do
      user = user_fixture()
      game = game_fixture()
      assert {:ok, %Player{} = player} = Players.create_player(game.id, user.id, @valid_attrs)
      # TODO: find a better place to do this
      player = player |> FungusToast.Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with invalid data returns error changeset" do
      user = user_fixture()
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.create_player(game, user, @invalid_attrs)
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
