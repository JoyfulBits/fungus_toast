defmodule FungusToast.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :name,
    :description,
    :up_is_good
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "skills" do
    field :description, :string
    field :increase_per_point, :decimal
    field :name, :string
    field :up_is_good, :boolean

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :description, :increase_per_point, :up_is_good])
    |> validate_required([:name, :description, :increase_per_point])
  end
end
