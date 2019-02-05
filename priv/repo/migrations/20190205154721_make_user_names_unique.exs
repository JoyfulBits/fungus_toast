defmodule FungusToast.Repo.Migrations.MakeUserNamesUnique do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:user_name])
  end
end
