defmodule FungusToast.Repo.Migrations.UseFloatForSkillIncreases do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      modify :increase_per_point, :float
    end
  end
end
