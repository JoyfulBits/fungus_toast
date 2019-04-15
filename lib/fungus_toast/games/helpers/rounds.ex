defmodule FungusToast.Rounds do
  @moduledoc """
    A helper for Round management
  """
  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.Games.{Game, Round}

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

    iex> get_latest_round_for_game(game)
    %{:ok, %Round{}}

    iex> get_latest_round_for_game(1)
    %{:ok, %Round{}}

  """
  def get_latest_round_for_game(%Game{} = game) do
    get_latest_round_for_game(game.id)
  end

  @doc """
  Gets the most recent completed round (including growth) for the specified game.
  """
  def get_latest_round_for_game(game_id) do
    from(r in Round, where: r.game_id == ^game_id, order_by: [desc: r.number], limit: 1)
    |> Repo.one()
  end

  def get_latest_completed_round_for_game(game_id) do
    from(r in Round, where: r.game_id == ^game_id and r.growth_cycles != [], order_by: [desc: r.number], limit: 1)
    |> Repo.one()
  end

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

  def create_round(%Game{} = game, attrs) when is_map(attrs) do
    create_round(game.id, attrs)
  end

  def create_round(game_id, attrs) when is_binary(game_id) do
    create_round(game_id, attrs)
  end

  def create_round(game_id, attrs) when is_map(attrs) do
    {:ok, round} = %Round{game_id: game_id}
    |> Round.changeset(attrs)
    |> Repo.insert()

    round
  end

  def update_round(%Round{} = round, attrs) do
    {:ok, round} = round
    |> Round.changeset(attrs)
    |> Repo.update()

    round
  end
end
