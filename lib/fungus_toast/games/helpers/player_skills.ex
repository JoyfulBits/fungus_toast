defmodule FungusToast.PlayerSkills do
  @moduledoc """
  The PlayerSkills helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games
  alias FungusToast.Games.{Player, PlayerSkill, Skill}

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
    from(ps in PlayerSkill, where: ps.player_id == ^player_id and ps.skill_id == ^skill_id) |> Repo.one()
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

  defp create_or_update_player_skill(%Player{} = player, nil, skill_id, points_spent) when points_spent >= 0 do
    create_player_skill(player.id, skill_id, %{skill_level: points_spent})
  end
  defp create_or_update_player_skill(%Player{} = _, player_skill, _,  points_spent) when points_spent >= 0 do
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
    |> Enum.map(fn su -> su |> Map.get("points_spent") end)
    |> Enum.sum
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
end
