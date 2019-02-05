defmodule FungusToastWeb.UserView do
  use FungusToastWeb, :view
  alias FungusToastWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}), do: map_from(user)
end
