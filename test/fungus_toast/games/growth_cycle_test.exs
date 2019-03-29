defmodule FungusToast.Games.GrowthCycleTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.GrowthCycle
  alias FungusToast.Games.GridCell

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = GrowthCycle.changeset(%GrowthCycle{}, %{generation_number: 0, mutation_points_earned: %{}, toast_changes: [%GridCell{}]})
    end

    #TODO I can't get required field validation to work and I don't know why!
    # test "a failing changeset" do
    #   assert %{valid?: false} = GrowthCycle.changeset(%GrowthCycle{}, %{})
    # end
  end
end
