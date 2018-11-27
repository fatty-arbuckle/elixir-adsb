defmodule AircraftHanger.AgentTest do
  use ExUnit.Case, async: true

  setup do
    agent = start_supervised!({AircraftHanger.Agent, fn -> %Aircraft{icoa: "ABC123"} end})
    %{agent: agent}
  end

  test "stores, gets, and deletes aircraft values", %{agent: agent} do
    assert AircraftHanger.Agent.get(agent, :longitude) == nil

    AircraftHanger.Agent.put(agent, :longitude, -71.123)
    assert AircraftHanger.Agent.get(agent, :longitude) == -71.123

    AircraftHanger.Agent.delete(agent, :longitude)
    assert AircraftHanger.Agent.get(agent, :longitude) == nil
  end

  test "gets all the state data in the agent", %{agent: agent} do
    AircraftHanger.Agent.put(agent, :latitude, 42.123)
    AircraftHanger.Agent.put(agent, :longitude, -71.123)
    aircraft = AircraftHanger.Agent.get(agent)
    assert aircraft.altitude == nil
    assert aircraft.heading == nil
    assert aircraft.icoa == "ABC123"
    assert aircraft.speed == nil
    assert aircraft.latitude == 42.123
    assert aircraft.longitude == -71.123
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(AircraftHanger.Agent, []).restart == :temporary
  end
end
