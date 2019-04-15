defmodule FungusToast.Repo.Migrations.ChangeGrowthCyclesToListOfMaps do
  use Ecto.Migration

  def change do
    alter table (:rounds) do
      modify :growth_cycles, :jsonb
    end
  end
end
