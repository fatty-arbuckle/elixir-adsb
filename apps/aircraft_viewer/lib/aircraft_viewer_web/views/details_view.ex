defmodule AircraftViewerWeb.DetailsView do
  use AircraftViewerWeb, :view

  def get_aircraft do
    AircraftHanger.get_aircraft
  end
end
