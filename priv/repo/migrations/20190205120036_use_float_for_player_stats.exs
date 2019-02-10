defmodule FungusToast.Repo.Migrations.UseFloatForPlayerStats do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :top_left_growth_chance, :float, default: 0.0, null: false
      modify :top_growth_chance, :float, default: 0.0, null: false
      modify :top_right_growth_chance, :float, default: 0.0, null: false
      modify :right_growth_chance, :float, default: 0.0, null: false
      modify :bottom_right_growth_chance, :float, default: 0.0, null: false
      modify :bottom_growth_chance, :float, default: 0.0, null: false
      modify :bottom_left_growth_chance, :float, default: 0.0, null: false
      modify :left_growth_chance, :float, default: 0.0, null: false
      modify :apoptosis_chance, :float, default: 0.0, null: false
      modify :starved_cell_death_chance, :float, default: 0.0, null: false
      modify :mutation_chance, :float, default: 0.0, null: false
      modify :regeneration_chance, :float, default: 0.0, null: false
      modify :mycotoxin_fungicide_chance, :float, default: 0.0, null: false
    end
  end
end
