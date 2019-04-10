defmodule FungusToast.GamesTest do
  use FungusToast.DataCase

  alias FungusToast.{Accounts, Games, Players, Rounds}
  alias FungusToast.Games.{Game, GameState, Player, GridCell}

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{user_name: "testUser"})
      |> Accounts.create_user()

    user
  end

  #Creates a game with a human player for that user, as well as any AI players
  defp game_fixture(attrs \\ %{number_of_human_players: 1}) do
    Games.create_game("testUser", attrs)
  end

  #creates a human player with a user
  defp human_player_with_user_fixture(user_name, game, mutation_points) do
    Players.create_player_for_user(game, user_name)
    |> Players.update_player(%{mutation_points: mutation_points})
  end

  #creates a human player without a user
  defp human_player_without_user_fixture(game, mutation_points \\ 0) do
    %Player{game_id: game.id, human: true, mutation_points: mutation_points}
      |> Player.changeset(%{})
      |> Repo.insert()
  end

  #Creates an AI player for the specified game with the specified number of mutation points
  defp ai_player_fixture(game, mutation_points \\ 0) do
    %Player{game_id: game.id, human: false, mutation_points: mutation_points}
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
      %Game{id: id} = Fixtures.Game.create!
      assert %{id: id} = Games.get_game!(id)
    end

    test "create_game/2 with valid data creates a game" do
      user = Fixtures.Accounts.User.create!()
      valid_attrs = %{number_of_human_players: 1, number_of_ai_players: 2}

      game = Games.create_game(user.user_name, valid_attrs)

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
      assert Games.update_game(game, @update_attrs)
    end

    test "delete_game/1 deletes the game" do
      user_fixture()
      game = game_fixture()
      Games.delete_game!(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      user_fixture()
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end

  describe "create_game_for_user" do
    test "that it creates a game with a single player for the current user populated" do
      user = user_fixture()
      cs = Game.changeset(%Game{}, %{number_of_human_players: 1})
      game = Games.create_game_for_user(cs, user.user_name)
      assert [player | _] = game.players
    end
  end

  describe "rounds" do
    @valid_attrs %{starting_game_state: %GameState{round_number: 1}, growth_cycles: []}
    @invalid_attrs %{starting_game_state: nil, growth_cycles: nil}

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
      round = Games.create_round(game.id, @valid_attrs)
      assert round.id >= 0
    end

    test "create_round/2 with invalid data returns error changeset" do
      user_fixture()
      game = game_fixture()
      assert_raise MatchError, fn -> Games.create_round(game.id, @invalid_attrs) end
    end
  end

  describe "next_round_available/1" do
    setup do
      user_fixture(%{user_name: "Fungusmotron"})
      user_fixture()
      :ok
    end

    test "that returns false if there is one human player and they have points to spend" do
      game =
        game_fixture(%{number_of_human_players: 1, number_of_ai_players: 1})

      human_player = Enum.filter(game.players, fn p -> p.human end)
        |> hd

      Players.update_player(human_player, %{mutation_points: 1})

      refute Games.next_round_available?(game)
    end

    test "that returns true if all players have spent their mutation points" do
      game =
        game_fixture(%{number_of_human_players: 1, number_of_ai_players: 1})

      Enum.each(game.players, fn player ->
        Games.update_player(player, %{mutation_points: 0}) end)

      game =
        Games.get_game!(game.id)

      assert Games.next_round_available?(game)
    end

    test "that returns false if at least one player has unspent points" do
      user = user_fixture(%{user_name: "someOtherUser"})
      game = game_fixture(%{number_of_human_players: 2, number_of_ai_players: 1})
      human_player_with_user_fixture(user.user_name, game, 1)
      game = Games.get_game!(game.id)

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns false if at least one ai player has unspent points" do
      user_fixture(%{user_name: "someOtherUser"})
      game = game_fixture(%{number_of_human_players: 1, number_of_ai_players: 0})
      ai_player_fixture(game, 1)
      game = Games.get_game!(game.id)

      game =
        Games.get_game!(game.id)

      refute Games.next_round_available?(game)
    end

    test "next_round_available/1 returns true if all players have spent their points" do
      user = user_fixture(%{user_name: "another user"})

      game = game_fixture(%{number_of_human_players: 2, number_of_ai_players: 1})

      human_player_with_user_fixture(user.user_name, game, 0)
      human_player_without_user_fixture(game)
      ai_player_fixture(game)
      game = Games.get_game!(game.id)

      Enum.each(game.players, fn player ->
        Games.update_player(player, %{mutation_points: 0}) end)

      game = Games.get_game!(game.id)

      assert Games.next_round_available?(game)
    end
  end

  describe "trigger_next_round/1" do
    test "that AI player's mutation points get spent" do
      user = user_fixture(%{user_name: "user name"})
      game = Games.create_game(user.user_name, %{number_of_human_players: 1, number_of_ai_players: 2})

      game = Games.get_game!(game.id)

      Games.trigger_next_round(game)

      game = Games.get_game!(game.id)

      Enum.each(game.players, fn player ->
        if(!player.human) do
          total_points_invested = Enum.reduce(player.skills, 0, fn player_skill, acc ->
            acc + player_skill.skill_level
          end)
          assert total_points_invested == Player.default_starting_mutation_points
        end
      end)
    end

    test "that AI and Human players are awarded their new mutation points" do
      user = user_fixture(%{user_name: "user name"})
      game = Games.create_game(user.user_name, %{number_of_human_players: 1, number_of_ai_players: 1})

      game = Games.get_game!(game.id)

      Games.trigger_next_round(game)

      Players.list_players_for_game(game.id)
      |> Enum.each(fn player ->
        assert player.mutation_points >= Player.default_starting_mutation_points
      end)
    end

    test "that players' number of regenerated cells get updated" do
      #TODO talk to Dave about how to test this. The setup seems too complicated
    end

    test "that the round count down starts at 5 if all cells have been consumed" do
      user = user_fixture(%{user_name: "user name"})
      number_of_cells_in_full_grid = Game.default_grid_size * Game.default_grid_size
      game = Games.create_game(user.user_name,
        %{number_of_human_players: 1, number_of_ai_players: 1, total_live_cells: number_of_cells_in_full_grid})

      a_player_id = hd(game.players).id
      latest_round = Rounds.get_latest_round_for_game(game.id)
      full_grid = Enum.map(0..number_of_cells_in_full_grid - 1, fn index -> %GridCell{index: index, empty: false, player_id: a_player_id} end)

      #make the starting game state have all cells full
      Rounds.update_round(latest_round, %{starting_game_state: %GameState{cells: full_grid}})

      Games.trigger_next_round(game)

      game = Games.get_game!(game.id)

      assert game.end_of_game_count_down == 5
    end

    test "that the round count decrements each round if the count down has started (even if the grid is not full)" do
      user = user_fixture(%{user_name: "user name"})
      number_of_cells_in_full_grid = Game.default_grid_size * Game.default_grid_size
      number_of_rounds_left = 5
      game = Games.create_game(user.user_name,
        %{number_of_human_players: 1, number_of_ai_players: 1, total_live_cells: number_of_cells_in_full_grid, end_of_game_count_down: number_of_rounds_left})

      Games.trigger_next_round(game)

      game = Games.get_game!(game.id)

      assert game.end_of_game_count_down == number_of_rounds_left - 1
    end
  end

  describe "update_aggregate_stats/3" do
    test "that it updates the total live and dead cells for the game and players" do
      user = user_fixture(%{user_name: "user name"})
      game = Games.create_game(user.user_name, %{number_of_human_players: 1, number_of_ai_players: 1})

      player_1_id = Enum.at(game.players, 0).id
      player_2_id = Enum.at(game.players, 1).id

      grid_cells = [
        %GridCell{player_id: player_1_id, live: true},
        %GridCell{player_id: player_1_id, live: true},
        %GridCell{player_id: player_1_id, live: true},
        %GridCell{player_id: player_2_id, live: false},
        %GridCell{player_id: player_2_id, live: false}
      ]

      {updated_game, updated_players} = Games.update_aggregate_stats(game, grid_cells)

      assert updated_game.total_live_cells == 3
      assert updated_game.total_dead_cells == 2

      player1 = Enum.find(updated_players, fn player -> player.id == player_1_id end)
      assert player1.live_cells == 3
      assert player1.dead_cells == 0

      player2 = Enum.find(updated_players, fn player -> player.id == player_2_id end)
      assert player2.live_cells == 0
      assert player2.dead_cells == 2
    end
  end
end
