defmodule Fixtures.Accounts.User do
    alias FungusToast.Repo
    alias FungusToast.Accounts.User, as: U

    def create!(attrs \\ %{user_name: "Testies"}) do
        U.changeset(%U{}, attrs)
        |> Repo.insert!
    end
end