defmodule FungusToast.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.{Players, PlayerSkills, Rounds, Skills}
  alias FungusToast.Accounts.User
  alias FungusToast.Games.{Game, GameState, Grid, Round, GrowthCycle, MutationPointsEarned}
  alias FungusToast.Game.Status

  @starting_mutation_points 5
  @starting_end_of_game_count_down 5
  def starting_end_of_game_count_down, do: @starting_end_of_game_count_down

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
  def list_active_games_for_user(%User{} = user),
    do: list_games_for_user(user, Status.active_statuses)

  def list_games_for_user(%User{} = user, statuses) when is_list(statuses) do
    user = user |> Repo.preload(players: :game)

    games =
      user.players
      |> Enum.map(fn p -> p.game end)
      |> Enum.filter(fn g -> Enum.member?(statuses, g.status) end)
      |> preload_for_games

    {:ok, games}
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
  def get_game!(id) do
    Repo.get!(Game, id) |> preload_for_games()
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game("testUser", %{field: value})
      %Game{}

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

    game = create_game_for_user(changeset, user_name)

    if(start_game(game)) do
      get_game!(game.id)
    else
      game
    end
  end

  def start_game(game = %Game{id: _, players: players, grid_size: grid_size, number_of_human_players: number_of_human_players}) do
      if(number_of_human_players <= 1) do
        player_ids = Enum.map(players, fn(x) -> x.id end)
        starting_cells = Grid.create_starting_grid(grid_size, player_ids)
        #create the first round with an empty starting_game_state and toast changes for the initial cells
        mutation_points_earned = get_starting_mutation_points(players)
        growth_cycle = %GrowthCycle{ mutation_points_earned: mutation_points_earned }
        first_round_values = %{number: 0, growth_cycles: [growth_cycle], starting_game_state: %GameState{cells: [], round_number: 0}}
        #create the second round with a starting_game_state but no state change yet
        second_round = %{number: 1, growth_cycles: [], starting_game_state: %GameState{cells: starting_cells, round_number: 1}}

        Rounds.create_round(game.id, first_round_values)
        Rounds.create_round(game.id, second_round)

        update_aggregate_stats(game, starting_cells)
        true
      else
        false
      end
  end

  def update_aggregate_stats(game = %Game{players: players}, cells) do
    stats_map = Enum.reduce(players, %{}, fn player, acc ->
      Map.put(acc, player.id, %{live_cells: 0, dead_cells: 0})
    end)

    stats_map = Enum.reduce(cells, stats_map, fn grid_cell, acc ->
      if(grid_cell.live) do
        update_in(acc, [grid_cell.player_id, :live_cells], &(&1 + 1))
      else
        update_in(acc, [grid_cell.player_id, :dead_cells], &(&1 + 1))
      end
    end)

    total_live_and_dead_cells = get_live_and_dead_cell_aggregates(stats_map)

    updated_players = update_players_aggregate_stats(players, stats_map)

    updated_game = update_game(game, %{
      total_live_cells: total_live_and_dead_cells.total_live_cells,
      total_dead_cells: total_live_and_dead_cells.total_dead_cells})
    {updated_game, updated_players}
  end

  defp get_live_and_dead_cell_aggregates(stats_map) do
    total_live_cells = Enum.reduce(stats_map, 0, fn {_k, v}, acc ->
      acc + v.live_cells
    end)

    total_dead_cells = Enum.reduce(stats_map, 0, fn {_k, v}, acc ->
      acc + v.dead_cells
    end)

    %{total_live_cells: total_live_cells, total_dead_cells: total_dead_cells}
  end

  defp update_players_aggregate_stats(players, stats_map) do
    Enum.map(players, fn player ->
      player_stats = Enum.filter(stats_map, fn {player_id, _} -> player_id == player.id end)
      player_live_and_dead_cells = get_live_and_dead_cell_aggregates(player_stats)
      Players.update_player(player, %{
        live_cells: player_live_and_dead_cells.total_live_cells,
        dead_cells: player_live_and_dead_cells.total_dead_cells})
    end)
  end

  def get_starting_mutation_points(players) do
    Enum.map(players, fn player -> %MutationPointsEarned{player_id: player.id, mutation_points: @starting_mutation_points} end)
  end

  def create_game_for_user(game_changeset, user_name) when is_binary(user_name) do
    {:ok, game} = Repo.transaction(fn ->
      {:ok, game} = Repo.insert(game_changeset)

      Players.create_player_for_user(game, user_name)
      Players.create_human_players(game, game.number_of_human_players - 1)
      Players.create_ai_players(game)

      get_game!(game.id)
    end)

    game
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      game

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    {:ok, game} = game
    |> Game.changeset(attrs)
    |> Repo.update()

    game
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game!(game)
      game

      iex> delete_game!(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game!(%Game{} = game) do
    Repo.delete!(game)
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

  #Preloads the necessary data for games
  defp preload_for_games(games) do
    games |> Repo.preload([players: [skills: :skill]])
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
  Returns whether or not all players have spent their mutation points
  """
  def next_round_available?(%Game{players: players}) do
    players
    |> Enum.all?(fn player -> player.mutation_points == 0 end)
  end

  @doc """
  Executes a full round of growth cycles and creates a new round for this game
  """
  def trigger_next_round(%Game{players: players} = game) do
    player_id_to_player_map = players
      |> Map.new(fn x -> {x.id, x} end)

    total_cells = game.grid_size * game.grid_size
    total_remaining_cells = Game.number_of_empty_cells(game)
    ai_players = Enum.filter(players, fn player -> !player.human end)
    Enum.each(ai_players, fn player ->
        Players.spend_ai_mutation_points(player, player.mutation_points, total_cells, total_remaining_cells)
      end)

    #generate a new growth summary
    latest_round = get_latest_round_for_game(game.id)
    current_game_state = latest_round.starting_game_state

    starting_grid_map = Enum.into(current_game_state.cells, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
    growth_summary = Grid.generate_growth_summary(starting_grid_map, game.grid_size, player_id_to_player_map)

    #set the growth cycles on the latest around
    latest_round = Rounds.get_latest_round_for_game(game)
      |> Rounds.update_round(%{growth_cycles: growth_summary.growth_cycles})

    update_players_for_growth_cycles(players, growth_summary.growth_cycles)

    {updated_game, _} = update_aggregate_stats(game, growth_summary.new_game_state)

    updated_game = check_for_game_end(updated_game)

    if(updated_game.status != Status.status_finished) do
      #set up the new round with only the starting game state
      next_round_number = latest_round.number + 1
      next_round = %{number: next_round_number, growth_cycles: [], starting_game_state: %GameState{round_number: next_round_number, cells: growth_summary.new_game_state}}
      Rounds.create_round(game.id, next_round)
    end
  end

  defp check_for_game_end(game) do
    if(game.end_of_game_count_down != nil) do
      new_count_down_value = game.end_of_game_count_down - 1
      new_game_status = if(new_count_down_value > 0) do
        Status.status_started
      else
        Status.status_finished
      end
      update_game(game, %{end_of_game_count_down: game.end_of_game_count_down - 1, status: new_game_status})
    else
      if(Game.number_of_empty_cells(game) <= 0) do
        update_game(game, %{end_of_game_count_down: @starting_end_of_game_count_down})
      else
        game
      end
    end
  end

  defp update_players_for_growth_cycles(players, growth_cycles) do
    player_to_mutation_points_map = Enum.map(players, fn player -> {player.id, 0} end)
    |> Enum.into(%{})

    mutation_points_map = Enum.reduce(growth_cycles, player_to_mutation_points_map, fn growth_cycle, acc ->
      mutation_points_earned_map = Enum.map(growth_cycle.mutation_points_earned, fn mutuation_points_earned ->
        {mutuation_points_earned.player_id, mutuation_points_earned.mutation_points}
      end)
      |> Enum.into(%{})

      Map.merge(acc, mutation_points_earned_map, fn _k, v1, v2 -> v1 + v2 end)
    end)

    Enum.each(players, fn player ->
      mutation_points = mutation_points_map[player.id]
      #TODO setting to -1 so there is always an update. What's a better way to do this?
      player = %{player | mutation_points: -1}
      number_of_regenerated_cells = get_number_of_cells_regenerated_during_growth_cycles(player.id, growth_cycles)
      Players.update_player(player, %{mutation_points: mutation_points, regenerated_cells: number_of_regenerated_cells})
    end)
  end

  defp get_number_of_cells_regenerated_during_growth_cycles(player_id, growth_cycles) do
    Enum.reduce(growth_cycles, 0, fn growth_cycle, acc ->
      regenerated_cells_for_player = Enum.filter(growth_cycle.toast_changes, fn grid_cell ->
        grid_cell.live and grid_cell.player_id == player_id and grid_cell.previous_player_id != nil
      end)
      acc + length(regenerated_cells_for_player)
    end)
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
