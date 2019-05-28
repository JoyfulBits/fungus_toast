defmodule FungusToast.Accounts.UsersSeed do
  alias FungusToast.Accounts

  defp create_user_if_not_exists(user_name) do
    existing_user = Accounts.get_user_for_name(user_name)

    if(existing_user == nil) do
      Accounts.create_user(%{user_name: user_name})
    end

  end

  def seed_users do
    create_user_if_not_exists("Human 1")
    create_user_if_not_exists("Human 2")
    create_user_if_not_exists("Human 3")
    create_user_if_not_exists("Human 4")
    create_user_if_not_exists("Human 5")
    create_user_if_not_exists("Human 6")
  end
end
