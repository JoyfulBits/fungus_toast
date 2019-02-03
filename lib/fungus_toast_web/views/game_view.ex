defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view

  def render("show.json", %{game: game}) do
    # TODO: Move this into a helper that accepts a struct
    Map.from_struct(game)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
