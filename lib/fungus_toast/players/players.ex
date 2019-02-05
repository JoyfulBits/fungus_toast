defmodule FungusToast.Players do
  @moduledoc """
  The Players context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Accounts
  alias FungusToast.Accounts.User
  alias FungusToast.Players.Player

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

      iex> create_player(user, %{field: value})
      {:ok, %Player{}}

      iex> create_player(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_player(1, %{field: value})
      {:ok, %Player{}}

      iex> create_player(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(user, attrs \\ %{})
  def create_player(%User{} = user, attrs) when is_map(attrs) do
    attrs =
      attrs |> Map.put(:name, user.user_name)
    create_player(user.id, attrs)
  end
  def create_player(user_id, attrs) when is_map(attrs) do
    #TODO: Find a better way to do this check
    attrs = if Map.has_key?(attrs, :name) do
              attrs
            else
              user = Accounts.get_user!(user_id)
              Map.put(attrs, :name, user.user_name)
            end

    %Player{user_id: user_id}
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
