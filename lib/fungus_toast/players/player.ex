defmodule FungusToast.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :user_name,
    :human,
    :active
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "players" do
    field :active, :boolean, default: false
    field :human, :boolean, default: false
    field :user_name, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:user_name, :active, :human])
    |> validate_required([:user_name, :active, :human])
  end
end
