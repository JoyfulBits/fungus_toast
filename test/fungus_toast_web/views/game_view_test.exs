defmodule FungusToastWeb.GameViewTest do
  use FungusToastWeb.ConnCase, async: true
  use Plug.Test
  alias FungusToastWeb.GameView
  alias FungusToast.Games.Game
  alias FungusToast.Games.Player
  alias FungusToast.Games.Round
  alias FungusToast.Game.Status

  import FungusToast.Factory

  describe "game.json" do
    # TODO: run through this piece by piece until we swagger or something else:
    # https://docs.google.com/document/d/1e7jwVzMLy4Ob9T36gQxmDFHR36xtcbk78mJdzlt9mqM/edit
    #TODO this test is fragile as the *_chance starting values are subject to change as we balance the game
    #@tag :skip
    test "the transformation of data model to json" do
      game = insert(:game)

      assert %{
                 id: _,
                 number_of_human_players: 1,
                 number_of_ai_players: 0,
                 grid_size: 50,
                 status: "Not Started",
                 players: [
                   %{
                     name: _,
                     id: _,
                     mutation_points: _,
                     human: true,
                     top_left_growth_chance: _,
                     top_growth_chance: _,
                     top_right_growth_chance: _,
                     right_growth_chance: _,
                     bottom_right_growth_chance: _,
                     bottom_growth_chance: _,
                     bottom_left_growth_chance: _,
                     left_growth_chance: _,
                     dead_cells: _,
                     live_cells: _,
                     regenerated_cells: _,
                     perished_cells: _,
                     grown_cells: _,
                     apoptosis_chance: _,
                     starved_cell_death_chance: _,
                     mutation_chance: _,
                     regeneration_chance: _,
                     mycotoxin_fungicide_chance: _
                   }
                 ]
               } = GameView.render("game.json", %{game: game})
    end
  end
end
