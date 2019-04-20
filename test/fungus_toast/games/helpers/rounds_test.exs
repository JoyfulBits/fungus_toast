defmodule FungusToast.RoundsTest do
  use FungusToast.DataCase
  alias FungusToast.{Games, Rounds, Accounts}

  describe "get_latest_completed_round_for_game/1" do
    test "that the round doesn't have any growth cycles" do
      user_name = "testUser"
      {:ok, _user} = Accounts.create_user(%{user_name: user_name})
      game = Games.create_game(user_name, %{number_of_human_players: 1})

      latest_round = Rounds.get_latest_completed_round_for_game(game.id)

      assert latest_round.growth_cycles != []
    end
  end
end
