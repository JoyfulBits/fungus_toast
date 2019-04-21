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
    player = Games.get_player!(player_id)

    with {:ok, _} <- Games.update_player_skills(player, upgrade_attrs) do
      spent_points = Games.sum_skill_upgrades(upgrade_attrs)

      updated_player = Players.update_player(player, %{mutation_points: player.mutation_points - spent_points})

      game = Games.get_game!(game_id)
      new_round = Games.next_round_available?(game)

      if(new_round) do
        Games.trigger_next_round(game)
      end

      render(conn, "player_skill_update.json", model: %{next_round_available: new_round, updated_player: updated_player})
    end
  end
end
