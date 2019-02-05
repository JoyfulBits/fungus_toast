defmodule FungusToast.Players do
  @moduledoc """
  The Games.context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Accounts.User
  alias FungusToast.Games.{Game, Player}

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Returns the list of players for a given user.

  ## Examples

      iex> list_players_for_user(%User{})
      [%Player{}, ...]

      iex> list_players_for_user(1)
      [%Player{}, ...]

  """
  def list_players_for_user(%User{} = user) do
    list_players_for_user(user.id)
  end
  def list_players_for_user(user_id) do
    from(p in Player, where: p.user_id == ^user_id) |> Repo.all()
  end

  @doc """
  Returns the list of players for a given game.

  ## Examples

      iex> list_players_for_game(%Game{})
      [%Player{}, ...]

      iex> list_players_for_game(1)
      [%Player{}, ...]

  """
  def list_players_for_game(%Game{} = game) do
    list_players_for_game(game.id)
  end
  def list_players_for_game(game_id) do
    from(p in Player, where: p.game_id == ^game_id) |> Repo.all()
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(game, user, %{field: value})
      {:ok, %Player{}}

      iex> create_player(game, user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_player(1, 1, %{field: value})
      {:ok, %Player{}}

      iex> create_player(1, 1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(game, user, attrs \\ %{})
  def create_player(%Game{} = game, %User{} = user, attrs) when is_map(attrs) do
    create_player(game.id, user.id, attrs)
  end
  def create_player(game_id, user_id, attrs) when is_map(attrs) do
    %Player{game_id: game_id, user_id: user_id}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{source: %Player{}}

  """
  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end
end
