defmodule FungusToastWeb.UserController do
  use FungusToastWeb, :controller

  alias FungusToast.Accounts
  alias FungusToast.Accounts.User

  action_fallback FungusToastWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      # Should this be handled in Accounts?
      user = user |> FungusToast.Repo.preload(:players)

      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id) |> FungusToast.Repo.preload(:players)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      # Should this be handled in Accounts?
      user = user |> FungusToast.Repo.preload(:players)
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    update(conn, %{"id" => id, "user" => %{active: false}})
  end
end
