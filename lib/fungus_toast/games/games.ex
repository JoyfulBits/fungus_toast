defmodule FungusToast.Games do

  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Accounts
  alias FungusToast.Players
  alias FungusToast.Games
  alias FungusToast.Games.{Game, Round}

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
    with {:ok, game} <- Repo.insert(changeset) do
      # TODO: handle the case where a user_name is not passed in
      user = Map.get(attrs, :user_name) || Map.get(attrs, "user_name")
      create_round(game, %{number: 1})
      game = add_player_to_game(game, user)

      {:ok, game}
    end
  end

  defp add_player_to_game(%Game{} = game, user_name) do
    user = Accounts.get_user_for_name(user_name)
    game |> Players.create_player(user, %{human: true, name: user_name})
    game
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

  @doc """
  Returns the list of rounds.

  ## Examples

      iex> list_rounds_for_game(game)
      [%Round{}, ...]

      iex> list_rounds_for_game(1)
      [%Round{}, ...]

  """
  def list_rounds_for_game(%Game{} = game) do
    list_rounds_for_game(game.id)
  end
  def list_rounds_for_game(game_id) do
    from(r in Round, where: r.game_id == ^game_id) |> Repo.all()
  end

  @doc """
  Gets a specific round from a game using the round number.

  ## Examples

    iex> get_round_for_game!(1, 3)
    %{:ok, %Round{}}

  """
  def get_round_for_game!(game_id, round_number) do
    from(r in Round, where: r.game_id == ^game_id and r.number == ^round_number) |> Repo.one()
  end

  @doc """
  Gets the most recent round for the specified game.

  ## Examples

    iex> get_latest_round_for_game(1)
    %{:ok, %Round{}}

  """
  def get_latest_round_for_game(game_id) do
    from(r in Round, where: r.game_id == ^game_id, order_by: [desc: r.number], limit: 1) |> Repo.one()
  end

  @doc """
  Gets a single round.

  Raises `Ecto.NoResultsError` if the Round does not exist.

  ## Examples

      iex> get_round!(123)
      %Round{}

      iex> get_round!(456)
      ** (Ecto.NoResultsError)

  """
  def get_round!(id), do: Repo.get!(Round, id)

  @doc """
  Creates a round.

  ## Examples

      iex> create_round(game, %{field: value})
      {:ok, %Round{}}

      iex> create_round(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_round(1, %{field: value})
      {:ok, %Round{}}

      iex> create_round(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_round(game, attrs \\ %{})
  def create_round(%Game{} = game, attrs) when is_map(attrs) do
    create_round(game.id, attrs)
  end
  def create_round(game_id, attrs) when is_map(attrs) do
    %Round{game_id: game_id}
    |> Round.changeset(attrs)
    |> Repo.insert()
  end
end
