defmodule MetristWeb.PageController do
  use MetristWeb, :controller

  def index(conn, _params) do
    if not is_nil(get_session(conn, :current_user)) do
      redirect(conn, to: "/home")
    else
      render(conn, "index.html",
        current_user: get_session(conn, :current_user))
    end
  end
end
