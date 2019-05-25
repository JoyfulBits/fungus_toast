defmodule FungusToast.ActiveCellChanges do
  alias FungusToast.Skills

  @doc """
  Returns a map of skill id to the number of active changes made by for that skill.

  ## Examples
      #it returns true when there is an empty map
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{})
      true

      #it returns true when there were no active_cell_changes
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{"1" => %{"active_cell_changes" => [], "points_spent" => 1}, "2" => %{"active_cell_changes" => [], "points_spent" => 1}})
      true

      #it returns true when the number of active cell changes is equal to the max allowed per point for that skill
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{"6" => %{"active_cell_changes" => [1, 2, 3], "points_spent" => 1}})
      true

      #it returns true when two points are spent and two times the max is spent
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{"6" => %{"active_cell_changes" => [1, 2, 3, 4, 5, 6], "points_spent" => 2}})
      true

      #it returns false when there are active cell changes but no points are spent
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{"6" => %{"active_cell_changes" => [1], "points_spent" => 0}})
      false

      #it returns false when there are more active cell changes than the max allowed for that skill
      iex> ActiveCellChanges.active_cell_changes_are_valid(%{"6" => %{"active_cell_changes" => [1, 2, 3, 4], "points_spent" => 1}})
      false

  """
  def active_cell_changes_are_valid(upgrade_attrs) do
    Enum.reduce(upgrade_attrs, true, fn {skill_id, map}, acc ->
      total_active_changes_for_skill = length(Map.get(map, "active_cell_changes"))
      points_spent = Map.get(map, "points_spent")
      max_allowed_active_changes = Skills.get_allowed_number_of_active_changes(skill_id) * points_spent
      acc and total_active_changes_for_skill <= max_allowed_active_changes
    end)
  end
end
