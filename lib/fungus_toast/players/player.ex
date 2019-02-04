defmodule FungusToast.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :human,
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "players" do
    field :human, :boolean, default: false

    belongs_to :user, FungusToast.Accounts.User, foreign_key: :user_id

    many_to_many :games, FungusToast.Games.Game, join_through: "player_games",
      unique: true, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:human])
    |> validate_required([:human])
  end
end
