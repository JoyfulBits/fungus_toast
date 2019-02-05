defmodule FungusToast.Games.PlayerSkill do
  use Ecto.Schema

  schema "player_skills" do
    field :skill_level, :integer, default: 0, null: false

    belongs_to :player, FungusToast.Games.Player
    belongs_to :skill, FungusToast.Games.Skill
  end
end
