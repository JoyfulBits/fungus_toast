defmodule FungusToastWeb.GameViewTest do
  use FungusToastWeb.ConnCase, async: true
  use Plug.Test
  alias FungusToastWeb.GameView
  alias FungusToast.Games.{Game, Player, GridCell, GameState, Round}
  alias FungusToast.Game.Status

  import FungusToast.Factory

  describe "game.json" do
    # TODO: run through this piece by piece until we swagger or something else:
    # https://docs.google.com/document/d/1e7jwVzMLy4Ob9T36gQxmDFHR36xtcbk78mJdzlt9mqM/edit
    #@tag :skip
    test "that the game and player information gets added to the model" do
      game = insert(:game)
      player = %Player{
        name: "player name",
        id: 1,
        mutation_points: 2,
        human: true,
        top_left_growth_chance: 3,
        top_growth_chance: 4,
        top_right_growth_chance: 5,
        right_growth_chance: 6,
        bottom_right_growth_chance: 7,
        bottom_growth_chance: 8,
        bottom_left_growth_chance: 9,
        left_growth_chance: 10,
        dead_cells: 11,
        live_cells: 12,
        regenerated_cells: 13,
        perished_cells: 14,
        grown_cells: 15,
        apoptosis_chance: 16,
        starved_cell_death_chance: 17,
        mutation_chance: 18,
        regeneration_chance: 19,
        mycotoxin_fungicide_chance: 20,
        user_id: 21
      }
      game = Map.put(game, :players, [player])
      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.id == game.id
      assert result.number_of_human_players == game.number_of_human_players
      assert result.number_of_ai_players == game.number_of_ai_players
      assert result.grid_size == game.grid_size
      assert result.status == Status.status_not_started
      assert length(result.players) == 1
      actual_player_info = hd(result.players)

      assert actual_player_info.id == player.id
      assert actual_player_info.top_left_growth_chance == player.top_left_growth_chance
      assert actual_player_info.top_growth_chance == player.top_growth_chance
      assert actual_player_info.top_right_growth_chance == player.top_right_growth_chance
      assert actual_player_info.right_growth_chance == player.right_growth_chance
      assert actual_player_info.bottom_right_growth_chance == player.bottom_right_growth_chance
      assert actual_player_info.bottom_growth_chance == player.bottom_growth_chance
      assert actual_player_info.bottom_left_growth_chance == player.bottom_left_growth_chance
      assert actual_player_info.dead_cells == player.dead_cells
      assert actual_player_info.live_cells == player.live_cells
      assert actual_player_info.regenerated_cells == player.regenerated_cells
      assert actual_player_info.perished_cells == player.perished_cells
      assert actual_player_info.grown_cells == player.grown_cells
      assert actual_player_info.apoptosis_chance == player.apoptosis_chance
      assert actual_player_info.starved_cell_death_chance == player.starved_cell_death_chance
      assert actual_player_info.mutation_chance == player.mutation_chance
      assert actual_player_info.regeneration_chance == player.regeneration_chance
      assert actual_player_info.mycotoxin_fungicide_chance == player.mycotoxin_fungicide_chance
    end

    test "that AI players and players with user ids have a status of Joined and humans without user ids are Not Joined" do
      ai_player = %Player{id: 1, human: false, user_id: nil }
      not_joined_human_player = %Player{id: 2, human: true, user_id: nil}
      joined_human_player = %Player{id: 3, human: true, user_id: 1}

      game = %Game{players: [ai_player, not_joined_human_player, joined_human_player]}
      game_with_round = %{game: game, latest_completed_round: nil}

      result = GameView.render("game.json", %{game: game_with_round})

      assert length(result.players) == 3

      transformed_ai_player = Enum.filter(result.players, fn player -> player.id == ai_player.id end) |> hd
      assert transformed_ai_player.status == "Joined"

      not_joined_human_player = Enum.filter(result.players, fn player -> player.id == not_joined_human_player.id end) |> hd
      assert not_joined_human_player.status == "Not Joined"

      not_joined_human_player = Enum.filter(result.players, fn player -> player.id == joined_human_player.id end) |> hd
      assert not_joined_human_player.status == "Joined"
    end

    test "that the starting game state gets added" do
      game = %Game{players: []}
      live_cell =  %GridCell{
        index: 1,
        player_id: 10,
        live: true
      }

      dead_cell =  %GridCell{
        index: 2,
        player_id: 10,
        live: false
      }

      regenerated_cell =  %GridCell{
        index: 3,
        player_id: 10,
        live: true,
        previous_player_id: 11
      }

      cells = [live_cell, dead_cell, regenerated_cell]

      starting_game_state = %GameState{round_number: 1, cells: cells}
      latest_completed_round = %Round{starting_game_state: starting_game_state}
      game_with_round = %{game: game, latest_completed_round: latest_completed_round}

      result = GameView.render("game.json", %{game: game_with_round})

      assert result.starting_game_state != nil
      actual_starting_game_state = result.starting_game_state
      assert actual_starting_game_state.round_number == starting_game_state.round_number
      assert length(actual_starting_game_state.fungal_cells) == length(cells)

      actual_live_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == live_cell.index end) |> hd
      assert actual_live_cell.index == live_cell.index
      assert actual_live_cell.player_id == live_cell.player_id
      assert actual_live_cell.live == live_cell.live

      actual_dead_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == dead_cell.index end) |> hd
      assert actual_dead_cell.index == dead_cell.index
      assert actual_dead_cell.player_id == dead_cell.player_id
      assert actual_dead_cell.live == dead_cell.live

      actual_regenerated_cell = Enum.filter(actual_starting_game_state.fungal_cells, fn cell -> cell.index == regenerated_cell.index end) |> hd
      assert actual_regenerated_cell.index == regenerated_cell.index
      assert actual_regenerated_cell.player_id == regenerated_cell.player_id
      assert actual_regenerated_cell.live == regenerated_cell.live
    end
  end
end
