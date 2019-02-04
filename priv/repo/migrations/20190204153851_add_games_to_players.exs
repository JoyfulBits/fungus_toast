defmodule FungusToast.Repo.Migrations.AddGamesToPlayers do
  use Ecto.Migration

  def change do
    create table(:player_games) do
      add :player_id, references(:players, on_delete: :delete_all)
      add :game_id, references(:games, on_delete: :delete_all)
    end

    create unique_index(:player_games, [:player_id, :game_id], name: :unique_player_games_index)
  end
end
