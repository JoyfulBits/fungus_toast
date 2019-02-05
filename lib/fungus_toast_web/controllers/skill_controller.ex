defmodule FungusToastWeb.SkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Games
  alias FungusToast.Games.Skill

  action_fallback FungusToastWeb.FallbackController

  def index(conn, _params) do
    skills = Games.list_skills()
    render(conn, "index.json", skills: skills)
  end

  def create(conn, %{"skill" => skill_params}) do
    with {:ok, %Skill{} = skill} <- Games.create_skill(skill_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.skill_path(conn, :show, skill))
      |> render("show.json", skill: skill)
    end
  end

  def show(conn, %{"id" => id}) do
    skill = Games.get_skill!(id)
    render(conn, "show.json", skill: skill)
  end

  def update(conn, %{"id" => id, "skill" => skill_params}) do
    skill = Games.get_skill!(id)

    with {:ok, %Skill{} = skill} <- Games.update_skill(skill, skill_params) do
      render(conn, "show.json", skill: skill)
    end
  end

  def delete(conn, %{"id" => id}) do
    skill = Games.get_skill!(id)

    with {:ok, %Skill{}} <- Games.delete_skill(skill) do
      send_resp(conn, :no_content, "")
    end
  end
end
