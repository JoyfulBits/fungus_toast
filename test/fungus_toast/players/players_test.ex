defmodule FungusToast.PlayersTest do
    use ExUnit.Case, async: false
    alias FungusToast.Games.Grid
    alias FungusToast.Games.Player
    alias FungusToast.Players

    doctest FungusToast.Players

    describe "create_player_for_user/2" do
        test "that it creates a player with default skills" do
            game = Fixtures.Game.create!
            player = Players.create_player_for_user("testUser", game)

            assert length(player.skills) > 0
            assert player.id != nil
        end
    end
end
  