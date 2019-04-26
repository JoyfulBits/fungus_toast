defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.{Games, Players}

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => _, "player_id" => player_id}) do
    player_skills =
      Games.get_player_skills(player_id)
      |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])

    render(conn, "index.json", player_skills: player_skills)
  end

  def update(conn, %{
        "game_id" => game_id,
        "player_id" => player_id,
        "skill_upgrades" => upgrade_attrs
      }) do


    result = Games.spend_human_player_mutation_points(player_id, game_id, upgrade_attrs)

    render(conn, "player_skill_update.json", model: result)
  end
end
