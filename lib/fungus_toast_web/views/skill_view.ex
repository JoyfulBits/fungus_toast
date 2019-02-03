defmodule FungusToastWeb.SkillView do
  use FungusToastWeb, :view
  alias FungusToastWeb.SkillView

  def render("index.json", %{skills: skills}) do
    render_many(skills, SkillView, "skill.json")
  end

  def render("show.json", %{skill: skill}) do
    render_one(skill, SkillView, "skill.json")
  end

  def render("skill.json", %{skill: skill}) do
    # TODO: Move this into a helper that accepts a struct
    Map.from_struct(skill)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
