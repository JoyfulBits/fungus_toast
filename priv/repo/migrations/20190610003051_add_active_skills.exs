defmodule FungusToast.Repo.Migrations.AddActiveSkills do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      add :active_skill, :boolean, null: false, default: false
    end
  end
end
