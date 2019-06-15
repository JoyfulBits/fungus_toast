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
      description: active_skill.description,
      minimum_round: active_skill.minimum_round,
      number_of_toast_changes: active_skill.number_of_toast_changes
    }
  end
end
