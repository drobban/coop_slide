defmodule CoopSlideWeb.PageController do
  use CoopSlideWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
