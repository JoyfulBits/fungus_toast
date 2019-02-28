defmodule FungusToast.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @default_status "Not Started"
  @statuses ["Started", "Finished", "Abandoned", "Archived"]

  @attrs [
    :number_of_human_players,
    :number_of_ai_players,
    :grid_size,
    :status
  ]

  @default_grid_size 50
  @derive {Jason.Encoder, only: [:id] ++ @attrs}

  schema "games" do
    field :status, :string, default: @default_status
    field :grid_size, :integer, default: @default_grid_size, null: false
    field :number_of_human_players, :integer, null: false
    field :number_of_ai_players, :integer, default: 0, null: false

    has_many :rounds, FungusToast.Games.Round, on_delete: :delete_all
    has_many :players, FungusToast.Games.Player, on_delete: :delete_all

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
