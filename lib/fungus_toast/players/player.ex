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
    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:human])
    |> validate_required([:human])
  end
end
