defmodule FungusToast.ActiveSkills do
  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games.ActiveSkill

  def skill_id_eye_dropper, do: 1
  def number_of_toast_changes_for_eye_dropper, do: 3

  #TODO this should come from the database instead of being hard-coded here
  defp skill_to_number_of_active_changes_map, do: %{
    skill_id_eye_dropper() => number_of_toast_changes_for_eye_dropper()
  }

  def get_allowed_number_of_active_changes(active_skill_id) when is_integer(active_skill_id) do
    Map.get(skill_to_number_of_active_changes_map(), active_skill_id)
  end

  def get_allowed_number_of_active_changes(active_skill_id) when is_binary(active_skill_id) do
    Map.get(skill_to_number_of_active_changes_map(), String.to_integer(active_skill_id))
  end

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%ActiveSkill{}, ...]

  """
  def list_skills do
    Repo.all(ActiveSkill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill_by_name("Eye Dropper")
      %ActiveSkill{}

      iex> get_skill_by_name("invalid")
      ** (Ecto.NoResultsError)

  """
  def get_active_skill_by_name(name) do
    from(s in ActiveSkill, where: s.name == ^name) |> Repo.one
  end

  @doc """
  Gets a single active skill (using an integer skill id)

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_active_skill!(123)
      %ActiveSkill{}

      iex> get_active_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_active_skill!(id) when is_integer(id) do
    Repo.get!(ActiveSkill, id)
  end

  @doc """
  Gets a single active skill (using a string skill id)

  Raises `Ecto.NoResultsError` if the Skill does not exist.
  """
  def get_active_skill!(id) when is_binary(id) do
    Repo.get!(ActiveSkill, String.to_integer(id))
  end

  @doc """
  Creates an active skill.

  ## Examples

      iex> create_active_skill(%{field: value})
      {:ok, %ActiveSkill{}}

      iex> create_active_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_active_skill(attrs \\ %{}) do
    %ActiveSkill{}
    |> ActiveSkill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an active skill.

  ## Examples

      iex> update_active_skill(active_skill, %{field: new_value})
      {:ok, %ActiveSkill{}}

      iex> update_active_skill(active_skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_active_skill(%ActiveSkill{} = active_skill, attrs) do
    active_skill
    |> ActiveSkill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an active skill.

  ## Examples

      iex> delete_active_skill(active_skill)
      {:ok, %ActiveSkill{}}

      iex> delete_active_skill(active_skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_active_skill(%ActiveSkill{} = active_skill) do
    Repo.delete(active_skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_active_skill(active_skill)
      %Ecto.Changeset{source: %ActiveSkill{}}

  """
  def change_active_skill(%ActiveSkill{} = active_skill) do
    ActiveSkill.changeset(active_skill, %{})
  end
end
