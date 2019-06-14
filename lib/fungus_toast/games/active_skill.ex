defmodule FungusToast.Games.ActiveSkill do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :name,
    :description,
    :number_of_toast_changes,
    :minimum_round
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "active_skills" do
    field :description, :string, size: 512
    field :number_of_toast_changes, :integer, default: 0
    field :name, :string, size: 64
    field :minimum_round, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :description, :number_of_toast_changes, :minimum_round])
    |> validate_required([:name, :description, :number_of_toast_changes, :minimum_round])
    |> validate_length(:name, max: 64)
    |> validate_length(:description, max: 512)
    |> unique_constraint(:name)
  end
end
