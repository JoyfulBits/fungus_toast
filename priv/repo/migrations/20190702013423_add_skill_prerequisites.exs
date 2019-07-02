defmodule FungusToast.Repo.Migrations.AddSkillPrerequisites do
  use Ecto.Migration

  def change do
    create table(:skill_prerequisites) do
      add :skill_id, :integer, null: false
      add :required_skill_id, :integer, null: false
      add :required_skill_level, :integer, null: false

      timestamps()
    end
  end
end
