defmodule FungusToast.Players do
  @moduledoc """
  The Players helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Accounts
  alias FungusToast.Accounts.User
  alias FungusToast.Games
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

      iex> list_players_for_game(1)
      [%Player{}, ...]

  """
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

  # TODO: Document this
  def get_player_for_game(%Game{} = game, id) do
    get_player_for_game(game.id, id)
  end

  def get_player_for_game(game_id, id) do
    from(p in Player, where: p.id == ^id and p.game_id == ^game_id) |> Repo.one()
  end

  defp get_ai_player_count() do
    from(p in Player, where: p.human == false, select: count(p.id)) |> Repo.one()
  end

  @doc """
  Creates the requested number of AI players for the given game
  """
  def create_ai_players(_, 0) do
    :ok
  end

  @doc """
  Creates a player for the given user and game
  """
  @spec create_player_for_user(%Game{}, String.t()) :: %Player{}
  def create_player_for_user(game = %Game{}, user_name) do
    user = Accounts.get_user_for_name(user_name)
    %Player{game_id: game.id, human: true, user_id: user.id, name: user.user_name}
    |> Player.changeset(%{})
    |> Repo.insert()
  end

  @doc """
  Creates the requested number of AI players for the given game. AI players have no user associated with them
  """
  @spec create_ai_players(%Game{}) :: %Player{}
  def create_ai_players(game) do
    Enum.map(1..game.number_of_ai_players, fn x -> 
      %Player{game_id: game.id, human: false, name: "Fungal Mutation #{x}"}
      |> Player.changeset(%{})
      |> Repo.insert()
    end)
  end

  @doc """
  Creates the requested number of yet unknown human players for the given game.
  """
  @spec create_human_players(%Game{}, integer()) :: %Player{}
  def create_human_players(game, number_of_human_players) do
    Enum.each(1..number_of_human_players, fn x -> 
      %Player{game_id: game.id, human: true}
      |> Player.changeset(%{})
      |> Repo.insert()
    end)
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
