defmodule FungusToast.ActiveCellChangesTest do
  use FungusToast.DataCase
  alias FungusToast.{Games, Players, Skills, Rounds, ActiveCellChanges}
  alias FungusToast.Games.ActiveCellChange

  doctest FungusToast.ActiveCellChanges

  describe "update_active_cell_changes/3" do
    test "that it returns true when there was an empty map" do
      assert ActiveCellChanges.update_active_cell_changes(-1, -1, %{})
    end

    test "that it returns true when there are no active cell changes" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      upgrade_attrs = %{"1" => %{"active_cell_changes" => [], "points_spent" => 1}, "2" => %{"active_cell_changes" => [], "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(player.id, game.id, upgrade_attrs)
    end

    test "it returns true when the number of active cell changes is equal to the max allowed per point for that skill" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      skill = Skills.get_skill!(Skills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes, fn x -> x end)
      upgrade_attrs = %{skill.id=> %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}
      assert ActiveCellChanges.update_active_cell_changes(player.id, game.id, upgrade_attrs)
    end

    test "it returns true when two points are spent and two times the max is spent" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))
      skill = Skills.get_skill!(Skills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes * 2, fn x -> x end)
      upgrade_attrs = %{skill.id=> %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 2}}
      assert ActiveCellChanges.update_active_cell_changes(player.id, game.id, upgrade_attrs)
    end

    test "it returns false when there are active cell changes but no points are spent" do
      upgrade_attrs = %{1 => %{"active_cell_changes" => [1], "points_spent" => 0}}
      refute ActiveCellChanges.update_active_cell_changes(-1, -1, upgrade_attrs)
    end

    test "it returns false when there are more active cell changes than the max allowed for that skill" do
      skill = Skills.get_skill!(Skills.skill_id_eye_dropper())
      list_with_one_too_many_changes = Enum.map(1..skill.number_of_active_cell_changes + 1, fn x -> x end)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => list_with_one_too_many_changes, "points_spent" => 1}}
      refute ActiveCellChanges.update_active_cell_changes(-1, -1, upgrade_attrs)
    end

    test "it sets active cell changes on the latest round" do
      user = Fixtures.Accounts.User.create!()
      game = Games.create_game(user.user_name, %{number_of_human_players: 1})
      player = hd(Players.list_players_for_game(game.id))

      skill = Skills.get_skill!(Skills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes, fn x -> x end)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}

      assert ActiveCellChanges.update_active_cell_changes(player.id, game.id, upgrade_attrs)

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
      existing_active_cell_changes = [%ActiveCellChange{skill_id: -1, player_id: -1, cell_indexes: [-1]}]
      Rounds.update_round(latest_round, %{active_cell_changes: existing_active_cell_changes})

      skill = Skills.get_skill!(Skills.skill_id_eye_dropper())
      list_with_max_allowed_changes = Enum.map(1..skill.number_of_active_cell_changes, fn x -> x end)
      upgrade_attrs = %{skill.id => %{"active_cell_changes" => list_with_max_allowed_changes, "points_spent" => 1}}

      assert ActiveCellChanges.update_active_cell_changes(player.id, game.id, upgrade_attrs)

      latest_round = Rounds.get_latest_round_for_game(game.id)
      assert latest_round.active_cell_changes
      active_cell_changes = latest_round.active_cell_changes
      assert length(active_cell_changes) == 2
    end
  end
end
