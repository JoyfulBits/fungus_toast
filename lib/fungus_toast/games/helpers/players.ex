defmodule FungusToast.Players do
  @moduledoc """
  The Players helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.{Accounts, PlayerSkills, AiStrategies}
  alias FungusToast.Accounts.User
  alias FungusToast.Games.{Game, Player, PlayerStats}


  @doc """
  Returns the list of players.
  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Returns the list of players for a given user.
  """
  def list_players_for_user(%User{} = user) do
    list_players_for_user(user.id)
  end

  def list_players_for_user(user_id) do
    from(p in Player, where: p.user_id == ^user_id) |> Repo.all()
  end

  @doc """
  Returns the list of players for a given game.
  """
  def list_players_for_game(game_id) do
    from(p in Player, where: p.game_id == ^game_id) |> Repo.all
  end

  @doc """
  Returns the total number of human players who have joined the game
  """
  def get_number_of_users_who_joined_game(game_id) do
    Repo.one(from p in Player, where: p.game_id == ^game_id and p.human and not is_nil(p.user_id), select: count(p.id))
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.
  """
  def get_player!(id), do: Repo.get!(Player, id)

  # TODO: Document this
  def get_player_for_game(%Game{} = game, id) do
    get_player_for_game(game.id, id)
  end

  def get_player_for_game(game_id, id) do
    from(p in Player, where: p.id == ^id and p.game_id == ^game_id) |> Repo.one()
  end

  @doc """
  Creates a player for the given user and game
  """
  @spec create_player_for_user(%Game{}, String.t()) :: %Player{}
  def create_player_for_user(game = %Game{}, user_name) do
    user = Accounts.get_user_for_name(user_name)
    {:ok, player} = create_basic_player(game.id, true, user.user_name, user.id)
    |> Player.changeset(%{})
    |> Repo.insert()

    player
  end

  @doc """
  Creates the requested number of AI players for the given game. AI players have no user associated with them
  """
  @spec create_ai_players(%Game{}, String.t()) :: [%Player{}]
  def create_ai_players(game, ai_type \\ nil) do
    if(game.number_of_ai_players > 0) do
      Enum.map(1..game.number_of_ai_players, fn x ->
        {:ok, player} = create_basic_player(game.id, false, "AI Strain #{x}", nil, ai_type)
        |> Player.changeset(%{})
        |> Repo.insert()

        player
      end)
    else
      []
    end
  end

  @doc """
  Creates the requested number of yet unknown human players for the given game.
  """
  @spec create_human_players(%Game{}, integer()) :: [%Player{}]
  def create_human_players(game, number_of_human_players) do
    if(number_of_human_players > 0) do
      Enum.map(1..number_of_human_players, fn x ->
        {:ok, player} = create_basic_player(game.id, true, "Unknown Player #{x}")
        |> Player.changeset(%{})
        |> Repo.insert()

        player
      end)
    else
      []
    end
  end

  @doc """
  Creates a player with teh default skills populated. If it is an AI player, it will set the AI type to whatever is specified, or choose one
  at random if not specified.
  """
  @spec create_basic_player(integer(), boolean(), String.t(), integer(), String.t()) :: %Player{}
  def create_basic_player(game_id, human, name, user_id \\ nil, ai_type \\ nil) do
    if(!human and user_id != nil) do
      raise ArgumentError, message: "AI players cannot have a user_id"
    end
    default_skills = PlayerSkills.get_default_starting_skills()
    ai_type = if(ai_type == nil) do
      get_ai_type(human)
    else
      ai_type
    end

    %Player{game_id: game_id, human: human, name: name, user_id: user_id, ai_type: ai_type, skills: default_skills}
  end

  defp get_ai_type(human) do
    if(!human) do
      Enum.random(AiStrategies.get_ai_types())
    end
  end

  @doc """
  Updates a player.
  """
  def update_player(%Player{} = player, attrs) do
    {:ok, player} = player
    |> Player.changeset(attrs)
    |> Repo.update()

    player
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  """
  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end

  @doc """
  Makes the AI player spend its mutation points in accordance with it's ai_type
  """
  @spec spend_ai_mutation_points(%Player{}, integer(), integer(), integer()) :: any()
  def spend_ai_mutation_points(player, mutation_points, total_cells, number_of_remaining_cells, acc \\ %{})
  def spend_ai_mutation_points(%Player{} = player, mutation_points, total_cells, number_of_remaining_cells, acc) when mutation_points > 0 do
    #get a version of the player with the latest updates so AI players can pick the best skills based on current attributes
    player_with_unsaved_updates = Map.merge(player, acc, fn _, _, v2 -> v2 end)
    skill = AiStrategies.get_skill_choice(player_with_unsaved_updates, total_cells, number_of_remaining_cells)
    |> FungusToast.Skills.get_skill_by_name()

    player_skill = PlayerSkills.get_player_skill(player.id, skill.id)
    PlayerSkills.update_player_skill(player_skill, %{skill_level: player_skill.skill_level + 1})

    attributes_to_update = AiStrategies.get_player_attributes_for_skill_name(skill.name)
    skill_change = if(skill.up_is_good, do: skill.increase_per_point, else: skill.increase_per_point * -1.0)

    acc = PlayerSkills.update_attribute(player, skill_change, attributes_to_update, acc)
    |> Map.put(:mutation_points, mutation_points - 1)
    spend_ai_mutation_points(player, mutation_points - 1, total_cells, number_of_remaining_cells, acc)
  end

  def spend_ai_mutation_points(player, mutation_points, _total_cells, _number_of_remaining_cells, acc) when mutation_points == 0 do
    #since AI players always spend all of their mutation points, increment the spent points by what they started with
    acc = Map.put(acc, :spent_mutation_points, player.spent_mutation_points + player.mutation_points)
    update_player(player, acc)
  end

  @doc """
  Transforms a list of players into an [%PlayerState]

  ## Examples

  iex> Players.make_starting_player_stats([%Player{id: 10, live_cells: 1, dead_cells: 2, grown_cells: 3, perished_cells: 4, regenerated_cells: 5, fungicidal_kills: 6, lost_dead_cells: 7, stolen_dead_cells: 8}])
  [%FungusToast.Games.PlayerStats{
    dead_cells: 2,
    fungicidal_kills: 6,
    grown_cells: 3,
    live_cells: 1,
    lost_dead_cells: 7,
    stolen_dead_cells: 8,
    perished_cells: 4,
    player_id: 10,
    regenerated_cells: 5
  }]
  """
  def make_starting_player_stats(players) do
    Enum.map(players, fn player ->
      %PlayerStats{
        player_id: player.id,
        live_cells: player.live_cells,
        dead_cells: player.dead_cells,
        grown_cells: player.grown_cells,
        perished_cells: player.perished_cells,
        regenerated_cells: player.regenerated_cells,
        fungicidal_kills: player.fungicidal_kills,
        lost_dead_cells: player.lost_dead_cells,
        stolen_dead_cells: player.stolen_dead_cells
      }
    end)
  end

  def spend_ai_action_points(ai_player, toast_grid, grid_size, remaining_cells, round_number) do
    {active_cell_changes, action_points_spent} = AiStrategies.use_active_skills(ai_player, toast_grid, grid_size, remaining_cells, round_number)
    updated_player = update_player(ai_player, %{action_points: ai_player.action_points - action_points_spent})
    {active_cell_changes, updated_player}
  end
end
