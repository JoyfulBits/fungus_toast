defmodule FungusToast.Games.SkillPrerequisite do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :skill_id,
    :required_skill_id,
    :required_skill_level
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "skill_prerequisites" do
    field :skill_id, :integer
    field :required_skill_id, :integer
    field :required_skill_level, :integer

    timestamps()
  end

  @doc false
  def changeset(skill_prerequisite, attrs) do
    skill_prerequisite
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
