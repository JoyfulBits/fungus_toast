defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => _, "player_id" => player_id}) do
    player_skills = Games.get_player_skills(player_id) |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
    render(conn, "index.json", player_skills: player_skills)
  end

  def update(conn, %{"player_id" => player_id, "skill_upgrades" => upgrade_attrs}) do
    with {:ok, player_skills} <- Games.update_player_skills(player_id, upgrade_attrs) do
      player_skills = player_skills |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
      render(conn, "show.json", player_skills: player_skills)
    end
  end
end
