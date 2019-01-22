defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view

  def render("show.json", %{game: game}) do
    Map.from_struct(game)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
