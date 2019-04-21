defmodule FungusToast.Repo.Migrations.AddEndOfGameCountDown do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :end_of_game_count_down, :integer, null: true, default: nil
    end
  end
end
