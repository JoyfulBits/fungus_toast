defmodule FungusToastWeb.PageController do
  use FungusToastWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
