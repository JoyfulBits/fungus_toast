defmodule FungusToast.Games.GameStateTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.GameState
  alias FungusToast.Games.GridCell

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = GameState.changeset(%GameState{}, %{round_number: 0, cells: [%GridCell{}]})
    end

    test "a failing changeset" do
      assert %{valid?: false} = GameState.changeset(%GameState{}, %{})
    end
  end
end
