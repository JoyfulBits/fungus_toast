defmodule FungusToast.Repo.Migrations.AddMinimumRoundToSkills do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      add :minimum_round, :integer, default: 0, null: false
      remove :active_skill
      remove :number_of_active_cell_changes
    end

    alter table(:active_skills) do
      add :minimum_round, :integer, default: 0, null: false
    end
  end
end
