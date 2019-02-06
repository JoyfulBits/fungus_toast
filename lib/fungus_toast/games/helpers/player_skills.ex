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

  # TODO: Make sure players do not overspend points
  def update_player_skills(%Player{} = player, attrs) when map_size(attrs) > 0 do
    name_id_map = %{
      "hypermutation_points" => 1,
      "budding_points" => 2,
      "anti_apoptosis_points" => 3,
      "regeneration_points" => 4,
      "mycotoxicity_points" => 5
    }

    skill =
      attrs
      |> Map.keys()
      |> List.first()
    # TODO: Protect this somehow. If a skill cannot be found, move on to the next iteration
    skill_id = Map.get(name_id_map, skill)
    points_spent =
      attrs
      |> Map.pop(skill)
      |> elem(0)

    # TODO: Add a guard against skills where no points were spent? It would be more efficient, but not necessary
    case player_skill = get_player_skill(player, skill_id) do
      nil ->
        create_player_skill(player.id, skill_id, %{skill_level: points_spent})
      _ ->
        update_player_skill(player_skill, %{skill_level: player_skill.skill_level + points_spent})
    end
    update_player_skills(player, attrs |> Map.pop(skill) |> elem(1))
  end
  def update_player_skills(%Player{} = player, %{}) do
    nil
  end
  def update_player_skills(player_id, attrs) do
    player = Games.get_player!(player_id) |> Repo.preload(:skills)
    update_player_skills(player, attrs)
  end

  def update_player_skill(%PlayerSkill{} = player_skill, attrs) do
    player_skill
    |> PlayerSkill.changeset(attrs)
    |> Repo.update()
  end
end
