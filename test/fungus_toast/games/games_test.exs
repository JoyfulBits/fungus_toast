defmodule FungusToast.GamesTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Players

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{user_name: "testUser"})
      |> Accounts.create_user()

    user
  end

  defp game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{user_name: "testUser", number_of_human_players: 1})
      |> Games.create_game()

    game
  end

  defp player_fixture(user, game, attrs \\ %{}) do
    updated_attrs =
      attrs
      |> Enum.into(%{human: true, user_name: user.user_name, name: user.user_name})

    {:ok, player} = Players.create_player(game, updated_attrs)
    player
  end

  defp create_users(count), do: create_users(count, [])

  defp create_users(count, accum) when count > 0 do
    user = user_fixture(%{user_name: "testUsers #{count}"})
    create_users(count - 1, [user | accum])
  end

  defp create_users(0, accum) do
    accum
  end

  defp create_players(users, game) when is_list(users), do: create_players(users, game, [])
  defp create_players(users, game) when not is_nil(users), do: create_players([users], game, [])

  defp create_players([head | tail], game, accum) do
    player = player_fixture(head, game)
    create_players(tail, game, [player | accum])
  end

  defp create_players([], _, accum) do
    accum
  end

  describe "games" do
    alias FungusToast.Games.Game

    # TODO: Evaluate if this is the best way to do this
    @valid_attrs %{user_name: "testUser", number_of_human_players: 1, number_of_ai_players: 2}
    @update_attrs %{active: true}

    test "list_games/0 returns all games" do
      game = Fixtures.Game.create!
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = Fixtures.Game.create!
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      user = Fixtures.Accounts.User.create!()
      valid_attrs = %{user_name: user.user_name, number_of_human_players: 1, number_of_ai_players: 2}

      assert {:ok, %Game{} = game} = Games.create_game(valid_attrs)
      assert length(game.players) == 1
      assert game.number_of_ai_players == 2
    end

    test "create_game/1 with invalid data does not create a game" do
      assert {:error, :bad_request} = Games.create_game()
    end

    test "create_game/1 with invalid status does not create a game" do
      assert {:error, :bad_request} =
               Games.create_game(%{status: "Nope", number_of_human_players: 2})
    end

    test "update_game/2 with valid data updates the game" do
      user_fixture()
      game = game_fixture()
      assert {:ok, %Game{} = game} = Games.update_game(game, @update_attrs)
    end

    test "delete_game/1 deletes the game" do
      user_fixture()
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      user_fixture()
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end

  describe "create_game_for_user" do
    alias FungusToast.Games
    alias FungusToast.Games.Game

    test "that it creates a game with a single player for the current user populated" do
      user = user_fixture()
      cs = Game.changeset(%Game{}, %{number_of_human_players: 1})
      {:ok, game} = Games.create_game_for_user(cs, user.user_name)
      assert [player | _] = game.players
    end
  end
  
  describe "rounds" do
    alias FungusToast.Games.Round

    @valid_attrs %{starting_game_state: %{"hello" => "world"}, state_change: %{"hello" => "world"}}
    @invalid_attrs %{starting_game_state: nil, state_change: nil}

    def round_fixture(game_id, attrs \\ %{}) do
      adjusted_attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, round} = Games.create_round(game_id, adjusted_attrs)

      round
    end

    # TODO: Revisit this test setup
    #test "get_round!/1 returns the round with given id" do
    #  user_fixture()
    #  game = game_fixture()
    #  round = round_fixture(game.id)
    #  assert Games.get_round!(round.id) == round
    #end

    test "create_round/2 with valid data creates a round" do
      user_fixture()
      game = game_fixture()
      assert {:ok, %Round{} = round} = Games.create_round(game.id, @valid_attrs)
      assert round.starting_game_state == %{"hello" => "world"}
      assert round.state_change == %{"hello" => "world"}
    end

    test "create_round/2 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.create_round(game.id, @invalid_attrs)
    end
  end

  describe "next round" do
    setup do
      user_fixture(%{user_name: "Fungusmotron"})
      user_fixture()
      :ok
    end

    test "next_round_available/1 returns false if there is one human player and they have points to spend" do
      game =
        game_fixture(%{number_of_ai_players: Enum.random(1..3)})
        |> Games.preload_for_games()

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns true if there is one human player and they have spent their points" do
      game =
        game_fixture(%{number_of_ai_players: Enum.random(1..3)})
        |> Games.preload_for_games()

      {:ok, _player} =
        game.players
        |> Enum.filter(fn p -> p.human end)
        |> List.first()
        |> Games.update_player(%{mutation_points: 0})

      game =
        Games.get_game!(game.id)
        |> Games.preload_for_games()

      assert Games.next_round_available?(game)
    end

    test "next_round_available/1 returns false if at least one human player has unspent points" do
      user = user_fixture(%{user_name: "someOtherUser"})
      game = game_fixture(%{number_of_human_players: 2, number_of_ai_players: Enum.random(1..2)})
      player_fixture(user, game)
      game = Games.get_game!(game.id) |> Games.preload_for_games()

      {:ok, _player} =
        game.players
        |> Enum.filter(fn p -> p.human end)
        |> List.first()
        |> Games.update_player(%{mutation_points: 0})

      game =
        Games.get_game!(game.id)
        |> Games.preload_for_games()

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns true if all human players have spent their points" do
      # Generate 1-3 more players alongside the existing testUser
      human_players = Enum.random(1..3)
      # Fill the game with up to 2 more AI players
      ai_players = Enum.random(0..(3 - human_players))

      users = create_users(human_players)

      game =
        game_fixture(%{number_of_human_players: human_players, number_of_ai_players: ai_players})

      create_players(users, game)
      game = Games.get_game!(game.id) |> Games.preload_for_games()

      game.players
      |> Enum.filter(fn p -> p.human end)
      |> Enum.map(fn p -> p |> Games.update_player(%{mutation_points: 0}) end)

      game =
        Games.get_game!(game.id)
        |> Games.preload_for_games()

      assert Games.next_round_available?(game)
    end
  end
end
