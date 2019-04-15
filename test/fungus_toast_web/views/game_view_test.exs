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
    @tag :skip
    test "the transformation of data model to json" do
      game = insert(:game)

      assert %{
                 id: _,
                 number_of_human_players: 1,
                 number_of_ai_players: 0,
                 grid_size: 50,
                 status: "Not Started",
                 status: Status.status_not_started,
                 players: [
                   %{
                     name: _,
                     id: _,
                     mutation_points: 5,
                     human: true,
                     top_left_growth_chance: _,
                     top_right_growth_chance: _,
                   }
                 ]
               } = GameView.render("game.json", %{game: game})
    end
  end
end
