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
    @moduledoc """
    Provides game state transformations to be passed to
    Game.changeset/2
    """
    alias FungusToast.Games.Game.State

    def create_state(%{"number_of_human_players" => 1, "number_of_ai_players" => count} = attrs)
        when count > 0 do
      Map.put(attrs, "status", "In Progress")
      |> Map.put("game_state", game_state())
    end

    def create_state(%{"number_of_human_players" => 1, "number_of_ai_players" => count} = attrs)
        when count <= 0 do
      Map.put(attrs, "status", "Finished")
    end

    def create_state(attrs), do: attrs

    def game_state() do
      %State{}
    end
  end
end
