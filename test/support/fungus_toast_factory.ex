defmodule FungusToast.Factory do
    use ExMachina.Ecto, repo: FungusToast.Repo

    def user_factory do
        %FungusToast.Accounts.User{
            user_name: sequence(:user_name, &"Test User#{&1}"),
            active: true
        }
    end
    
end