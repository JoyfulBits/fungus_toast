defmodule FungusToast.Repo.Migrations.AddPlayerCountsToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :number_of_human_players, :integer, null: false
      add :number_of_ai_players, :integer, null: false
    end
  end
end
