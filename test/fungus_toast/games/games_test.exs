defmodule FungusToast.GamesTest do
  use FungusToast.DataCase

  alias FungusToast.Accounts
  alias FungusToast.Games
  alias FungusToast.Players
  alias FungusToast.Games.Player

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{user_name: "testUser"})
      |> Accounts.create_user()

    user
  end

  @doc """
    Creates a game with a human player for that user, as well as any AI players
  """
  defp game_fixture(attrs \\ %{number_of_human_players: 1}) do
    {:ok, game} = Games.create_game("testUser", attrs)
    
    game
  end

  @doc """
    creates a human player with a user
  """
  defp human_player_with_user_fixture(user_name, game, mutation_points \\ 0) do
    {:ok, player} = Players.create_player_for_user(game, user_name)
    Players.update_player(player, %{mutation_points: mutation_points})
  end

  @doc """
    creates a human player without a user
  """
  defp human_player_without_user_fixture(game, mutation_points \\ 0) do
    %Player{game_id: game.id, human: true, mutation_points: mutation_points}
      |> Player.changeset(%{})
      |> Repo.insert()
  end

  @doc """
    Creates an AI player for the specified game with the specified number of mutation points
  """
  defp ai_player_fixture(game, mutation_points \\ 0) do
    %Player{game_id: game.id, human: false, mutation_points: mutation_points}
      |> Player.changeset(%{})
      |> Repo.insert()
  end

  defp create_ai_player(game_id) do
    %Player{game_id: game.id, human: false}
    |> Player.changeset(%{})
    |> Repo.insert()
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

    test "create_game/2 with valid data creates a game" do
      user = Fixtures.Accounts.User.create!()
      valid_attrs = %{number_of_human_players: 1, number_of_ai_players: 2}

      assert {:ok, %Game{} = game} = Games.create_game(user.user_name, valid_attrs)
      
      assert game.number_of_human_players == 1
      assert game.number_of_ai_players == 2
      assert length(game.players) == 3
    end

    test "create_game/2 with missing data does not create a game" do
      assert catch_error Games.create_game("some user name", %{})
    end

    test "create_game/2 with invalid status does not create a game" do
      assert catch_error Games.create_game("some user name", %{status: "Nope", number_of_human_players: 2})
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
        game_fixture(%{number_of_human_players: 1, number_of_ai_players: 1})
        |> Games.preload_for_games()

      human_player = Enum.filter(game.players, fn p -> p.human end)
        |> hd

      Players.update_player(human_player, %{mutation_points: 1})

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns true if there is one human player and they have spent their points" do
      game =
        game_fixture(%{number_of_human_players: 1, number_of_ai_players: 1})
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
      game = game_fixture(%{number_of_human_players: 2, number_of_ai_players: 1})
      human_player_with_user_fixture(user.user_name, game, 1)
      game = Games.get_game!(game.id) |> Games.preload_for_games()

      game =
        Games.get_game!(game.id)
        |> Games.preload_for_games()

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns false if at least one ai player has unspent points" do
      user = user_fixture(%{user_name: "someOtherUser"})
      game = game_fixture(%{number_of_human_players: 1, number_of_ai_players: 0})
      ai_player_fixture(game, 1)
      game = Games.get_game!(game.id) |> Games.preload_for_games()

      game =
        Games.get_game!(game.id)
        |> Games.preload_for_games()

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns true if all players have spent their points" do
      user = user_fixture(%{user_name: "another user"})
      
      game =
        game_fixture(%{number_of_human_players: 2, number_of_ai_players: 1})

      human_player_with_user_fixture(user.user_name, game, 0)
      human_player_without_user_fixture(game)
      ai_player_fixture(game)
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
