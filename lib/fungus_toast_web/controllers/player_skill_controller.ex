defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => _, "player_id" => player_id}) do
    player_skills = Games.get_player_skills(player_id) |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
    render(conn, "index.json", player_skills: player_skills)
  end

  def update(conn, params) do
    player_id = Map.get(params, "player_id")
    skill_params = Map.pop(params, "player_id") |> elem(1) |> Map.pop("game_id") |> elem(1)

    Games.update_player_skills(player_id, skill_params)
    player_skills = Games.get_player_skills(player_id) |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])
    render(conn, "show.json", player_skills: player_skills)
  end
end
