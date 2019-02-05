defmodule FungusToast.Repo.Migrations.AddSizesToSkillColumns do
  use Ecto.Migration

  def change do
    alter table(:skills) do
      modify :name, :string, size: 64
      modify :description, :string, size: 512
    end
  end
end
