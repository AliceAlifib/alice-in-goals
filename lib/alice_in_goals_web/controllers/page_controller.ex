defmodule AliceInGoalsWeb.PageController do
  use AliceInGoalsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
