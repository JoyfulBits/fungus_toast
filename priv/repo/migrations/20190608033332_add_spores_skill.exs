defmodule FungusToast.Repo.Migrations.AddSporesSkill do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :spores_chance, :float, null: false, default: 0.0
    end
  end
end
