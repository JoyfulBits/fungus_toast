defmodule Fixtures.Accounts.User do
    alias FungusToast.Repo
    alias FungusToast.Accounts.User, as: U

    def create!(attrs \\ %{user_name: "testUser", active: true}) do
        U.changeset(%U{}, attrs)
        |> Repo.insert!
    end
end