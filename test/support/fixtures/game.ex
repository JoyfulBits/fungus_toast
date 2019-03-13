defmodule Fixtures.Game do
    alias FungusToast.Games.Game, as: G
    alias FungusToast.Repo

    def create!(attrs \\ %{number_of_human_players: 1}) do
        G.changeset(%G{}, attrs)
        |> Repo.insert!
    end
end