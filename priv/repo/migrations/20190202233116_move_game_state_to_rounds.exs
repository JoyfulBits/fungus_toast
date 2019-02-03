defmodule FungusToast.Repo.Migrations.MoveGameStateToRounds do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :game_state
    end
  end
end
