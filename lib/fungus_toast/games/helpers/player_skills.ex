defmodule FungusToast.PlayerSkills do
  @moduledoc """
  The PlayerSkills helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games.{Game, Player, PlayerSkill, Skill}

  def get_player_skill!(id), do: Repo.get!(PlayerSkill, id)

  def get_player_skills(%Player{} = player) do
    get_player_skills(player.id)
  end
  def get_player_skills(player_id) do
    from(ps in PlayerSkill, where: ps.player_id == ^player_id) |> Repo.all()
  end

  def create_player_skill(player, skill, attrs \\ %{})
  def create_player_skill(%Player{} = player, %Skill{} = skill, attrs) when is_map(attrs) do
    create_player_skill(player.id, skill.id, attrs)
  end
  def create_player_skill(player_id, skill_id, attrs) when is_map(attrs) do
    %PlayerSkill{player_id: player_id, skill_id: skill_id}
    |> PlayerSkill.changeset(attrs)
    |> Repo.insert()
  end

  # TODO: support updating a list of skills?
  # TODO: figure out a way to convert a single request into updates of many skills
  # Maybe create one copy of each skill when a player is created, set it to level 0

  def update_player_skill(%PlayerSkill{} = player_skill, attrs) do
    player_skill
    |> PlayerSkill.changeset(attrs)
    |> Repo.update()
  end
end
