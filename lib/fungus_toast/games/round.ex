defmodule FungusToast.Games.Round do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :number,
    :game_state,
    :state_change
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "rounds" do
    field :game_state, :map, null: false
    field :state_change, :map, null: false
    field :number, :integer, default: 1, null: false

    belongs_to :game, FungusToast.Games.Game

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
