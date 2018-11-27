defmodule AircraftHanger.Janitor do
  use Task
  require Logger

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      10_000 ->
        remove_aircraft()
        poll()
    end
  end

  defp remove_aircraft() do
    cutoff = :os.system_time(:millisecond) - 60_000
    AircraftHanger.get_aircraft
    |> Enum.each(fn aircraft ->
      if aircraft.last_seen_time < cutoff do
        Logger.debug("removing #{aircraft.icoa} because it has gone silent")
        {:ok, aircraftAgent} = AircraftHanger.Registry.lookup(AircraftHanger.Registry, aircraft.icoa)
        Agent.stop(aircraftAgent)
      end
    end)
  end
end
