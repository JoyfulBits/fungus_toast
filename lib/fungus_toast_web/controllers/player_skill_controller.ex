defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => _, "player_id" => player_id}) do
    player_skills = Games.get_player_skills(player_id) |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
    render(conn, "index.json", player_skills: player_skills)
  end

  def update(conn, %{"player_id" => player_id, "skillExpenditure" => skill_params}) do
    Game.update_player_skills(player_id, skill_params)
    # with {:ok, player_skill} <- Games.update_player_skill(skill, skill_params) do
    # player_skill = player_skill |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
    # render(conn, "show.json", player_skill: player_skill)
    #end
  end
end
