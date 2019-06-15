defmodule FungusToastWeb.ActiveSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.ActiveSkills

  action_fallback FungusToastWeb.FallbackController

  def index(conn, _) do
    active_skills = ActiveSkills.list_skills()
    render(conn, "index.json", active_skills: active_skills)
  end
end
