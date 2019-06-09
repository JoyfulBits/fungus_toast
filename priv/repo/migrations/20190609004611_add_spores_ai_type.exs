defmodule FungusToast.Repo.Migrations.AddSporesAiType do
  use Ecto.Migration

  def change do
    drop constraint(:players, "ai_type_in_enumerable")

    create constraint("players", "ai_type_in_enumerable",
    check:
      "ai_type in ('Random', 'Growth', 'Spores', 'Toxic', 'Long Term', 'Experimental 1', 'Experimental 2')",
    comment: "Constrains the set of possible values for ai_type")
  end
end
