defmodule FungusToast.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :active,
    :user_name
  ]

  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "users" do
    field :active, :boolean, default: true, null: false
    field :user_name, :string

    has_many :players, FungusToast.Games.Player

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_name, :active])
    |> validate_required([:user_name, :active])
    |> unique_constraint(:user_name)
  end
end
