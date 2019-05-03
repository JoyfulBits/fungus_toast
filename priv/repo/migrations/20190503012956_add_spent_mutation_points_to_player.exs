defmodule FungusToast.Repo.Migrations.AddSpentMutationPointsToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :spent_mutation_points, :integer, null: false, default: 0
    end
  end
end
