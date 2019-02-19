defmodule FungusToast.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_name, :string
      add :active, :boolean, default: true, null: false

      timestamps()
    end
  end
end
