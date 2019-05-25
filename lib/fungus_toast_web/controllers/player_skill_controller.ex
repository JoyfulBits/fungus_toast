defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.{Games}

  action_fallback FungusToastWeb.FallbackController

  def index(conn, %{"game_id" => _, "player_id" => player_id}) do
    player_skills =
      Games.get_player_skills(player_id)
      |> FungusToast.Repo.preload([[player: [skills: :skill]], :skill])

    render(conn, "index.json", player_skills: player_skills)
  end

  #incoming params example:
  # %{
  #   "game_id" => "48",
  #   "player_id" => "50",
  #   "upgrades" => %{
  #     "6" => %{"active_cell_changes" => [1, 2, 3, 4], "points_spent" => 0}
  #   }
  # }
  def update(conn, params) do

    game_id = Map.get(params, "game_id")
    player_id = Map.get(params, "player_id")
    upgrades = Map.get(params, "upgrades")
    result = Games.spend_human_player_mutation_points(player_id, game_id, upgrades)

    case result do
      {:ok, next_round_available: next_round_available, updated_player: updated_player} ->
        render(conn, "player_skill_update.json", model: %{next_round_available: next_round_available, updated_player: updated_player})
      {:error_illegal_number_of_points_spent} ->
        conn
        |> put_status(:bad_request)
        |> render("illegal_points_spent.json", %{})
    end
  end
end
