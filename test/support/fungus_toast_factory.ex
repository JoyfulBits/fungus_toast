defmodule FungusToast.Factory do
    use ExMachina.Ecto, repo: FungusToast.Repo

    def user_factory do
        %FungusToast.Accounts.User{
            user_name: sequence(:user_name, &"Test User#{&1}"),
            active: true
        }
    end

    def skill_factory do
        %FungusToast.Games.Skill{
            name: sequence(:name, &"Skill-#{&1}"),
            description: sequence(:description, &"description-#{&1}"),
            increase_per_point: 1
        }
    end

    def player_skill_factory do
        %FungusToast.Games.PlayerSkill{
            skill: build(:skill)
        }
    end

    def player_factory do
        %FungusToast.Games.Player{
            name: sequence(:user_name, &"Test Player#{&1}"),
            human: true,
            user: build(:user),
            skills: [build(:player_skill)]
        }
    end
    def game_factory do
        %FungusToast.Games.Game{
            number_of_human_players: 1,
            number_of_ai_players: 0,
            players: [build(:player)]
        }
    end
end