defmodule FungusToast.Repo.Migrations.AddActiveCellChangesToRound do
  use Ecto.Migration

  def change do
    alter table(:rounds) do
      add :active_cell_changes, :jsonb, null: true
    end
  end
end
