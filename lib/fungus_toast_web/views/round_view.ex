defmodule FungusToastWeb.RoundView do
  use FungusToastWeb, :view
  alias FungusToastWeb.RoundView

  def render("show.json", %{round: round}) do
    Map.from_struct(round)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
