defmodule FungusToast.Repo.Migrations.AddLightLevelToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :light_level, :integer, default: 50, null: false
    end
  end
end
