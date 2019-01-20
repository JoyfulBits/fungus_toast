defmodule FungusToastWeb.GameView do
  use FungusToastWeb, :view

  def render("show.json", %{game: game}) do
    %{
      id: game.id,
      created: game.inserted_at
    }
  end
end
