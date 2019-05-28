defmodule FungusToast.ActiveCellChanges do
  alias FungusToast.{Skills, Rounds}
  alias FungusToast.Games.ActiveCellChange

  @moduledoc """
  Provides functions for dealing with active cell changes. Active cell changes are player-generated manipulations of the toast
  resulting from certain skills. These changes are applied to the toast at the start of the round, before growth cycles.
  """

  defp active_cell_changes_are_valid(upgrade_attrs) do
    Enum.reduce(upgrade_attrs, true, fn {skill_id, map}, acc ->
      total_active_changes_for_skill = length(Map.get(map, "active_cell_changes"))
      points_spent = Map.get(map, "points_spent")
      max_allowed_active_changes = Skills.get_allowed_number_of_active_changes(skill_id) * points_spent
      acc and total_active_changes_for_skill <= max_allowed_active_changes
    end)
  end


  def update_active_cell_changes(player_id, game_id, upgrade_attrs) do
    if(active_cell_changes_are_valid(upgrade_attrs)) do
      active_cell_changes = Enum.map(upgrade_attrs, fn {skill_id, map} ->
        %ActiveCellChange{skill_id: skill_id, player_id: player_id, cell_indexes: Map.get(map, "active_cell_changes")}
      end)

      if(length(active_cell_changes) > 0) do
        latest_round = Rounds.get_latest_round_for_game(game_id)

        new_active_cell_changes = latest_round.active_cell_changes ++ active_cell_changes
        Rounds.update_round(latest_round, %{active_cell_changes: new_active_cell_changes})
      end
      true

    else
      false
    end
  end
end
