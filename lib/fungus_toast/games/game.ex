defmodule FungusToast.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :active,
    :game_state,
    :number_of_human_players,
    :number_of_ai_players,
    :number_of_rows,
    :number_of_columns
  ]

  @default_rows 50
  @default_columns 50
  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "games" do
    field :game_state, :map
    field :active, :boolean, default: false
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
  end
end