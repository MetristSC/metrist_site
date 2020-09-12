defmodule MetristSiteWeb.PageController do
  use MetristSiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
