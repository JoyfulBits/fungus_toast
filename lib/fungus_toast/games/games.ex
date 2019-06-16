defmodule FungusToast.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias FungusToast.{Repo, Accounts, Players, PlayerSkills, Rounds, ActiveCellChanges}
  alias FungusToast.Accounts.User

  alias FungusToast.Games.{Game, GameState, Grid, Round, GrowthCycle, PointsEarned, Player}
  alias FungusToast.Game.Status

  @starting_end_of_game_count_down 5
  def starting_end_of_game_count_down, do: @starting_end_of_game_count_down

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
  def create_game(user_name, attrs) do
    #since changesets can have only all atoms or all strings, keep it consistent
    attrs = if(Map.get(attrs, "number_of_human_players") < 2) do
      Map.put(attrs, "status", Status.status_started)
    else
      if(Map.get(attrs, :number_of_human_players) < 2) do
        Map.put(attrs, :status, Status.status_started)
      else
        attrs
      end
    end
    changeset = %Game{} |> Game.changeset(attrs)

    {:ok, game} = Repo.transaction(fn ->
      game = create_game_for_user(changeset, user_name)

      if(start_game(game)) do
        get_game!(game.id)
      else
        game
      end
    end)

    game
  end

  def start_game(game = %Game{id: id, players: players, grid_size: grid_size, number_of_human_players: number_of_human_players, number_of_ai_players: number_of_ai_players}) do
    if(number_of_ai_players > 0) do
      total_cells = grid_size * grid_size
      Enum.each(players, fn player ->
        if(!player.human and player.mutation_points > 0) do
          Players.spend_ai_mutation_points(player, player.mutation_points, total_cells, total_cells)
        end
      end)
    end

    number_of_joined_human_players = Players.get_number_of_users_who_joined_game(id)
    if(number_of_joined_human_players == number_of_human_players) do
        player_ids = Enum.map(players, fn(x) -> x.id end)
        starting_cells = Grid.create_starting_grid(grid_size, player_ids)
        #create the first round with an empty starting_game_state and toast changes for the initial cells
        mutation_points_earned = get_starting_mutation_points(players)
        action_points_earned = get_starting_action_points(players)
        growth_cycle = %GrowthCycle{ mutation_points_earned: mutation_points_earned, action_points_earned: action_points_earned, toast_changes: starting_cells }
        first_round_values = %{
          number: 0,
          growth_cycles: [growth_cycle],
          starting_game_state: %GameState{cells: [], round_number: 0}
        }

        {:ok, _} = Repo.transaction(fn ->
          {updated_game, updated_players} = set_starting_game_stats(game, starting_cells)

          #TODO found examples where the number of dead cells on starting player stats is not consistent with what is in the starting game state
          starting_player_stats = Players.make_starting_player_stats(updated_players)

          #create the second round with a starting_game_state but no state change yet
          second_round = %{
            number: 1,
            growth_cycles: [],
            starting_game_state: %GameState{cells: starting_cells, round_number: 1},
            starting_player_stats: starting_player_stats
          }

          Rounds.create_round(game.id, first_round_values)
          Rounds.create_round(game.id, second_round)

          update_game(updated_game, %{status: Status.status_started})
        end)

        true
      else
        false
      end
  end

  def update_players_for_next_round(game = %Game{players: players}, growth_summary) do
    players_live_and_dead_cells_count_map = get_live_and_dead_cells_for_player(players, growth_summary.new_game_state)

    player_to_mutation_points_map = Enum.map(players, fn player -> {player.id, 0} end)
    |> Enum.into(%{})

    mutation_points_map = Enum.reduce(growth_summary.growth_cycles, player_to_mutation_points_map, fn growth_cycle, acc ->
      mutation_points_earned_map = Enum.map(growth_cycle.mutation_points_earned, fn mutuation_points_earned ->
        {mutuation_points_earned.player_id, mutuation_points_earned.points}
      end)
      |> Enum.into(%{})

      Map.merge(acc, mutation_points_earned_map, fn _k, v1, v2 -> v1 + v2 end)
    end)

    action_points_map = Enum.map(players, fn player -> {player.id, player.action_points + PointsEarned.default_action_points_per_round()} end)
    |> Enum.into(%{})

    player_ids = Enum.map(players, fn player -> player.id end)
    #get all of the delta attributes like grown and perished cells (etc.)
    player_growth_cycle_stats_map = Grid.get_player_growth_cycles_stats(player_ids, growth_summary.growth_cycles)

    #merge the stats that are a function of the current toast (e.g. live cells) vs. the stats that are more transient (e.g. perished cells)
    new_players_stats_map = Enum.map(player_growth_cycle_stats_map, fn {player_id, map} ->
      player_live_and_dead_cells_map = Map.get(players_live_and_dead_cells_count_map, player_id)
      {player_id, Map.merge(map, player_live_and_dead_cells_map)}
    end)
    |> Enum.into(%{})

    updated_players = Enum.map(players, fn player ->
      mutation_points = mutation_points_map[player.id]
      action_points = action_points_map[player.id]
      #TODO setting to -1 so there is always an update (since we may have already updated the player struct). May want to clean this up..
      player = %{player | mutation_points: -1}
      existing_stats = %{
        mutation_points: mutation_points,
        action_points: action_points,
        grown_cells: player.grown_cells,
        regenerated_cells: player.regenerated_cells,
        perished_cells: player.perished_cells,
        fungicidal_kills: player.fungicidal_kills,
        lost_dead_cells: player.lost_dead_cells,
        stolen_dead_cells: player.stolen_dead_cells
      }
      new_stats = new_players_stats_map[player.id]
      |> Map.merge(existing_stats, fn _, v1, v2 -> v1 + v2 end)

      Players.update_player(player, new_stats)
    end)

    #since we've already aggregated player stats, just aggregate those without the player id to get totals for the game
    total_live_and_dead_cells = get_live_and_dead_cell_aggregates(players_live_and_dead_cells_count_map)
    updated_game = update_game(game, %{
      total_live_cells: total_live_and_dead_cells.total_live_cells,
      total_dead_cells: total_live_and_dead_cells.total_dead_cells})

    {updated_game, updated_players}
  end






  def set_starting_game_stats(game = %Game{players: players}, cells) do
    player_stats_map = get_live_and_dead_cells_for_player(players, cells)
    updated_players = update_players_aggregate_stats(players, player_stats_map)

    #since we've already aggregated player stats, just aggregate those without the player id to get totals for the game
    total_live_and_dead_cells = get_live_and_dead_cell_aggregates(player_stats_map)
    updated_game = update_game(game, %{
      total_live_cells: total_live_and_dead_cells.total_live_cells,
      total_dead_cells: total_live_and_dead_cells.total_dead_cells})

    {updated_game, updated_players}
  end

  defp update_players_aggregate_stats(players, stats_map) do
    Enum.map(players, fn player ->
      player_stats = Enum.filter(stats_map, fn {player_id, _} -> player_id == player.id end)

      player_live_and_dead_cells = get_live_and_dead_cell_aggregates(player_stats)
      player_updates = %{
        live_cells: player_live_and_dead_cells.total_live_cells,
        dead_cells: player_live_and_dead_cells.total_dead_cells
      }

      player_updates = Map.put(player_updates, :grown_cells, player_live_and_dead_cells.total_live_cells)

      Players.update_player(player, player_updates)
    end)
  end

  def get_live_and_dead_cells_for_player(players, cells) do
    stats_map = Enum.reduce(players, %{}, fn player, acc ->
      Map.put(acc, player.id, %{live_cells: 0, dead_cells: 0})
    end)

    Enum.reduce(cells, stats_map, fn grid_cell, acc ->
      if(grid_cell.live) do
        update_in(acc, [grid_cell.player_id, :live_cells], &(&1 + 1))
      else
        #moist cells can be empty
        if(grid_cell.empty) do
          acc
        else
          update_in(acc, [grid_cell.player_id, :dead_cells], &(&1 + 1))
        end
      end
    end)
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

  def get_starting_mutation_points(players) do
    Enum.map(players, fn player -> %PointsEarned{player_id: player.id, points: Player.default_starting_mutation_points()} end)
  end

  def get_starting_action_points(players) do
    Enum.map(players, fn player -> %PointsEarned{player_id: player.id, points: PointsEarned.default_action_points_per_round()} end)
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

    {:ok, latest_round} = Repo.transaction(fn ->
      #generate a new growth summary
      latest_round = get_latest_round_for_game(game.id)
      current_game_state = latest_round.starting_game_state

      starting_grid_map = Enum.into(current_game_state.cells, %{}, fn grid_cell -> {grid_cell.index, grid_cell} end)
      growth_summary = Grid.generate_growth_summary(starting_grid_map, latest_round.active_cell_changes, game.grid_size, player_id_to_player_map)

      #set the growth cycles on the latest around
      latest_round = Rounds.get_latest_round_for_game(game)
        |> Rounds.update_round(%{growth_cycles: growth_summary.growth_cycles})

      {updated_game, updated_players} = update_players_for_next_round(game, growth_summary)

      updated_game = check_for_game_end(updated_game)

      if(updated_game.status == Status.status_finished) do
        latest_round
      else
        #spend AI mutation points immediately
        Enum.filter(updated_players, fn player -> !player.human end)
        |> Enum.each(fn player ->
            Players.spend_ai_mutation_points(player, player.mutation_points, total_cells, total_remaining_cells)
        end)

        #set up the new round with only the starting game state and starting player stats
        starting_player_stats = Players.make_starting_player_stats(updated_players)
        next_round_number = latest_round.number + 1
        next_round = %{
          number: next_round_number, growth_cycles: [],
          starting_game_state: %GameState{round_number: next_round_number,
          cells: growth_summary.new_game_state},
          starting_player_stats: starting_player_stats
        }
        Rounds.create_round(game.id, next_round)
      end
    end)

    latest_round
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

  @doc """
  Spends points for active and passive skills.

  skill_upgrades must be a map of skill_id => points_spent
  passive_skill_upgrades must be a map of active_skill_id => %{"active_cell_changes" => [indexes], "points_spent" => points_spent}
  """
  def spend_human_player_mutation_points(player_id, game_id, passive_skill_upgrades, active_skill_changes \\ %{}) do
    #TODO check if the game is started and throw a 400 bad request if not
    player = Players.get_player!(player_id)
    spent_mutation_points = PlayerSkills.sum_skill_upgrades(passive_skill_upgrades)
    if(spent_mutation_points > player.mutation_points) do
      {:error_illegal_number_of_points_spent}
    else
      if(ActiveCellChanges.update_active_cell_changes(player, game_id, active_skill_changes)) do
        total_spent_points = player.spent_mutation_points + spent_mutation_points

        player_changes = PlayerSkills.update_player_skills_and_get_player_changes(player, passive_skill_upgrades)
        |> Map.put(:mutation_points, player.mutation_points - spent_mutation_points)
        |> Map.put(:spent_mutation_points, total_spent_points)

        updated_player = Players.update_player(player, player_changes)

        game = get_game!(game_id)
        new_round = next_round_available?(game)

        if(new_round) do
          trigger_next_round(game)
        end

        {:ok, next_round_available: new_round, updated_player: updated_player}
      else
        {:error_illegal_active_cell_changes}
      end

    end
  end

  def join_game(game_id, user_name) do
    game = get_game!(game_id)

    number_of_already_joined_players = Players.get_number_of_users_who_joined_game(game_id)
    open_slots = game.number_of_human_players - number_of_already_joined_players

    if(open_slots > 0) do
      user = Accounts.get_user_for_name(user_name)
      existing_player = Enum.find(game.players, fn player -> player.user_id == user.id end)
      if(existing_player == nil) do
        next_open_player = Enum.find(game.players, fn player -> player.human and player.user_id == nil end)
        Players.update_player(next_open_player, %{user_id: user.id, name: user.user_name})

        if(open_slots == 1) do
          game = get_game!(game.id)
          start_game(game)
          {:ok, true}
        else
          {:ok, false}
        end
      else
        {:error, :user_already_joined}
      end
    else
      {:error, :no_open_slots}
    end
  end

  defdelegate get_latest_round_for_game(game), to: Rounds

  def get_round!(id) do
    alias FungusToast.Games.Round
    Repo.get!(Round, id) |> Repo.preload(:game)
  end

  defdelegate list_players_for_game(game), to: Players
  defdelegate get_player_for_game(game_id, id), to: Players
  defdelegate get_player!(id), to: Players

  defdelegate get_player_skills(player), to: PlayerSkills
  defdelegate sum_skill_upgrades(skill_upgrades), to: PlayerSkills
  defdelegate update_player_skill(player_skill, attrs), to: PlayerSkills
end
