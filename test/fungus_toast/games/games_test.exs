defmodule FungusToast.GamesTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Games

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{"user_name" => "testUser"})
      |> Accounts.create_user()

    user
  end

  def game_fixture(attrs \\ %{}) do
    user_fixture()
    {:ok, game} =
      attrs
      |> Enum.into(%{"user_name" => "testUser", "number_of_human_players" => 1})
      |> Games.create_game()

    # Reload the game to pick up the new Player association
    Games.get_game!(game.id)
  end

  def create_test_user(_) do
    user_fixture()
  end

  describe "games" do
    alias FungusToast.Games.Game

    # TODO: Evaluate if this is the best way to do this
    @valid_attrs %{"user_name" => "testUser", "number_of_human_players" => 1}
    @update_attrs %{active: true}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      user_fixture()
      assert {:ok, %Game{} = game} = Games.create_game(@valid_attrs)
      game = game |> FungusToast.Repo.preload(:players)
      assert length(game.players) == 1
    end

    test "create_game/1 with invalid data does not create a game" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Games.create_game()
    end

    test "create_game/1 with invalid status does not create a game" do
      assert {:error, %Ecto.Changeset{valid?: false}} =
               Games.create_game(%{status: "Nope", number_of_human_players: 2})
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = Games.update_game(game, @update_attrs)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end

  describe "rounds" do
    alias FungusToast.Games.Round

    @valid_attrs %{game_state: %{"hello" => "world"}, state_change: %{"hello" => "world"}}
    @invalid_attrs %{game_state: nil, state_change: nil}

    def round_fixture(game_id, attrs \\ %{}) do
      adjusted_attrs = attrs
                       |> Enum.into(@valid_attrs)
      {:ok, round} = Games.create_round(game_id, adjusted_attrs)

      round
    end

    test "get_round!/1 returns the round with given id" do
      game = game_fixture()
      round = round_fixture(game.id)
      assert Games.get_round!(round.id) == round
    end

    test "create_round/2 with valid data creates a round" do
      game = game_fixture()
      assert {:ok, %Round{} = round} = Games.create_round(game.id, @valid_attrs)
      assert round.game_state == %{"hello" => "world"}
      assert round.state_change == %{"hello" => "world"}
    end

    test "create_round/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.create_round(game.id, @invalid_attrs)
    end

    test "list_rounds_for_game/1 returns rounds for the specified game" do
      game1 = game_fixture()
      game2 = game_fixture()
      round1 = round_fixture(game1.id, %{game_state: %{"hello" => "world"}, state_change: %{}})
      _round2 = round_fixture(game2.id, %{game_state: %{}, state_change: %{}})

      assert Games.list_rounds_for_game(game1.id) == [round1]
    end

    test "get_round_for_game!/2 returns the round with the given round number for the specified game" do
      game = game_fixture()
      _round1 = round_fixture(game.id, %{game_state: %{}, state_change: %{}, number: 1})
      round2 = round_fixture(game.id, %{game_state: %{"hello" => "world"}, state_change: %{"hello" => "world"}, number: 2})

      assert Games.get_round_for_game!(game.id, 2) == round2
    end
  end
end
