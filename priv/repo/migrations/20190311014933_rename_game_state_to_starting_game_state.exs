defmodule FungusToast.Repo.Migrations.RenameGameStateToStartingGameState do
  use Ecto.Migration

  def change do
    rename table(:rounds), :game_state, to: :starting_game_state
  end
end
