defmodule FungusToast.Repo.Migrations.AddFungicidalKillsToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :fungicidal_kills, :integer, null: false, default: 0
    end
  end
end
