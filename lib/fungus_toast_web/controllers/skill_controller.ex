defmodule FungusToastWeb.SkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Skills

  action_fallback FungusToastWeb.FallbackController

  def index(conn, _) do
    skills = Skills.list_skills()
    render(conn, "index.json", skills: skills)
  end
end
