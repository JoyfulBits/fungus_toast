defmodule Fixtures.Player do
    alias FungusToast.Games.Player, as: P
    alias FungusToast.Repo

    def create!(attrs \\ %{}) do
        merged_attrs = Map.merge(attrs, FungusToast.Players.create_basic_player(attrs.game_id, false, "Some AI Player Name"), fn _k, v1, _v2 -> v1 end)
        {:ok, player} = P.changeset(%P{}, merged_attrs)
        |> Repo.insert!

        player
    end
end
