defmodule FungusToast.Games.CellGrowerTest do
    use ExUnit.Case, async: true
    alias FungusToast.Games.{CellGrower, GridCell}

    doctest FungusToast.Games.CellGrower

    describe "try_spore_growth/3" do
        test "it returns a new %GridCell if the spore chance hits and the random location is open" do
            player_with_maxed_out_spores = %FungusToast.Games.Player{id: 1, spores_chance: 100}
            grid_size = 100
            new_grid_cell = CellGrower.try_spore_growth(%{}, grid_size, player_with_maxed_out_spores)

            assert new_grid_cell != nil
            assert new_grid_cell.live
            refute new_grid_cell.empty
            assert new_grid_cell.previous_player_id == nil
            assert new_grid_cell.index >= 0
            assert new_grid_cell.index < grid_size
            assert new_grid_cell.player_id == player_with_maxed_out_spores.id
        end
    end
end
