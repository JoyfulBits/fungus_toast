defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view

  def render("show.json", %{game: game}), do: game
end
