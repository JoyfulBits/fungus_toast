defmodule FungusToast.Repo.Migrations.AddNameToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :name, :string, null: false
    end
  end
end
