defmodule FungusToast.Games.FullAiGameTest do
  use FungusToast.DataCase
  use Plug.Test
  alias FungusToast.{Games, Players, AiStrategies}
  alias FungusToast.Games.{Game, Player}
  alias FungusToast.Repo
  alias FungusToast.Game.Status

  describe "tests for playing out an entire AI game" do

    @tag :skip
    test "that two AI players can finish a game" do

      Repo.transaction(fn ->
        game_changeset = %Game{} |> Game.changeset(%{number_of_ai_players: 4, number_of_human_players: 0})
        {:ok, game} = Repo.insert(game_changeset)

        Players.create_basic_player(game.id, false, "Random AI", nil, AiStrategies.ai_type_random)
        |> Player.changeset(%{})
        |> Repo.insert()

        Players.create_basic_player(game.id, false, "Growth AI", nil, AiStrategies.ai_type_growth)
        |> Player.changeset(%{})
        |> Repo.insert()

        Players.create_basic_player(game.id, false, "Toxic AI", nil, AiStrategies.ai_type_toxic)
        |> Player.changeset(%{})
        |> Repo.insert()

        Players.create_basic_player(game.id, false, "Long Term AI", nil, AiStrategies.ai_type_long_term)
        |> Player.changeset(%{})
        |> Repo.insert()

        game = Repo.get(Game, game.id) |> Repo.preload(:players)

        Games.start_game(game)

        game = Repo.get(Game, game.id) |> Repo.preload(:players)

        play_game(game)
      end)
    end

    def play_game(game) do
      round = Games.trigger_next_round(game)

      game = Games.get_game!(game.id)

      if(game.status == Status.status_finished) do
        IO.inspect "***************"
        IO.inspect "GAME OVER"
        ranked_map = Enum.sort(game.players, &(&1.live_cells >= &2.live_cells))
        |> Enum.map(fn player -> {player.ai_type, player.live_cells} end)
        |> IO.inspect
      else
        if(round.number == 100) do
          IO.inspect "***************"
          IO.inspect "GAME TOOK TOO LONG TO FINISH"
        else
          number_of_cells = length(round.starting_game_state.cells)
          IO.inspect "**ROUND NUMBER #{round.number}, NUMBER OF CELLS: #{number_of_cells}"

          play_game(game)
        end
      end
    end
  end
end
