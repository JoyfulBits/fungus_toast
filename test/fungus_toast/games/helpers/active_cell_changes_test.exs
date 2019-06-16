defmodule FungusToast.ActiveCellChangesTest do
  use FungusToast.DataCase
  alias FungusToast.{Games, Players, ActiveSkills, Rounds, ActiveCellChanges}
  alias FungusToast.Games.{ActiveCellChange, Player}

  doctest FungusToast.ActiveCellChanges

  describe "update_active_cell_changes/3" do
    test "that it returns true when there was an empty map" do
      assert ActiveCellChanges.update_active_cell_changes(%Player{}, -1, %{})
    end

    test "that it returns true when there are no active cell changes" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      upgrade_attrs = %{"1" => %{"active_cell_changes" => [], "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)
    end

    test "it returns true when the number of active cell changes is equal to the max allowed per action point for that skill" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_toast_changes, fn x -> x end)
      upgrade_attrs = %{skill.id=> %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)
      updated_player = Players.get_player!(player.id)
      assert updated_player.action_points == 0
    end

    test "it returns true when two action points are spent and two times the max cell changes are requested" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      |> Players.update_player(%{action_points: 2})
      skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_toast_changes * 2, fn x -> x end)
      upgrade_attrs = %{skill.id=> %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 2}}
      assert ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)
    end

    test "it returns false when the player doesn't have enough action points" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      upgrade_attrs = %{skill.id=> %{"active_cell_changes" => [], "points_spent" => 2}}
      refute ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)
    end

    test "it returns false when there are active cell changes but no points are spent" do
      upgrade_attrs = %{1 => %{"active_cell_changes" => [1], "points_spent" => 0}}
      refute ActiveCellChanges.update_active_cell_changes(%Player{}, -1, upgrade_attrs)
    end

    test "it returns false when there are more active cell changes than the max allowed for that skill" do
      skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      list_with_one_too_many_changes = Enum.map(1..skill.number_of_toast_changes + 1, fn x -> x end)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => list_with_one_too_many_changes, "points_spent" => 1}}
      refute ActiveCellChanges.update_active_cell_changes(%Player{action_points: 1}, -1, upgrade_attrs)
    end

    test "it sets active cell changes on the latest round" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))

      skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_toast_changes, fn x -> x end)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}

      assert ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)

      latest_round = Rounds.get_latest_round_for_game(game.id)
      assert latest_round.active_cell_changes
      active_cell_changes = latest_round.active_cell_changes
      assert length(active_cell_changes) == 1
      active_cell_change = hd(active_cell_changes)
      assert active_cell_change.player_id == player.id
    end

    test "it adds active cell changes on the latest round if some already exist" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      latest_round = Rounds.get_latest_round_for_game(game.id)
      existing_active_cell_changes = [%ActiveCellChange{active_skill_id: -1, player_id: -1, cell_indexes: [-1]}]
      Rounds.update_round(latest_round, %{active_cell_changes: existing_active_cell_changes})

      active_skill = ActiveSkills.get_active_skill!(ActiveSkills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..active_skill.number_of_toast_changes, fn x -> x end)
      upgrade_attrs = %{active_skill.id => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}

      assert ActiveCellChanges.update_active_cell_changes(player, game.id, upgrade_attrs)

      latest_round = Rounds.get_latest_round_for_game(game.id)
      assert latest_round.active_cell_changes
      active_cell_changes = latest_round.active_cell_changes
      assert length(active_cell_changes) == 2
    end
  end
end
