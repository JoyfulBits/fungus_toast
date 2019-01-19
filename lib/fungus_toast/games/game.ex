defmodule FungusToast.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset


  schema "games" do
    field :game_state, :map
    field :active, :boolean, default: false
    field :number_of_columns, :integer, default: 0, null: false
    field :number_of_rows, :integer, default: 0, null: false

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:active, :game_state])
    |> validate_required([])
  end
end
