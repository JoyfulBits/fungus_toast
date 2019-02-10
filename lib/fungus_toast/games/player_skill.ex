defmodule FungusToast.Games.PlayerSkill do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :skill_level, :skill]}

  schema "player_skills" do
    field :skill_level, :integer, default: 0, null: false

    belongs_to :player, FungusToast.Games.Player
    belongs_to :skill, FungusToast.Games.Skill
  end

  @doc false
  def changeset(player_skill, attrs) do
    player_skill
    |> cast(attrs, [:skill_level])
    |> validate_required([:skill_level])
  end
end
