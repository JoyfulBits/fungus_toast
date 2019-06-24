defmodule FungusToast.ActiveCellChanges do
  alias FungusToast.{ActiveSkills, Rounds, Players}
  alias FungusToast.Games.{ActiveCellChange}

  @moduledoc """
  Provides functions for dealing with active cell changes. Active cell changes are player-generated manipulations of the toast
  resulting from certain skills. These changes are applied to the toast at the start of the round, before growth cycles.
  """

  #TODO should we add number of active skill changes to player? Should these accumulate or must you spend one per round?
  defp active_cell_changes_are_valid(player, round_number, upgrade_attrs) do
    total_action_points_spent = Enum.reduce(upgrade_attrs, 0, fn {_active_skill_id, map}, acc ->
      Map.get(map, "points_spent") + acc
    end)

    if(total_action_points_spent > player.action_points) do
      {:error, :not_enough_action_points}
    else

      validation_result = Enum.reduce(upgrade_attrs, %{:error => nil}, fn {active_skill_id, map}, acc ->
        if(Map.get(acc, :error) == nil) do
          total_active_changes_for_skill = length(Map.get(map, "active_cell_changes"))
          action_points_spent = Map.get(map, "points_spent")
          max_allowed_active_changes = ActiveSkills.get_allowed_number_of_active_changes(active_skill_id) * action_points_spent
          legal_number_of_active_cell_changes = total_active_changes_for_skill <= max_allowed_active_changes
          if(!legal_number_of_active_cell_changes) do
            %{:error => :too_many_active_cell_changes}
          else
            legal_round_number = round_number >= ActiveSkills.get_minimum_round_number(active_skill_id)
            if(!legal_round_number) do
              %{:error => :skill_used_too_early}
            else
              acc
            end
          end
        else
        end
      end)

      error = Map.get(validation_result, :error)
      if(error == nil) do
        {:ok, total_action_points_spent}
      else
        {:error, error}
      end
    end
  end

  @spec update_active_cell_changes(atom | %{action_points: any}, any, any, any) ::
          {:ok} | {:error, any}
  def update_active_cell_changes(player, game_id, round_number, upgrade_attrs) do
    case active_cell_changes_are_valid(player, round_number, upgrade_attrs) do
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
        {:ok}
      {:error, error_reason} -> {:error, error_reason}
    end
  end
end
