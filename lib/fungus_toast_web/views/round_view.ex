defmodule FungusToastWeb.RoundView do
  use FungusToastWeb, :view
  alias FungusToastWeb.RoundView

  def render("show.json", %{round: round}) do
    # TODO: Move this into a helper that accepts a struct
    Map.from_struct(round)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
