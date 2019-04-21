defmodule FungusToastWeb.PlayerSkillUpdateView do
  use FungusToastWeb, :view

  def render("player_skill_update.json", model), do: spent_skills_json(model)

  defp spent_skills_json(%{next_round_available: new_round, updated_player: updated_player}) do
    %{
      next_round_available: new_round,
      updated_player: FungusToastWeb.GameView.player_json(updated_player)
    }
  end
end
