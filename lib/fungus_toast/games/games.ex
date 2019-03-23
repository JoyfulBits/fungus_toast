defmodule FungusToast.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.{Accounts, Players, PlayerSkills, Rounds, Skills}
  alias FungusToast.Accounts.User
  alias FungusToast.Games.Game
  alias FungusToast.Games.GameState
  alias FungusToast.Games.Grid
  alias FungusToast.Games.Round
  alias FungusToast.Games.GrowthCycle

  @starting_mutation_points 5

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
      |> preload_for_games

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
  def get_game!(id), do: Repo.get!(Game, id) |> preload_for_games()

  @doc """
  Creates a game.

  ## Examples

      iex> create_game("testUser", %{field: value})
      {:ok, %Game{}}

      iex> create_game("testUser", %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  #TODO Dave says there may be some opportunities here... need to run all updates in a transaction, and pulling values from the attrs might be odd
  def create_game(user_name, attrs) do
    attrs = if(Map.get(attrs, :number_of_human_players) < 2) do
      Map.put(attrs, :status, "Started")
    else
      attrs
    end
    changeset = %Game{} |> Game.changeset(attrs)

    with {:ok, game} <- create_game_for_user(changeset, user_name) do
      start_game(game)
      preloaded_game = get_game!(game.id) |> preload_for_games()

      {:ok, preloaded_game}
    end
  end

  def start_game(game = %Game{players: players, grid_size: grid_size, number_of_human_players: number_of_human_players}) do
      if(number_of_human_players == 1) do
        player_ids = Enum.map(players, fn(x) -> x.id end)
        starting_cells = Grid.create_starting_grid(grid_size, player_ids)
        #create the first round with an empty starting_game_state and toast changes for the initial cells
        mutation_points_earned = get_starting_mutation_points(players)
        growth_cycle = %GrowthCycle{ mutation_points_earned: mutation_points_earned }
        first_round = %{number: 0, growth_cycles: [growth_cycle], starting_game_state: %GameState{cells: %{}, round_number: 0}}
        #create the second round with a starting_game_state but no state change yet
        second_round = %{number: 1, starting_game_state: starting_cells}

        Rounds.create_round(game.id, first_round)
        Rounds.create_round(game.id, second_round)
      end
  end

  def get_starting_mutation_points(players) do
    Enum.map(players, fn player -> %{player.id => @starting_mutation_points} end)
      |> Enum.reduce(fn (x, acc) -> Map.merge(x, acc) end)
  end

  def create_game_for_user(game_changeset, user_name) when is_binary(user_name) do
    Repo.transaction(fn ->
      {:ok, game} = Repo.insert(game_changeset)

      Players.create_player_for_user(game, user_name)
      Players.create_human_players(game, game.number_of_human_players - 1)
      Players.create_ai_players(game)

      Repo.get(Game, game.id) |> Repo.preload(:players)
    end)
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
  defp preload_for_games(games) do
    games |> Repo.preload([:rounds, players: [skills: :skill]])
  end

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
    game
      |> Map.put(:next_round_available, next_round_available?(game))
      |> Map.put(:latest_round, get_latest_round_for_game(game.id))
  end

  @doc """
  Returns whether or not all human players have spent their mutation points
  """
  def next_round_available?(%Game{} = game_with_players) do
    game_with_players.players
    |> Enum.filter(fn p -> Map.get(p, :human) end)
    |> Enum.all?(fn p -> Map.get(p, :mutation_points) == 0 end)
  end

  @doc """
  Executes a full round of growth cycles and creates a new round for this game
  """
  def trigger_next_round(game) do
    latest_round = get_latest_round_for_game(game.id)

    current_game_state = latest_round.starting_game_state["cells"]
    players = game.players
    player_id_to_player_map = players
      |> Map.new(fn x -> {x.id, x} end)

    Enum.filter(players, fn player -> !player.human end)
      |> (fn player -> Players.spend_ai_mutation_points(player, player.mutation_points) end).()

    growth_summary = Grid.generate_growth_summary(current_game_state, game.grid_size, player_id_to_player_map)

    #set the growth cycles on the latest around
    latest_round = Rounds.get_latest_round_for_game(game)
      |> Rounds.update_round(%{growth_cycles: growth_summary.growth_cycles})

    #set up the new round with only the starting game state
    next_round = %Round{number: latest_round.number + 1, starting_game_state: growth_summary.new_game_state}
    Rounds.create_round(game.id, next_round)
  end

  defdelegate get_latest_round_for_game(game), to: Rounds

  def get_round!(id) do
    alias FungusToast.Games.Round
    Repo.get!(Round, id) |> Repo.preload(:game)
  end

  defdelegate create_round(game, attrs), to: Rounds

  defdelegate list_players_for_game(game), to: Players
  defdelegate get_player_for_game(game_id, id), to: Players
  defdelegate get_player!(id), to: Players
  defdelegate update_player(player, attrs), to: Players

  defdelegate get_player_skills(player), to: PlayerSkills
  defdelegate sum_skill_upgrades(skill_upgrades), to: PlayerSkills
  defdelegate update_player_skills(player, attrs), to: PlayerSkills
  defdelegate update_player_skill(player_skill, attrs), to: PlayerSkills

  defdelegate create_skill(attrs), to: Skills
end
