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
                 id: "fake",
                 number_of_human_players: 1,
                 number_of_ai_players: 1,
                 grid_size: 50,
                 status: "Not Started",
                 players: [
                   %{
                     ai_type: nil,
                     apoptosis_chance: 5.0,
                     bottom_growth_chance: 7.5,
                     bottom_left_growth_chance: 0.0,
                     bottom_right_growth_chance: 0.0,
                     dead_cells: 0,
                     game_id: nil,
                     human: false,
                     id: nil,
                     inserted_at: nil,
                     left_growth_chance: 7.5,
                     live_cells: 0,
                     mutation_chance: 20.0,
                     mutation_points: 5,
                     mycotoxin_fungicide_chance: 0.0,
                     name: nil,
                     regenerated_cells: 0,
                     regeneration_chance: 0.0,
                     right_growth_chance: 7.5,
                     starved_cell_death_chance: 10.0,
                     top_growth_chance: 7.5,
                     top_left_growth_chance: 0.0,
                     top_right_growth_chance: 0.0,
                     updated_at: nil,
                     user_id: nil
                   },
                   %{
                     ai_type: nil,
                     apoptosis_chance: 5.0,
                     bottom_growth_chance: 7.5,
                     bottom_left_growth_chance: 0.0,
                     bottom_right_growth_chance: 0.0,
                     dead_cells: 0,
                     game_id: nil,
                     human: false,
                     id: nil,
                     inserted_at: nil,
                     left_growth_chance: 7.5,
                     live_cells: 0,
                     mutation_chance: 20.0,
                     mutation_points: 5,
                     mycotoxin_fungicide_chance: 0.0,
                     name: nil,
                     regenerated_cells: 0,
                     regeneration_chance: 0.0,
                     right_growth_chance: 7.5,
                     starved_cell_death_chance: 10.0,
                     top_growth_chance: 7.5,
                     top_left_growth_chance: 0.0,
                     top_right_growth_chance: 0.0,
                     updated_at: nil,
                     user_id: nil
                   }
                 ]
               }
    end
  end
end

# {
#  "id":2391,
#  "numberOfHumanPlayers":2,
#  "numberOfAiPlayers":1,
#  "gridSize":50,
#  "status":"Not Started",
#  "players":[
#     {
#        "name":"Jake",
#        "id":"Player 1 id",
#        "mutationPoints":0,
#        "human":true,
#        "topLeftGrowthChance":0.0,
#        "topGrowthChance":0.0,
#        "topRightGrowthChance":0.0,
#        "rightGrowthChance":0.0,
#        "bottomRightGrowthChance":0.0,
#        "bottomGrowthChance":0.0,
#        "bottomLeftGrowthChance":0.0,
#        "leftGrowthChance":0.0,
#        "deadCells":0,
#        "liveCells":0,
#        "regeneratedCells":0,
#        "hyperMutationSkillLevel":0,
#        "antiApoptosisSkillLevel":0,
#        "regenerationSkillLevel":0,
#        "buddingSkillLevel":0,
#        "mycotoxinsSkillLevel":0,
#        "apoptosisChance":0.0,
#        "starvedCellDeathChance":0.0,
#        "mutationChance":0.0,
#        "regenerationChance":0.0,
#        "mycotoxinFungicideChance":0.0,
#        "status":"Joined"
#     },
#     {
#        "name":"AI Player",
#        "id":"AI Player 3 id",
#        "mutationPoints":0,
#        "human":false,
#        "topLeftGrowthChance":0.0,
#        "topGrowthChance":0.0,
#        "topRightGrowthChance":0.0,
#        "rightGrowthChance":0.0,
#        "bottomRightGrowthChance":0.0,
#        "bottomGrowthChance":0.0,
#        "bottomLeftGrowthChance":0.0,
#        "leftGrowthChance":0.0,
#        "deadCells":0,
#        "liveCells":0,
#        "regeneratedCells":0,
#        "hyperMutationSkillLevel":0,
#        "antiApoptosisSkillLevel":0,
#        "regenerationSkillLevel":0,
#        "buddingSkillLevel":0,
#        "mycotoxinsSkillLevel":0,
#        "apoptosisChance":0.0,
#        "starvedCellDeathChance":0.0,
#        "mutationChance":0.0,
#        "regenerationChance":0.0,
#        "mycotoxinFungicideChance":0.0,
#        "status":"Joined"
#     }
#  ],
#  "previousGameState":{
#     "roundNumber":0,
#     "generationNumber":0,
#     "fungalCells":[
#
#     ]
#  },
#  "growthCycles":[
#
#  ],
#  "generationNumber":0,
#  "roundNumber":0,
#  "totalDeadCells":0,
#  "totalEmptyCells":0,
#  "totalLiveCells":0,
#  "totalRegeneratedCells":0,
#  "joinGamePassword":"password"
# }
