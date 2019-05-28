defmodule FungusToast.Repo.Migrations.AddMoistureGrowthBoost do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :moisture_growth_boost, :float, null: false, default: 2.0
    end
  end
end
