defmodule FungusToastWeb.UserView do
  use FungusToastWeb, :view
  alias FungusToastWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    # TODO: Move this into a helper that accepts a struct
    Map.from_struct(user)
    |> Map.pop(:__meta__)
    |> elem(1)
  end
end
