defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params, _assigns) do
    render(conn, "index.html")
  end
end
