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
  Returns a list of games for a given user. The "active" parameter determines which games are returned
  """
  def list_games_for_user(%User{} = user),
    do: list_games_for_user(user, ["Started", "Not Started"])

  def list_games_for_user(%User{} = user, true), do: list_games_for_user(user, ["Started"])
  def list_games_for_user(%User{} = user, false), do: list_games_for_user(user)
  def list_games_for_user(%User{} = user, nil), do: list_games_for_user(user)

  def list_games_for_user(%User{} = user, statuses) when is_list(statuses) do
    user = user |> Repo.preload(players: :game)

    games =
      user.players
      |> Enum.map(fn p -> p.game end)
      |> Enum.filter(fn g -> Enum.member?(statuses, g.status) end)

    {:ok, games}
  end

  def list_games_for_user(user_id, active) when is_boolean(active) do
    user = Accounts.get_user!(user_id)
    list_games_for_user(user, active)
  end

  def list_games_for_user(_, _) do
    {:error, :bad_request}
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

    with {:ok, game} <- create_game_for_user(changeset, user_name) do
      human_player_count =
        Map.get(attrs, :number_of_human_players) || Map.get(attrs, "number_of_human_players")

      ai_player_count =
        Map.get(attrs, :number_of_ai_players) || Map.get(attrs, "number_of_ai_players") || 0

      game
      |> Players.create_ai_players(ai_player_count)

      game
      |> set_new_game_status(human_player_count)
    end
  end

  # This is a special case to avoid creating human players with our AI user.
  # AI users should also just not be able to create games in general.
  # If we move the "human" flag to User, we could do away with this and use
  # the user's value on line 85, but I don't expect us to need multipl AI users yet
  def create_game_for_user(_, "Fungusmotron") do
    {:error, :bad_request}
  end

  def create_game_for_user(changeset, %User{} = user) do
    with {:ok, game} <- Repo.insert(changeset) do
      # TODO: Handle the case where a round is not created
      create_round(game, %{number: 1})

      game
      |> Players.create_player(%{human: true, user_name: user.user_name, name: user.user_name})

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

  defp set_new_game_status(game, 1) do
    update_game(game, %{status: "Started"})
  end

  defp set_new_game_status(game, human_player_count) when human_player_count > 0 do
    {:ok, game}
  end

  defp set_new_game_status(_, _) do
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

  @doc """
  Preloads the necessary data for games
  """
  def preload_for_games(games) do
    games |> Repo.preload([:rounds, players: [skills: :skill]])
  end

  # TODO: consider moving to Games.Logic?
  @doc """
  Adds any extra fields necessary for representing games
  """
  def decorate_games(%Game{} = game), do: decorate_game(game)

  def decorate_games(games) when is_list(games) do
    decorate_games(games, [])
  end

  def decorate_games([head | tail], accum) do
    decorated_game = head |> decorate_game()
    decorate_games(tail, [decorated_game | accum])
  end

  def decorate_games([], accum) do
    Enum.reverse(accum)
  end

  defp decorate_game(%Game{} = game) do
    game |> Map.put(:next_round_available, next_round_available?(game))
  end

  @doc """
  Returns whether or not all human players have spent their mutation points
  """
  def next_round_available?(%Game{} = game) do
    game.players
    |> Enum.filter(fn p -> Map.get(p, :human) end)
    |> Enum.all?(fn p -> Map.get(p, :mutation_points) == 0 end)
  end

  def get_round!(id) do
    alias FungusToast.Games.Round
    Repo.get!(Round, id) |> Repo.preload(:game)
  end

  defdelegate create_round(game, attrs), to: Rounds

  defdelegate list_players_for_game(game), to: Players
  defdelegate get_player_for_game(game_id, id), to: Players
  defdelegate get_player!(id), to: Players
  defdelegate create_player(game, attrs), to: Players
  defdelegate update_player(player, attrs), to: Players

  defdelegate get_player_skills(player), to: PlayerSkills
  defdelegate sum_skill_upgrades(skill_upgrades), to: PlayerSkills
  defdelegate update_player_skills(player, attrs), to: PlayerSkills
  defdelegate update_player_skill(player_skill, attrs), to: PlayerSkills

  defdelegate create_skill(attrs), to: Skills
end
