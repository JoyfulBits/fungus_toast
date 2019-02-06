defmodule FungusToast.PlayerSkills do
  @moduledoc """
  The PlayerSkills helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games
  alias FungusToast.Games.{Player, PlayerSkill, Skill}

  def get_player_skill(%Player{} = player, skill_id) do
    get_player_skill(player.id, skill_id)
  end
  def get_player_skill(player_id, skill_id) do
    from(ps in PlayerSkill, where: ps.player_id == ^player_id and ps.skill_id == ^skill_id) |> Repo.one()
  end

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
  def update_player_skills(player_id, attrs) when is_number(player_id) do
    player = Games.get_player!(player_id) |> Repo.preload(:skills)
    update_player_skills(player, attrs)
  end
  def update_player_skills(%Player{} = player, attrs) when map_size(attrs) > 0 do
    name_id_map = %{
      "hypermutationPoints" => 1,
      "buddingPoints" => 2,
      "antiApoptosisPoints" => 3,
      "regenerationPoints" => 4,
      "mycotoxicityPoints" => 5
    }

    skill =
      attrs
      |> Map.keys()
      |> List.first()
    skill_id = Map.get(name_id_map, skill)
    points_spent =
      attrs
      |> Map.pop(skill)
      |> elem(0)

    # TODO: convert this into a list that we can return
    case player_skill = get_player_skill(player, skill_id) do
      nil ->
        create_player_skill(player.id, skill_id, %{skill_level: points_spent})
      _ ->
        update_player_skill(player_skill, %{skill_level: player_skill.skill_level + points_spent})
        update_player_skills(player, attrs |> Map.pop(skill) |> elem(1))
    end
  end
  def update_player_skills(%Player{} = player, %{}) do
    nil
  end

  def update_player_skill(%PlayerSkill{} = player_skill, attrs) do
    player_skill
    |> PlayerSkill.changeset(attrs)
    |> Repo.update()
  end
end
