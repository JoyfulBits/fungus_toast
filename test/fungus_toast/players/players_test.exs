defmodule FungusToast.PlayersTest do
    use FungusToast.DataCase
    alias FungusToast.Games.Grid
    alias FungusToast.Games.Player
    alias FungusToast.Players

    doctest FungusToast.Players

    describe "create_player_for_user/2" do
        test "that it creates a player with default skills" do
            game = Fixtures.Game.create!
            user = Fixtures.Accounts.User.create!
            {:ok, player} = Players.create_player_for_user(game, user.user_name)

            assert player.id != nil
            #TODO this passes when I run everything through IEX, but I have no idea why I can't
            assert length(player.skills) > 0
        end
    end
end
