defmodule FungusToast.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_state, :map
      add :active, :boolean, default: false, null: false
      add :number_of_columns, :integer, default: 0, null: false
      add :number_of_rows, :integer, default: 0, null: false

      timestamps()
    end

  end
end
