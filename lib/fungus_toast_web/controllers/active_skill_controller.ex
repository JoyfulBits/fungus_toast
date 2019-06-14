defmodule FungusToastWeb.ActiveSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.ActiveSkills

  action_fallback FungusToastWeb.FallbackController

  def index(conn, _) do
    skills = ActiveSkills.list_skills()
    render(conn, "index.json", skills: skills)
  end
end
