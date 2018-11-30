defmodule AircraftViewerWeb.DetailsController do
  use AircraftViewerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
