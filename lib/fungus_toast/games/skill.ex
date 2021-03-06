defmodule FungusToast.Games.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :name,
    :description,
    :up_is_good
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "skills" do
    field :description, :string, size: 512
    field :increase_per_point, :float
    field :name, :string, size: 64
    field :up_is_good, :boolean
    field :minimum_round, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :description, :increase_per_point, :up_is_good, :minimum_round])
    |> validate_required([:name, :description, :increase_per_point])
    |> validate_length(:name, max: 64)
    |> validate_length(:description, max: 512)
    |> unique_constraint(:name)
  end
end
