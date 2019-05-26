defmodule FungusToast.ActiveCellChangesTest do
  use ExUnit.Case, async: true
  alias FungusToast.ActiveCellChanges
  alias FungusToast.Skills

  doctest FungusToast.ActiveCellChanges

  describe "update_active_cell_changes/2" do
    test "that it returns true when there was an empty map" do
      assert ActiveCellChanges.update_active_cell_changes(-1, %{})
    end

    test "that it returns true when there are no active cell changes" do
      upgrade_attrs = %{"1" => %{"active_cell_changes" => [], "points_spent" => 1}, "2" => %{"active_cell_changes" => [], "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(-1, upgrade_attrs)
    end

    test "it returns true when the number of active cell changes is equal to the max allowed per point for that skill" do
      skill = Skills.get_skill!(Skills.skill_id_hydrophilia())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes, fn x -> x end)
      upgrade_attrs = %{"6" => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(-1, upgrade_attrs)
    end

    test "it returns true when two points are spent and two times the max is spent" do
      skill = Skills.get_skill!(Skills.skill_id_hydrophilia())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes * 2, fn x -> x end)
      upgrade_attrs = %{"6" => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 2}}
      assert ActiveCellChanges.update_active_cell_changes(-1, upgrade_attrs)
    end

    test "it returns false when there are active cell changes but no points are spent" do
      upgrade_attrs = %{"6" => %{"active_cell_changes" => [1], "points_spent" => 0}}
      refute ActiveCellChanges.update_active_cell_changes(-1, upgrade_attrs)
    end

    test "it returns false when there are more active cell changes than the max allowed for that skill" do
      skill = Skills.get_skill!(Skills.skill_id_hydrophilia())
      list_with_one_too_many_changes = Enum.map(1..skill.number_of_active_cell_changes + 1, fn x -> x end)
      upgrade_attrs = %{"6" => %{"active_cell_changes" => list_with_one_too_many_changes, "points_spent" => 1}}
      refute ActiveCellChanges.update_active_cell_changes(-1, upgrade_attrs)
    end
  end
end
