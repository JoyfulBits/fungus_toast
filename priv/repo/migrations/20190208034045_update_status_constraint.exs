defmodule FungusToast.Repo.Migrations.UpdateStatusConstraint do
  use Ecto.Migration

  def change do
    drop constraint(:games, "status_in_enumerable")
    create constraint(:games, "status_in_enumerable",
             check:
               "status in ('Not Started', 'Started', 'Finished', 'Abandoned', 'Archived')",
             comment: "Constrains the set of possible values for status"
           )
  end
end
