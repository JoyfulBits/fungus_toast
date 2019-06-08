defmodule FungusToast.Repo.Migrations.AddStolenDeadCellsToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :stolen_dead_cells, :integer, default: 0, null: false
    end
  end
end
