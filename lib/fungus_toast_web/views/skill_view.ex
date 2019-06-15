defmodule FungusToastWeb.SkillView do
  use FungusToastWeb, :view
  alias FungusToastWeb.SkillView

  def render("index.json", %{skills: skills}) do
    render_many(skills, SkillView, "skill.json")
  end

  def render("show.json", %{skill: skill}) do
    render_one(skill, SkillView, "skill.json")
  end

  def render("skill.json", %{skill: skill}), do: skill_json(skill)

  def skill_json(skill) do
    %{
      id: skill.id,
      name: skill.name,
      up_is_good: skill.up_is_good,
      increase_per_point: skill.increase_per_point,
      minimum_round: skill.minimum_round
    }
  end
end
