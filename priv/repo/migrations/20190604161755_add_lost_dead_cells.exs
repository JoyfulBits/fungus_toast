defmodule FungusToast.Repo.Migrations.AddLostDeadCells do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :lost_dead_cells, :integer, default: 0, null: false
    end
  end
end
