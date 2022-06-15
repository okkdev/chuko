defmodule ChukoWeb.PageController do
  use ChukoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
