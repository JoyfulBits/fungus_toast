defmodule FungusToast.Repo.Migrations.UpdateRoundsToHaveGrowthCycles do
  use Ecto.Migration

  def change do
    rename table(:rounds), :state_change, to: :growth_cycles
  end
end
