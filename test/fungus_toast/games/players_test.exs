defmodule FungusToast.PlayersTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Games

  describe "players" do
    alias FungusToast.Games.Player

    @valid_attrs %{human: true, name: "testUser", user_name: "testUser"}
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

    def player_fixture(game, attrs \\ %{}) do
      adjusted_attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, player} = Games.create_player(game, adjusted_attrs)
      player
    end

    test "list_players/0 returns all players" do
      # Creating a game always creates a player from the supplied user
      user_fixture()
      game = game_fixture() |> FungusToast.Repo.preload(:players)
      assert Games.list_players() == game.players
    end

    test "get_player!/1 returns the player with given id" do
      user_fixture()
      game = game_fixture()
      player = player_fixture(game)
      assert Games.get_player!(player.id) == player
    end

    test "create_player/1 with valid data and a %Game{} and %User{} creates a player" do
      user = user_fixture()
      game = game_fixture()
      assert {:ok, %Player{} = player} = Games.create_player(game, @valid_attrs)
      player = player |> Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with valid data and a game ID and user ID creates a player" do
      user = user_fixture()
      game = game_fixture()
      assert {:ok, %Player{} = player} = Games.create_player(game.id, @valid_attrs)
      # TODO: find a better place to do this
      player = player |> FungusToast.Repo.preload(:user)
      assert player.human == true
      assert player.user == user
    end

    test "create_player/1 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      assert {:error, :bad_request} = Games.create_player(game, @invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      user_fixture()
      game = game_fixture()
      player = player_fixture(game)
      assert {:ok, %Player{} = player} = Games.update_player(player, @update_attrs)
      assert player.human == false
    end

    test "update_player/2 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      player = player_fixture(game)
      assert {:error, %Ecto.Changeset{}} = Games.update_player(player, @invalid_attrs)
      assert player == Games.get_player!(player.id)
    end

    test "change_player/1 returns a player changeset" do
      user_fixture()
      game = game_fixture()
      player = player_fixture(game)
      assert %Ecto.Changeset{} = Games.change_player(player)
    end
  end
end
