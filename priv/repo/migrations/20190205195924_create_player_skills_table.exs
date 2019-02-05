defmodule FungusToast.Repo.Migrations.CreatePlayerSkillsTable do
  use Ecto.Migration

  def change do
    create table(:player_skills) do
      add :player_id, references(:players, on_delete: :delete_all, null: false)
      add :skill_id, references(:skills, on_delete: :delete_all, null: false)
      add :skill_level, :integer, default: 0, null: false
    end
  end
end
