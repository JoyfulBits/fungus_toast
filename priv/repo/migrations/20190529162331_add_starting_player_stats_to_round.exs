defmodule FungusToast.Repo.Migrations.AddStartingPlayerStatsToRound do
  use Ecto.Migration

  def change do
    alter table(:rounds) do
      add :starting_player_stats, :jsonb, null: true
    end
  end
end
