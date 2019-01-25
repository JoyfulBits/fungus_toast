defmodule FungusToast.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @default_status "Not Started"
  @statuses ["In Progress", "Finished", "Abandoned", "Archived"]

  @attrs [
    :game_state,
    :number_of_human_players,
    :number_of_ai_players,
    :number_of_rows,
    :number_of_columns,
    :status
  ]

  @default_rows 50
  @default_columns 50
  def default_cols, do: @default_columns
  def default_rows, do: @default_rows
  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "games" do
    field :status, :string, default: @default_status
    field :game_state, :map
    field :number_of_columns, :integer, default: @default_columns, null: false
    field :number_of_rows, :integer, default: @default_rows, null: false
    field :number_of_human_players, :integer, null: false
    field :number_of_ai_players, :integer, default: 0, null: false

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, @attrs)
    |> validate_required([:number_of_human_players])
    |> validate_inclusion(:status, [@default_status] ++ @statuses)
  end

  defmodule Engine do
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
      Map.put(attrs, "game_state", Grid.new(Game.default_rows(), Game.default_cols()) |> wrap_state())
    end

    defp wrap_state(grid), do: %{grid: grid}
  end
end
