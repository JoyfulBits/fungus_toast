defmodule FungusToast.Repo.Migrations.AddAggregateFieldsToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :total_live_cells, :integer, null: false, default: 0
      add :total_dead_cells, :integer, null: false, default: 0
    end
  end
end
