defmodule FungusToast.Games.RoundTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.Round
  alias FungusToast.Games.GameState

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = Round.changeset(%Round{}, %{starting_game_state: %{round_number: 1, cells: %{}}})
    end

    test "a failing changeset" do
       params =
       %{
           number: 0,
           starting_game_state: %FungusToast.Games.GameState{
             cells: %{},
             round_number: 0
           }
         }
       assert %{valid?: true} = Round.changeset(%Round{}, params)
    end
  end

  test "gamestate debuggering" do
    assert %{valid?: true} = GameState.changeset(%GameState{}, %GameState{round_number: 0, cells: %{}})

  end
end
