defmodule FungusToast.Repo.Migrations.AddStatusToGame do
  use Ecto.Migration

  def up do
    alter table(:games) do
      remove :active
      add :status, :string, null: false
    end

    create constraint(:games, "status_in_enumerable",
             check:
               "status in ('Not Started', 'In Progress', 'Finished', 'Abandoned', 'Archived')",
             comment: "Constrains the set of possible values for status"
           )
  end

  def down do
    drop_if_exists constraint(:games, "status_in_enumerable")

    alter table(:games) do
      remove :status
      add :active, :boolean, default: false, null: false
    end
  end
end
