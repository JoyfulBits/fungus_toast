defmodule FungusToast.PlayersTest do
  use FungusToast.DataCase

  alias FungusToast.Players

  describe "players" do
    alias FungusToast.Players.Player

    @valid_attrs %{active: true, human: true, user_name: "some user_name"}
    @update_attrs %{active: false, human: false, user_name: "some updated user_name"}
    @invalid_attrs %{active: nil, human: nil, user_name: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Players.create_player()

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

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Players.create_player(@valid_attrs)
      assert player.active == true
      assert player.human == true
      assert player.user_name == "some user_name"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Players.update_player(player, @update_attrs)
      assert player.active == false
      assert player.human == false
      assert player.user_name == "some updated user_name"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end

    test "delete_player/1 deactivates the player" do
      player = player_fixture()
      assert {:ok, player} = Players.delete_player(player)
      refute player.active
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Players.change_player(player)
    end
  end
end
