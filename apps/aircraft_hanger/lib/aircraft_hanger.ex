defmodule AircraftHanger do
  use Application

  @doc """
  Gets all aircraft in the registry
  """
  def get_aircraft() do
    Enum.map AircraftHanger.Registry.all_names(AircraftHanger.Registry), fn icoa ->
      get_aircraft(icoa)
    end
  end
  @doc """
  Get an aircraft by its icoa string
  """
  def get_aircraft(icoa) do
    case AircraftHanger.Registry.lookup(AircraftHanger.Registry, icoa) do
      {:ok, aircraftAgent} ->
        AircraftHanger.Agent.get(aircraftAgent)
      :error ->
        :not_found
    end
  end

  @doc """
  Update an aircraft by its icoa string
  """
  def update_aircraft(icoa, data, message) do
    aircraftAgent = get_or_create_aircraft(icoa)
    Enum.each Map.to_list(data), fn {k, v} ->
      unless v == nil do AircraftHanger.Agent.put(aircraftAgent, k, v) end
    end
    AircraftHanger.Agent.put(aircraftAgent, :last_seen_time, :os.system_time(:millisecond))
    AircraftHanger.Agent.append(aircraftAgent, :messages, message)
    AircraftHanger.Agent.get(aircraftAgent)
  end

  defp get_or_create_aircraft(icoa) do
    case AircraftHanger.Registry.lookup(AircraftHanger.Registry, icoa) do
      {:ok, aircraftAgent} ->
        aircraftAgent
      _ ->
        AircraftHanger.Registry.create(AircraftHanger.Registry, icoa)
        {:ok, aircraftAgent} = AircraftHanger.Registry.lookup(AircraftHanger.Registry, icoa)
        aircraftAgent
    end
  end

  def start(_type, _args) do
    AircraftHanger.Supervisor.start_link(name: AircraftHanger.Supervisor)
  end

  ## TODO listen here for raw_aircraft_topic and do the right thing (call update?)
  ## TODO take parsing code out of client...new module?  part of aircraft?
end
