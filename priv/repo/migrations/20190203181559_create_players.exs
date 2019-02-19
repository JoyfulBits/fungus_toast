defmodule FungusToast.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :user_name, :string
      add :active, :boolean, default: false, null: false
      add :human, :boolean, default: false, null: false

      timestamps()
    end
  end
end
