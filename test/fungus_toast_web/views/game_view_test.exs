defmodule FungusToastWeb.GameViewTest do
  use FungusToastWeb.ConnCase, async: true
  alias FungusToastWeb.GameView
  alias FungusToast.Games.Game
  alias FungusToast.Games.Player
  alias FungusToast.Games.Round

  describe "game.json" do
    @stub_game %Game{
      id: "fake",
      number_of_human_players: 1,
      number_of_ai_players: 1,
      players: [%Player{}, %Player{}],
      rounds: [%Round{}, %Round{}]
    }

    test "the transformation of data model to json" do
      assert GameView.render("game.json", %{game: @stub_game}) ==
               %{
                 grid_size: 50,
                 id: "fake",
                 number_of_ai_players: 1,
                 number_of_human_players: 1,
                 status: "Not Started",
                 players: [
                   %{
                     human: false,
                     id: nil,
                     name: nil,
                     apoptosis_chance: 5.0,
                     bottom_growth_chance: 7.5,
                     bottom_left_growth_chance: 0.0,
                     bottom_right_growth_chance: 0.0,
                     dead_cells: 0,
                     left_growth_chance: 7.5,
                     live_cells: 0,
                     mutation_chance: 20.0,
                     mutation_points: 5,
                     mycotoxin_fungicide_chance: 0.0,
                     regenerated_cells: 0,
                     regeneration_chance: 0.0,
                     right_growth_chance: 7.5,
                     starved_cell_death_chance: 10.0,
                     top_growth_chance: 7.5,
                     top_left_growth_chance: 0.0,
                     top_right_growth_chance: 0.0
                   },
                   %{
                     human: false,
                     id: nil,
                     name: nil,
                     apoptosis_chance: 5.0,
                     bottom_growth_chance: 7.5,
                     bottom_left_growth_chance: 0.0,
                     bottom_right_growth_chance: 0.0,
                     dead_cells: 0,
                     left_growth_chance: 7.5,
                     live_cells: 0,
                     mutation_chance: 20.0,
                     mutation_points: 5,
                     mycotoxin_fungicide_chance: 0.0,
                     regenerated_cells: 0,
                     regeneration_chance: 0.0,
                     right_growth_chance: 7.5,
                     starved_cell_death_chance: 10.0,
                     top_growth_chance: 7.5,
                     top_left_growth_chance: 0.0,
                     top_right_growth_chance: 0.0
                   }
                 ],
                 generation_number: 0,
                 round_number: 0,
                 total_dead_cells: 0,
                 total_empty_cells: 0,
                 total_live_cells: 0,
                 total_regenerated_cells: 0,
                 join_game_password: "password"
               }
    end
  end
end

# {
#  "previousGameState":{
#     "roundNumber":0,
#     "generationNumber":0,
#     "fungalCells":[
#
#     ]
#  },
#  "growthCycles":[
#
#  ]
# }
