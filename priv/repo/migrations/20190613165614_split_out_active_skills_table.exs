defmodule FungusToast.Repo.Migrations.SplitOutActiveSkillsTable do
  use Ecto.Migration

  def change do
    create table(:active_skills) do
      add :name, :string
      add :description, :string
      add :number_of_toast_changes, :integer

      timestamps()
    end
  end
end
