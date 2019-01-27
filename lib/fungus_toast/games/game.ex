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
end
