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
        rounds: [%Round{}, %Round{}]}

    test "the transformation of data model to json" do
        assert GameView.render("game.json", %{game: @stub_game}) == 
          %{
              number_of_human_players: 1,
              number_of_ai_players: 1,
              grid_size: 50,
              status: "Not Started"
          }
    end
  end
end