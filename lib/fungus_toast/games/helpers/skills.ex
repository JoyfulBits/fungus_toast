defmodule FungusToast.Skills do
  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games.Skill

  def skill_id_hypermutation, do: 1
  def skill_id_budding, do: 2
  def skill_id_anti_apoptosis, do: 3
  def skill_id_regeneration, do: 4
  def skill_id_mycotoxicity, do: 5
  def skill_id_hydrophilia, do: 6
  def skill_id_spores, do: 7

  #TODO this should come from the database instead of being hard-coded here
  defp skill_to_number_of_active_changes_map, do: %{
    skill_id_hypermutation() => 0,
    skill_id_budding() => 0,
    skill_id_anti_apoptosis() => 0,
    skill_id_regeneration() => 0,
    skill_id_mycotoxicity() => 0,
    skill_id_hydrophilia() => 0,
    skill_id_spores() => 0
  }

  def get_allowed_number_of_active_changes(skill_id) when is_integer(skill_id) do
    Map.get(skill_to_number_of_active_changes_map(), skill_id)
  end

  def get_allowed_number_of_active_changes(skill_id) when is_binary(skill_id) do
    Map.get(skill_to_number_of_active_changes_map(), String.to_integer(skill_id))
  end

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    Repo.all(Skill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill_by_name("Budding")
      %Skill{}

      iex> get_skill_by_name("invalid")
      ** (Ecto.NoResultsError)

  """
  def get_skill_by_name(name) do
    from(s in Skill, where: s.name == ^name) |> Repo.one
  end

  @doc """
  Gets a single skill (using an integer skill id)

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id) when is_integer(id) do
    Repo.get!(Skill, id)
  end

  @doc """
  Gets a single skill (using a string skill id)

  Raises `Ecto.NoResultsError` if the Skill does not exist.
  """
  def get_skill!(id) when is_binary(id) do
    Repo.get!(Skill, String.to_integer(id))
  end

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    Repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{source: %Skill{}}

  """
  def change_skill(%Skill{} = skill) do
    Skill.changeset(skill, %{})
  end
end
