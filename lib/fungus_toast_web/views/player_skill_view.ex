defmodule FungusToastWeb.PlayerSkillView do
  use FungusToastWeb, :view
  alias FungusToastWeb.PlayerSkillView

  def render("index.json", %{player_skills: player_skills}) do
    render_many(player_skills, PlayerSkillView, "player_skill.json")
  end

  def render("player_skill.json", %{player_skill: player_skill}), do: map_from(player_skill)
end
