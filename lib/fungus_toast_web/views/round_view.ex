defmodule FungusToastWeb.RoundView do
  use FungusToastWeb, :view

  def render("show.json", %{round: round}), do: map_from(round)
end
