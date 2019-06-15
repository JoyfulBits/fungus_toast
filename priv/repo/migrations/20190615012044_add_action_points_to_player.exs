defmodule FungusToast.Repo.Migrations.AddActionPointsToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :action_points, :integer, default: 0, null: false
    end
  end
end
