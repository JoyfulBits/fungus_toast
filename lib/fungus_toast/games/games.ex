defmodule FungusToast.Games do

  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.{Accounts, Players, PlayerSkills, Rounds, Skills}
  alias FungusToast.Accounts.User
  alias FungusToast.Games.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Active game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    changeset = %Game{} |> Game.changeset(attrs)
    user_name = Map.get(attrs, :user_name) || Map.get(attrs, "user_name")
    create_game_for_user(changeset, user_name)
  end

  def create_game_for_user(changeset, %User{} = user) do
    with {:ok, game} <- Repo.insert(changeset) do
      # Handle the case where a round is not created
      create_round(game, %{number: 1})
      game |> Players.create_player(%{human: true, user_name: user.user_name, name: user.user_name})

      {:ok, game}
    end
  end
  def create_game_for_user(changeset, user_name) when is_binary(user_name) do
    user = Accounts.get_user_for_name(user_name)
    create_game_for_user(changeset, user)
  end
  def create_game_for_user(_, _) do
    {:error, :bad_request}
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end

  defdelegate list_rounds_for_game(game), to: Rounds
  defdelegate get_round_for_game!(game_id, round_number), to: Rounds
  defdelegate get_latest_round_for_game(game), to: Rounds
  defdelegate get_round!(id), to: Rounds
  defdelegate create_round(game, attrs), to: Rounds

  defdelegate list_players, to: Players
  defdelegate list_players_for_user(user), to: Players
  defdelegate list_players_for_game(game), to: Players
  defdelegate get_player_for_game(game_id, id), to: Players
  defdelegate get_player!(id), to: Players
  defdelegate create_player(game, attrs), to: Players
  defdelegate update_player(player, attrs), to: Players
  defdelegate change_player(player), to: Players

  defdelegate get_player_skill(player, skill_id), to: PlayerSkills
  defdelegate get_player_skills(player), to: PlayerSkills
  defdelegate create_player_skill(player, skill, attrs), to: PlayerSkills
  defdelegate update_player_skills(player, attrs), to: PlayerSkills
  defdelegate update_player_skill(player_skill, attrs), to: PlayerSkills

  defdelegate list_skills, to: Skills
  defdelegate get_skill!(id), to: Skills
  defdelegate create_skill(attrs), to: Skills
  defdelegate update_skill(skill, attrs), to: Skills
  defdelegate delete_skill(skill), to: Skills
  defdelegate change_skill(skill), to: Skills
end
