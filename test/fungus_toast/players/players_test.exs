defmodule FungusToast.PlayersTest do
    use FungusToast.DataCase
    alias FungusToast.Games.Grid
    alias FungusToast.Games.Player
    alias FungusToast.{Players, Skills, AiStrategies}
    alias FungusToast.Skills.SkillsSeed

    doctest FungusToast.Players

    describe "create_basic_player/2" do
        test "that it creates the player including at least the 5 basic skills" do
            SkillsSeed.seed_skills()

            game_id = 2
            human = true
            user_name = "some user name"
            user_id = 1
            player = Players.create_basic_player(game_id, human, user_name, user_id)

            assert player.game_id == game_id
            assert player.human == true
            assert player.name == user_name
            assert player.user_id == user_id
            assert length(player.skills) > 0
        end

        test "that it can create players without user_id" do
            player = Players.create_basic_player(-1, false, "some user name")

            assert player.user_id == nil
        end

        test "that it sets the ai_type for AI players when not specified" do
            player = Players.create_basic_player(-1, false, "some user name")

            assert player.ai_type != nil
        end

        test "that it sets the ai_type to the specified value" do
            expected_ai_type = "some ai type"
            player = Players.create_basic_player(-1, false, "some user name", nil, expected_ai_type)

            assert player.ai_type == expected_ai_type
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
            player = Players.create_player_for_user(game, user.user_name)

            assert player.id != nil
            assert player.human
            assert player.name == user.user_name
            assert player.user_id == user.id
        end
    end

    describe "create_human_players/2" do
        test "that it creates and returns a list of game.number_of_human_players -1 human players" do
            #the player for the user that created the game is created separately
            number_of_human_players = 2
            game = Fixtures.Game.create!(%{number_of_human_players: 3})
            Players.create_human_players(game, number_of_human_players)
            |> Enum.reduce(1, fn player, acc ->
                assert player.id != nil
                assert player.game_id == game.id
                assert player.human
                assert player.name == "Unknown Player " <> Integer.to_string(acc)
                assert player.user_id == nil
                assert acc <= number_of_human_players
                acc + 1
            end)
        end
    end

    describe "create_ai_players/2" do
        test "that it creates and returns a list of game.number_of_ai_players AI players" do
            game = Fixtures.Game.create!(%{number_of_ai_players: 2, number_of_human_players: 1})
            Players.create_ai_players(game)
            |> Enum.reduce(1, fn player, acc ->
                assert player.id != nil
                assert player.game_id == game.id
                assert !player.human
                assert player.ai_type != nil
                assert "Fungal Mutation " <> Integer.to_string(acc) == player.name
                assert player.user_id == nil
                acc + 1
            end)
        end
    end

    describe "spend_ai_mutation_points/2" do
        test "that all mutation points are spent and skills are adjusted accordingly" do
            SkillsSeed.seed_skills()

            mutation_points = 3
            game = Fixtures.Game.create!(%{number_of_ai_players: 1, number_of_human_players: 0})
            player = hd(FungusToast.Players.create_ai_players(game))

            {:ok, player} = Player.changeset(player, %{mutation_points: mutation_points})
            |> Repo.update()

            total_cells = game.grid_size * game.grid_size
            remaining_cells = 1

            player = Players.spend_ai_mutation_points(player, player.mutation_points, total_cells, remaining_cells)

            player = Repo.get(Player, player.id) |> Repo.preload(:skills)

            default_player = %Player{}
            Enum.each(player.skills, fn player_skill ->
                skill = Skills.get_skill!(player_skill.skill_id)

                attributes_to_check = AiStrategies.get_player_attributes_for_skill_name(skill.name)

                Enum.each(attributes_to_check, fn attribute ->
                    current_player_attribute_value = Map.get(player, attribute)
                    default_player_attribute_value = Map.get(default_player, attribute)
                    assert current_player_attribute_value ==
                        default_player_attribute_value + (skill.increase_per_point * get_up_is_good_multiplier(skill.up_is_good)) * player_skill.skill_level
                end)
            end)

            total_skill_level = Enum.reduce(player.skills, 0, fn player_skill, acc -> player_skill.skill_level + acc end)

            assert total_skill_level == mutation_points
        end

        defp get_up_is_good_multiplier(up_is_good) do
            if(up_is_good) do
                1.0
            else
                -1.0
            end
        end
    end
end
