defmodule FungusToast.Repo.Migrations.IncreaseDefaultMutationPoints do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :mutation_points, :integer, default: 5, null: false
    end
  end
end
