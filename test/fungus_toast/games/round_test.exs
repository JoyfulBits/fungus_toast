defmodule FungusToast.Games.RoundTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Round
  alias FungusToast.Games.GameState
  alias FungusToast.Games.GridCell

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = Round.changeset(%Round{}, %{starting_game_state: %{round_number: 1, cells: [%GridCell{}]}})
    end

    test "a failing changeset" do
       assert %{valid?: false} = Round.changeset(%Round{}, %{})
    end
  end
end
