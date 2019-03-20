defmodule FungusToastWeb.GameViewTest do
  use FungusToastWeb.ConnCase, async: true
  alias FungusToastWeb.GameView
  alias FungusToast.Games.Game
  alias FungusToast.Games.Player
  alias FungusToast.Games.Round

  describe "game.json" do
    @stub_game %Game{ 
        id: "fake",
        players: [%Player{}, %Player{}],
        rounds: [%Round{}, %Round{}]}

    test "the transformation of data model to json" do
        assert GameView.render("game.json", %{game: @stub_game}) == 
          %{
              # TODO: provide the structure we ACTUALLY want

          }
    end
  end
end