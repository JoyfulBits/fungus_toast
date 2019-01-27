defmodule FungusToast.Games.Engine do
  alias FungusToast.Games.Grid
  alias FungusToast.Games.Grid
  alias FungusToast.Games.Game

  @moduledoc """
  Provides game state transformations to be passed to
  Game.changeset/2
  """

  def create_state(%{"number_of_human_players" => 1, "number_of_ai_players" => count} = attrs)
      when count > 0 do
    Map.put(attrs, "status", "In Progress")
    |> with_game_state()
  end

  def create_state(%{"number_of_human_players" => 1, "number_of_ai_players" => count} = attrs)
      when count <= 0 do
    Map.put(attrs, "status", "Finished")
  end

  def create_state(attrs), do: attrs

  defp with_game_state(%{"number_of_rows" => rows, "number_of_colums" => cols} = attrs) do
    Map.put(attrs, "game_state", Grid.new(rows, cols) |> wrap_state())
  end

  defp with_game_state(%{"number_of_colums" => cols} = attrs) do
    Map.put(attrs, "game_state", Grid.new(Game.default_rows(), cols) |> wrap_state())
  end

  defp with_game_state(%{"number_of_rows" => rows} = attrs) do
    Map.put(attrs, "game_state", Grid.new(rows, Game.default_cols()) |> wrap_state())
  end

  defp with_game_state(attrs) do
    Map.put(
      attrs,
      "game_state",
      Grid.new(Game.default_rows(), Game.default_cols()) |> wrap_state()
    )
  end

  defp wrap_state(grid), do: %{grid: grid}

  def random_indices(grid, number_of_players),
    do: 1..Grid.size(grid) |> Enum.take_random(number_of_players)
end
