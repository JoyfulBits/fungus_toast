defmodule FungusToast.Games.FullAiGameTest do
  use FungusToast.DataCase
  use Plug.Test
  alias FungusToast.{Games, Players, AiStrategies}
  alias FungusToast.Games.{Game, Player}
  alias FungusToast.Repo
  alias FungusToast.Game.Status

  describe "tests for playing out an entire AI game" do

    #@tag :skip
    test "that two AI players can finish a game" do

      game_changeset = %Game{} |> Game.changeset(%{number_of_ai_players: 5, number_of_human_players: 0})
      {:ok, game} = Repo.insert(game_changeset)

      Players.create_basic_player(game.id, false, "Random AI", nil, AiStrategies.ai_type_random)
      |> Player.changeset(%{})
      |> Repo.insert()

      Players.create_basic_player(game.id, false, "Toxic AI", nil, AiStrategies.ai_type_toxic)
      |> Player.changeset(%{})
      |> Repo.insert()

      Players.create_basic_player(game.id, false, "Growth AI", nil, AiStrategies.ai_type_growth)
      |> Player.changeset(%{})
      |> Repo.insert()

      Players.create_basic_player(game.id, false, "Long Term AI", nil, AiStrategies.ai_type_long_term)
      |> Player.changeset(%{})
      |> Repo.insert()

      Players.create_basic_player(game.id, false, "Super Toxic AI", nil, AiStrategies.ai_type_experimental_1)
      |> Player.changeset(%{})
      |> Repo.insert()

      game = Repo.get(Game, game.id) |> Repo.preload(:players)

      Games.start_game(game)

      game = Repo.get(Game, game.id) |> Repo.preload(:players)

      latest_round = Games.get_latest_round_for_game(game.id)
      #capture each player's start grid cell index so we can see if there are any spots that are better than others
      player_id_to_starting_cell_index_map = Enum.map(latest_round.starting_game_state.cells, fn grid_cell -> {grid_cell.player_id, grid_cell.index} end)
      |> Enum.into(%{})

      play_game(game, player_id_to_starting_cell_index_map)
    end

    def play_game(game, player_id_to_starting_cell_index_map) do
      round = Games.trigger_next_round(game)

      game = Games.get_game!(game.id)

      if(game.status == Status.status_finished) do
        IO.inspect "***************"
        IO.inspect "GAME OVER"
        Enum.sort(game.players, &(&1.live_cells >= &2.live_cells))
        |> Enum.map(fn player -> %{
          starting_index: player_id_to_starting_cell_index_map[player.id],
          ai_type: player.ai_type,
          live_cells: player.live_cells,
          dead_cells: player.dead_cells,
          regenerated_cells: player.regenerated_cells,
          apoptosis_chance: player.apoptosis_chance,
          regeneration_chance: player.regeneration_chance,
          top_right_growth_chance: player.top_right_growth_chance,
          mutation_chance: player.mutation_chance,
          mycotoxin_fungicide_chance: player.mycotoxin_fungicide_chance,
          total_points_spent: get_points_spent(player)
        }
            end)
        |> IO.inspect
      else
        if(round.number == 100) do
          IO.inspect "***************"
          IO.inspect "GAME TOOK TOO LONG TO FINISH"
        else
          number_of_cells = length(round.starting_game_state.cells)
          grid_percent_full = (number_of_cells / (game.grid_size * game.grid_size))
          IO.inspect "**ROUND NUMBER #{round.number}, NUMBER OF CELLS: #{number_of_cells}, % full: #{grid_percent_full}"

          play_game(game, player_id_to_starting_cell_index_map)
        end
      end
    end

    defp get_points_spent(player) do
      Enum.reduce(player.skills, 0, fn player_skill, acc -> player_skill.skill_level + acc end)
    end
  end
end
