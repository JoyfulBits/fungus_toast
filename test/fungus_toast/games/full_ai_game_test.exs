defmodule FungusToast.Games.FullAiGameTest do
  use FungusToast.DataCase
  alias FungusToast.{Games, Players, AiStrategies}
  alias FungusToast.Games.{Game, Player}
  alias FungusToast.Skills.SkillsSeed
  alias FungusToast.Repo

  describe "tests for playing out an entire AI game" do
    test "that two AI players can finish a game" do
      SkillsSeed.seed_skills()

      Repo.transaction(fn ->
        game_changeset = %Game{} |> Game.changeset(%{number_of_ai_players: 2, number_of_human_players: 0})
        {:ok, game} = Repo.insert(game_changeset)

        Players.create_basic_player(game.id, false, "Random AI", nil, AiStrategies.ai_type_random)
        |> Player.changeset(%{})
        |> Repo.insert()

        Players.create_basic_player(game.id, false, "Growth AI", nil, AiStrategies.ai_type_growth)
        |> Player.changeset(%{})
        |> Repo.insert()

        game = Repo.get(Game, game.id) |> Repo.preload(:players)

        Games.start_game(game)

        game = Repo.get(Game, game.id) |> Repo.preload(:players)

        play_game(game)
      end)
    end

    def play_game(game, round_count_down \\ nil) do
      round = Games.trigger_next_round(game)

      game = Repo.get(Game, game.id) |> Repo.preload(:players)

      if(round_count_down == 0) do
        IO.inspect "***************"
        IO.inspect "GAME OVER"
        IO.inspect game
      else
        if(length(round.starting_game_state) == game.grid_size) do
          round_count_down = if(round_count_down == nil) do
            5
          else
            round_count_down - 1
          end
          play_game(game, round_count_down)
        else
          play_game(game)
        end

      end
    end
  end
end
