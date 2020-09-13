defmodule MetristSiteWeb.PageControllerTest do
  use MetristSiteWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "metri.st"
  end
end
