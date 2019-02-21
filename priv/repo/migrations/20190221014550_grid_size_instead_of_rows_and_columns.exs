defmodule FungusToast.Repo.Migrations.GridSizeInsteadOfRowsAndColumns do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :number_of_columns
      remove :number_of_rows
      add :grid_size, :integer, null: false, default: 50
    end
  end
end
