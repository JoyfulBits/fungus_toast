defmodule FungusToast.Games.GridCellTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.GridCell

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = GridCell.changeset(%GridCell{}, %{live: true, empty: false, out_of_grid: false})
    end

    test "a failing changeset" do
       assert %{valid?: false} = GridCell.changeset(%GridCell{}, %{})
    end
  end
end
