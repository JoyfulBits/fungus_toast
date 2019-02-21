defmodule FungusToastWeb.PlayerSkillController do
  use FungusToastWeb, :controller

  alias FungusToast.Games

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

      player
      |> Games.update_player(%{mutation_points: player.mutation_points - spent_points})

      game = Games.get_game!(game_id) |> FungusToast.Repo.preload(:players)
      new_round = Games.next_round_available?(game)

      if(new_round) do
        Games.trigger_next_round(game_id)
      end
      
      # How can we do this with Jason? It wants a struct and we don't have one here
      json(conn, %{nextRoundAvailable: new_round})
    end
  end
end
