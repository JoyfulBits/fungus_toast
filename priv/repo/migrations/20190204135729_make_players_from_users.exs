defmodule FungusToast.Repo.Migrations.MakePlayersFromUsers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :user_id, references(:users, on_delete: :nothing, null: false)

      remove :active
      remove :user_name
    end

    create index(:players, [:user_id])
  end
end
