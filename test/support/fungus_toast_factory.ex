defmodule FungusToast.Factory do
    use ExMachina.Ecto, repo: FungusToast.Repo

    def user_factory do
        %FungusToast.Accounts.User{
            user_name: sequence(:user_name, &"Test User#{&1}"),
            active: true
        }
    end

    def player_factory do
        %FungusToast.Games.Player{
            name: sequence(:user_name, &"Test Player#{&1}"),
            human: true,
            user: build(:user),
        }
    end

    def game_factory do
        %FungusToast.Games.Game{
            number_of_human_players: 1,
            number_of_ai_players: 1,
            players: build_list(1, :player)
        }
    end
    
end