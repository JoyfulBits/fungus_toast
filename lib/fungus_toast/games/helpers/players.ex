defmodule FungusToast.Players do
  @moduledoc """
  The Players helper for the Games context.
  """

  import Ecto.Query, warn: false
  alias FungusToast.Repo

  alias FungusToast.{Accounts, PlayerSkills, AiStrategies}
  alias FungusToast.Accounts.User
  alias FungusToast.Games.{Game, Player}


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
        {:ok, player} = create_basic_player(game.id, false, "Fungal Mutation #{x}", nil, ai_type)
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
    player
    |> Player.changeset(attrs)
    |> Repo.update()
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
    skill = AiStrategies.get_skill_choice(player.ai_type, total_cells, number_of_remaining_cells)
    |> FungusToast.Skills.get_skill_by_name()

    player_skill = PlayerSkills.get_player_skill(player.id, skill.id)
    PlayerSkills.update_player_skill(player_skill, %{skill_level: player_skill.skill_level + 1})

    attributes_to_update = AiStrategies.get_player_attributes_for_skill_name(skill.name)
    skill_change = if(skill.up_is_good, do: skill.increase_per_point, else: skill.increase_per_point * -1.0)

    acc = update_attribute(player, skill_change, attributes_to_update, acc)
    |> Map.put(:mutation_points, mutation_points - 1)
    spend_ai_mutation_points(player, mutation_points - 1, total_cells, number_of_remaining_cells, acc)
  end

  def spend_ai_mutation_points(player, mutation_points, _total_cells, _number_of_remaining_cells, acc) when mutation_points == 0 do
    {:ok, updated_player} = update_player(player, acc)
    updated_player
  end

  def update_attribute(%Player{} = player, skill_change, attributes, acc) when length(attributes) > 0 do
    [attribute | remaining_attributes] = attributes
    existing_value = Map.get(acc, attribute)
    existing_value =
      if(existing_value == nil) do
        Map.get(player, attribute)
      else
        existing_value
      end
    acc = Map.put(acc, attribute, existing_value + skill_change)
    update_attribute(player, skill_change, remaining_attributes, acc)
  end

  def update_attribute(_player, _skill_change, attributes, acc) when length(attributes) == 0 do
    acc
  end
end
