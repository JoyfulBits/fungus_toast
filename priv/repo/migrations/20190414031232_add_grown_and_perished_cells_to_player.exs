defmodule FungusToast.Repo.Migrations.AddGrownAndPerishedCellsToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :grown_cells, :integer, default: 0, null: false
      add :perished_cells, :integer, default: 0, null: false
    end
  end
end
