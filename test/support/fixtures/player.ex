defmodule Fixtures.Player do
    alias FungusToast.Games.Player, as: P
    alias FungusToast.Repo

    def create!(attrs \\ %{}) do
        P.changeset(%P{}, attrs)
        |> Repo.insert!
    end
end