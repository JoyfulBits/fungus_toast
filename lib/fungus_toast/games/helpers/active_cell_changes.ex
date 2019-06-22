defmodule FungusToast.ActiveCellChanges do
  alias FungusToast.{ActiveSkills, Rounds, Players}
  alias FungusToast.Games.{ActiveCellChange}

  @moduledoc """
  Provides functions for dealing with active cell changes. Active cell changes are player-generated manipulations of the toast
  resulting from certain skills. These changes are applied to the toast at the start of the round, before growth cycles.
  """

  #TODO should we add number of active skill changes to player? Should these accumulate or must you spend one per round?

  defp active_cell_changes_are_valid(player, upgrade_attrs) do
    total_action_points_spent = Enum.reduce(upgrade_attrs, 0, fn {_active_skill_id, map}, acc ->
      Map.get(map, "points_spent") + acc
    end)

    if(total_action_points_spent > player.action_points) do
      {:error, :not_enough_action_points}
    else
      legal_number_of_active_cell_changes = Enum.reduce(upgrade_attrs, true, fn {active_skill_id, map}, acc ->
        total_active_changes_for_skill = length(Map.get(map, "active_cell_changes"))
        action_points_spent = Map.get(map, "points_spent")
        max_allowed_active_changes = ActiveSkills.get_allowed_number_of_active_changes(active_skill_id) * action_points_spent
        acc and total_active_changes_for_skill <= max_allowed_active_changes
      end)

      if(legal_number_of_active_cell_changes) do
        {:ok, total_action_points_spent}
      else
        {:error, :too_many_active_cell_changes}
      end
    end
  end

  @spec update_active_cell_changes(any, any, any) :: boolean
  def update_active_cell_changes(player, game_id, upgrade_attrs) do
    case active_cell_changes_are_valid(player, upgrade_attrs) do
      {:ok, action_points_spent} ->
        active_cell_changes = Enum.map(upgrade_attrs, fn {active_skill_id, map} ->
          %ActiveCellChange{active_skill_id: active_skill_id, player_id: player.id, cell_indexes: Map.get(map, "active_cell_changes")}
        end)

        if(length(active_cell_changes) > 0) do
          Players.update_player(player, %{action_points: player.action_points - action_points_spent})
          latest_round = Rounds.get_latest_round_for_game(game_id)

          new_active_cell_changes = latest_round.active_cell_changes ++ active_cell_changes
          Rounds.update_round(latest_round, %{active_cell_changes: new_active_cell_changes})
        end
        true
      {:error, _} -> false
    end
  end
end
