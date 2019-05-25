defmodule FungusToast.Repo.Migrations.AddNumberOfActiveCellChangesToSkill do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      add :number_of_active_cell_changes, :integer, null: false, default: 0
    end
  end
end
