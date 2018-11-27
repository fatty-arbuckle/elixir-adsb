defmodule AircraftHanger.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: AircraftHanger.AircraftSupervisor, strategy: :one_for_one},
      {AircraftHanger.Janitor, name: AircraftHanger.Janitor},
      {AircraftHanger.Registry, name: AircraftHanger.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
