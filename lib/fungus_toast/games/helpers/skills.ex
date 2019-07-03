defmodule FungusToast.Skills do
  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games.{Skill, SkillPrerequisite}

  def skill_id_hypermutation, do: 1
  def skill_id_budding, do: 2
  def skill_id_anti_apoptosis, do: 3
  def skill_id_regeneration, do: 4
  def skill_id_mycotoxicity, do: 5
  def skill_id_hydrophilia, do: 6
  def skill_id_spores, do: 7
  def skill_id_regenerating_spores, do: 8

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
  """
  def create_skill(attrs \\ %{}) do
    {:ok, skill} = %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()

    skill
  end

  @doc """
  Updates a skill.
  """
  def update_skill(%Skill{} = skill, attrs) do
    {:ok, updated_skill} = skill
    |> Skill.changeset(attrs)
    |> Repo.update()

    updated_skill
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

  def create_skill_prerequisite(changes = %{skill_id: _, required_skill_id: _, required_skill_level: _}) do
    {:ok, skill_prerequisite} = %SkillPrerequisite{}
    |> SkillPrerequisite.changeset(changes)
    |> Repo.insert()

    skill_prerequisite
  end
end
