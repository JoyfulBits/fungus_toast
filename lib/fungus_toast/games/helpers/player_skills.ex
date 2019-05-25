defmodule FungusToast.PlayerSkills do
  @moduledoc """
  The PlayerSkills helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games
  alias FungusToast.Games.{Player, PlayerSkill, Skill}
  alias FungusToast.Skills

  @spec get_default_starting_skills() :: [%PlayerSkill{}, ...]
  def get_default_starting_skills() do
    Skills.list_skills
      |> Enum.map(fn skill -> %PlayerSkill{skill_id: skill.id } end)
  end

  @doc """
  Returns the skill information for a given player.

  ## Examples

      iex> get_player_skill(player, 1)
      %PlayerSkill{}

      iex> get_player_skill(1, 1)
      %PlayerSkill{}

  """
  def get_player_skill(%Player{} = player, skill_id) do
    get_player_skill(player.id, skill_id)
  end

  def get_player_skill(player_id, skill_id) do
    from(ps in PlayerSkill, where: ps.player_id == ^player_id and ps.skill_id == ^skill_id)
    |> Repo.one()
  end

  @doc """
  Returns information about all skills for a given player.

  ## Examples

      iex> get_player_skills(player)
      [%PlayerSkill{}, ...]

      iex> get_player_skills(1)
      [%PlayerSkill{}, ...]

  """
  def get_player_skills(%Player{} = player) do
    get_player_skills(player.id)
  end

  def get_player_skills(player_id) do
    from(ps in PlayerSkill, where: ps.player_id == ^player_id) |> Repo.all()
  end

  @doc """
  Creates a new PlayerSkill mapping a player to a skill with level, etc.

  ## Examples

      iex> create_player_skill(player, skill, %{field: new_value})
      {:ok, %PlayerSkill{}}

      iex> create_player_skill(1, 1, %{field: new_value})
      {:ok, %PlayerSkill{}}

      iex> create_player_skill(player, skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_player_skill(1, 1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player_skill(player, skill, attrs \\ %{})

  def create_player_skill(%Player{} = player, %Skill{} = skill, attrs) when is_map(attrs) do
    create_player_skill(player.id, skill.id, attrs)
  end

  def create_player_skill(player_id, skill_id, attrs) when is_map(attrs) do
    %PlayerSkill{player_id: player_id, skill_id: skill_id}
    |> PlayerSkill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates skill information for a given player, if they have the appropriate number of mutation points.

  ## Examples

      iex> update_player_skills(player, [%{"id": 1, "spent_points": 1}, ...])
      {:ok, [%PlayerSkill{}, ...]}

      iex> update_player_skills(1, [%{"id": 1, "spent_points": 1}, ...])
      {:ok, [%PlayerSkill{}, ...]}

      iex> update_player_skills(player, [%{"id": 1, "spent_points": -1}, ...])
      {:error, :bad_request}

  """
  def update_player_skills(%Player{} = player, skill_upgrades) when is_list(skill_upgrades) do
    valid_request = is_valid_request?(player, skill_upgrades)
    update_player_skills(%Player{} = player, skill_upgrades, [], valid_request)
  end

  def update_player_skills(player_id, skill_upgrades) when is_list(skill_upgrades) do
    player = Games.get_player!(player_id) |> Repo.preload(:skills)
    update_player_skills(player, skill_upgrades)
  end

  def update_player_skills_and_get_player_changes(%Player{} = player, upgrade_attrs) do
    Enum.reduce(upgrade_attrs, %{}, fn {skill_id, map}, acc ->
      points_spent = Map.get(map, "points_spent")

      skill = Skills.get_skill!(skill_id)

      player_skill = get_player_skill(player.id, skill_id)
      update_player_skill(player_skill, %{skill_level: player_skill.skill_level + points_spent})

      skill_change = if(skill.up_is_good, do: skill.increase_per_point * points_spent, else: skill.increase_per_point * points_spent * -1.0)
      attributes_to_update = FungusToast.AiStrategies.get_player_attributes_for_skill_name(skill.name)

      Map.merge(acc, update_attribute(player, skill_change, attributes_to_update, acc))
    end)
  end

  def update_player_skills(%Player{} = player, [head | tail], accum, true) do
    skill_id = head |> Map.get("id")
    points_spent = head |> Map.get("points_spent")

    player_skill = get_player_skill(player, skill_id)

    case create_or_update_player_skill(player, player_skill, skill_id, points_spent) do
      {:ok, updated_player_skill} ->
        update_player_skills(player, tail, [updated_player_skill | accum], true)

      {:error, _} ->
        {:error, :bad_request}
    end
  end

  def update_player_skills(_, [], accum, true) do
    {:ok, Enum.reverse(accum)}
  end

  def update_player_skills(_, _, _, false) do
    {:error, :bad_request}
  end

  defp create_or_update_player_skill(%Player{} = player, nil, skill_id, points_spent)
       when points_spent >= 0 do
    create_player_skill(player.id, skill_id, %{skill_level: points_spent})
  end

  defp create_or_update_player_skill(%Player{} = _, player_skill, _, points_spent)
       when points_spent >= 0 do
    update_player_skill(player_skill, %{skill_level: player_skill.skill_level + points_spent})
  end

  defp create_or_update_player_skill(_, _, _, _) do
    {:error, :bad_request}
  end

  def is_valid_request?(%Player{} = player, skill_upgrades) do
    points_spent = sum_skill_upgrades(skill_upgrades)
    player.mutation_points >= points_spent
  end

  @doc """
  Returns how many mutation points are required for all of the requested skill upgrades

  """
  def sum_skill_upgrades(skill_upgrades) do
    skill_upgrades
    |> Enum.reduce(0, fn {_, map}, acc -> acc + Map.get(map, "points_spent") end)
  end

  @doc """
  Updates a player skill.

  ## Examples

      iex> update_player_skill(player_skill, %{field: new_value})
      {:ok, %PlayerSkill{}}

      iex> update_player_skill(player_skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player_skill(%PlayerSkill{} = player_skill, attrs) do
    player_skill
    |> PlayerSkill.changeset(attrs)
    |> Repo.update()
  end

  #TODO perhaps rename to something like get_player_attribute_changes since this isn't actually updating the player?
  def update_attribute(%Player{} = player, skill_change, attributes, acc) when length(attributes) > 0 do
    [attribute | remaining_attributes] = attributes
    existing_value = Map.get(acc, attribute)
    existing_value =
      if(existing_value == nil) do
        Map.get(player, attribute)
      else
        existing_value
      end
    acc = Map.put(acc, attribute, existing_value + skill_change)
    update_attribute(player, skill_change, remaining_attributes, acc)
  end

  def update_attribute(_player, _skill_change, attributes, acc) when length(attributes) == 0 do
    acc
  end
end
