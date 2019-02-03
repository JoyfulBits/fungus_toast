defmodule FungusToast.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :game_state, :map, null: false
      add :state_change, :map, null: false
      add :number, :integer, default: 1, null: false
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:rounds, [:game_id])
  end
end
