defmodule FungusToast.Repo.Migrations.AddAiTypeToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :ai_type, :string, null: true
    end

    create constraint(:players, "ai_type_in_enumerable",
    check:
      "ai_type in ('Random', 'Growth', 'Toxic', 'Long Term')",
    comment: "Constrains the set of possible values for ai_type"
  )
  end
end
