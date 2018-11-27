defmodule AircraftHangerTest do
  use ExUnit.Case
  doctest Aircraft

  @icoa "ABC123"

  setup do
    on_exit fn ->
      case AircraftHanger.Registry.lookup(AircraftHanger.Registry, @icoa) do
        {:ok, aircraftAgent} ->
          {:ok, Agent.stop(aircraftAgent)}
        _ ->
          {:ok, nil}
      end
    end
    AircraftHanger.Registry.create(AircraftHanger.Registry, @icoa)
  end

  test "get_aircraft and update_aircraft create new aircraft" do
    assert :error == AircraftHanger.Registry.lookup(AircraftHanger.Registry, "unknown_get")
    assert :not_found == AircraftHanger.get_aircraft("unknown_get")

    AircraftHanger.update_aircraft("unknown_update", %{})
    {:ok, tmp} = AircraftHanger.Registry.lookup(AircraftHanger.Registry, "unknown_update")
    Agent.stop(tmp)
  end

  test "internal usage" do
    {:ok, aircraftAgent} = AircraftHanger.Registry.lookup(AircraftHanger.Registry, "ABC123")
    AircraftHanger.Agent.put(aircraftAgent, "longitude", -12.345)
    assert AircraftHanger.Agent.get(aircraftAgent, "longitude") == -12.345
  end

  test "external usage" do
    aircraft = AircraftHanger.get_aircraft("ABC123")
    assert aircraft.icoa == "ABC123"
    assert aircraft.altitude == nil
    assert aircraft.heading == nil
    assert aircraft.speed == nil
    assert aircraft.latitude == nil
    assert aircraft.longitude == nil

    aircraft = AircraftHanger.update_aircraft("ABC123", %{
      :latitude => 12,
      :longitude => 24,
    })
    assert aircraft.icoa == "ABC123"
    assert aircraft.altitude == nil
    assert aircraft.heading == nil
    assert aircraft.speed == nil
    assert aircraft.latitude == 12
    assert aircraft.longitude == 24

    aircraft = AircraftHanger.get_aircraft("ABC123")
    assert aircraft.icoa == "ABC123"
    assert aircraft.altitude == nil
    assert aircraft.heading == nil
    assert aircraft.speed == nil
    assert aircraft.latitude == 12
    assert aircraft.longitude == 24
  end

  test "getting all aircraft" do
    AircraftHanger.update_aircraft("A", %{
      :latitude => 11,
      :longitude => 12,
    })
    AircraftHanger.update_aircraft("B", %{
      :latitude => 21,
      :longitude => 22,
    })
    AircraftHanger.update_aircraft("C", %{
      :latitude => 31,
      :longitude => 32,
    })
    aircraft = AircraftHanger.get_aircraft()
    assert Enum.count(aircraft) == 4
    Enum.any? aircraft, fn a ->
      a.icoa == "A" && a.latitude == 11 && a.longitude == 12
    end
    Enum.any? aircraft, fn a ->
      a.icoa == "B" && a.latitude == 21 && a.longitude == 22
    end
    Enum.any? aircraft, fn a ->
      a.icoa == "C" && a.latitude == 31 && a.longitude == 32
    end
    Enum.any? aircraft, fn a ->
      a.icoa == @icoa
    end
  end

end
