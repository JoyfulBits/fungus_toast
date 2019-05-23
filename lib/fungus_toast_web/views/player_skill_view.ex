defmodule FungusToastWeb.PlayerSkillView do
  use FungusToastWeb, :view
  alias FungusToastWeb.PlayerSkillView

  def render("index.json", %{player_skills: player_skills}) do
    render_many(player_skills, PlayerSkillView, "player_skill.json")
  end

  def render("player_skill.json", %{player_skill: player_skill}), do: map_from(player_skill)

  def render("player_skill_update.json", %{model: model}), do: spent_skills_json(model)

  def render("illegal_points_spent.json", _) do
    %{ debug_error_message: "User attempted to spend more mutation points than were available"}
  end

  defp spent_skills_json(%{next_round_available: new_round, updated_player: updated_player}) do
    %{
      next_round_available: new_round,
      updated_player: FungusToastWeb.GameView.player_json(updated_player)
    }
  end
end
