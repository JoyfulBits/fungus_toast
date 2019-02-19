defmodule FungusToast.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :name, :string
      add :description, :string
      add :increase_per_point, :decimal
      add :up_is_good, :boolean

      timestamps()
    end
  end
end
