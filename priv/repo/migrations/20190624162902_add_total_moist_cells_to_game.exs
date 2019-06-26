defmodule FungusToast.Repo.Migrations.AddTotalMoistCellsToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :total_moist_cells, :integer, null: false, default: 0
    end
  end
end
