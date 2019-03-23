defmodule FungusToast.PlayersTest do
    use FungusToast.DataCase
    alias FungusToast.Games.Grid
    alias FungusToast.Games.Player
    alias FungusToast.Players

    doctest FungusToast.Players

    describe "create_basic_player/2" do
        test "that it creates the player including at least the 5 basic skills" do
            game_id = 2
            human = true
            user_name = "some user name"
            user_id = 1
            player = Players.create_basic_player(game_id, human, user_name, user_id)

            assert player.game_id == game_id
            assert player.human == true
            assert player.name == user_name
            assert player.user_id == user_id
            length(player.skills) > 0
        end

        test "that it can create players with no user_name or user_id" do
            player = Players.create_basic_player(-1, false)

            assert player.human == false
            assert player.name == nil
            assert player.user_id == nil
        end

        test "that it raises an error if trying to create an AI player with a user_id" do
            assert_raise ArgumentError, "AI players cannot have a user_id", fn ->
                Players.create_basic_player(-1, false, "user name", 1) end
        end
    end

    describe "create_player_for_user/2" do
        test "that it creates and returns a human player with the correct username" do
            game = Fixtures.Game.create!
            user = Fixtures.Accounts.User.create!
            {:ok, player} = Players.create_player_for_user(game, user.user_name)

            assert player.id != nil
            assert player.human
            assert player.name == user.user_name
            assert player.user_id == user.id
        end
    end
end
