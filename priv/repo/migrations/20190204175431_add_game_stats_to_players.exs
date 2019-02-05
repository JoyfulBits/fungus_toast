defmodule FungusToast.Repo.Migrations.AddGameStatsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :mutation_points, :integer, default: 0, null: false
      add :top_left_growth_chance, :float, default: 0.0, null: false
      add :top_growth_chance, :float, default: 0.0, null: false
      add :top_right_growth_chance, :float, default: 0.0, null: false
      add :right_growth_chance, :float, default: 0.0, null: false
      add :bottom_right_growth_chance, :float, default: 0.0, null: false
      add :bottom_growth_chance, :float, default: 0.0, null: false
      add :bottom_left_growth_chance, :float, default: 0.0, null: false
      add :left_growth_chance, :float, default: 0.0, null: false
      add :dead_cells, :integer, default: 0, null: false
      add :live_cells, :integer, default: 0, null: false
      add :regenerated_cells, :integer, default: 0, null: false
      add :apoptosis_chance, :float, default: 0.0, null: false
      add :starved_cell_death_chance, :float, default: 0.0, null: false
      add :mutation_chance, :float, default: 0.0, null: false
      add :regeneration_chance, :float, default: 0.0, null: false
      add :mycotoxin_fungicide_chance, :float, default: 0.0, null: false
    end
  end
end
