defmodule FungusToastWeb.PlayerSkillViewTest do
  use FungusToastWeb.ConnCase, async: true
  use Plug.Test
  alias FungusToastWeb.{PlayerSkillView, GameView}
  alias FungusToast.Games.Player

  describe "updated_player.json" do
    test "that it returns the transformed player and the specified new round bool" do

      expected_next_round_available = true
      player = %Player{}
      expected_transformed_player = GameView.player_json(player)

      result = PlayerSkillView.render("player_skill_update.json", %{model: %{next_round_available: expected_next_round_available, updated_player: player}})

      assert result.next_round_available == expected_next_round_available
      assert result.updated_player == expected_transformed_player
    end
  end
end
