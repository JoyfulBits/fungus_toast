defmodule FungusToastWeb.ActiveSkillView do
  use FungusToastWeb, :view
  alias FungusToastWeb.ActiveSkillView

  def render("index.json", %{active_skills: active_skills}) do
    render_many(active_skills, ActiveSkillView, "skill.json")
  end

  def render("show.json", %{active_skill: active_skill}) do
    render_one(active_skill, ActiveSkillView, "skill.json")
  end

  def render("skill.json", %{active_skill: active_skill}), do: skill_json(active_skill)

  def skill_json(active_skill) do
    %{
      id: active_skill.id,
      name: active_skill.name,
      up_is_good: active_skill.up_is_good,
      increase_per_point: active_skill.increase_per_point
    }
  end
end
