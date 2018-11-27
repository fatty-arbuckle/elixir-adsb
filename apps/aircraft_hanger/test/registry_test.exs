defmodule AircraftHanger.RegistryTest do
  use ExUnit.Case, asyc: true

  @icoa "ABC123"

  setup do
    registry = start_supervised!(AircraftHanger.Registry)
    %{registry: registry}
  end

  test "aircraft registry create/lookup", %{registry: registry} do
    assert :error == AircraftHanger.Registry.lookup(registry, @icoa)
    AircraftHanger.Registry.create(registry, @icoa)

    assert {:ok, aircraft} = AircraftHanger.Registry.lookup(registry, @icoa)
    assert [@icoa] == AircraftHanger.Registry.all_names(registry)
  end

  test "removes aircraft on exit", %{registry: registry} do
    AircraftHanger.Registry.create(registry, @icoa)
    {:ok, aircraft} = AircraftHanger.Registry.lookup(registry, @icoa)
    Agent.stop(aircraft)
    assert AircraftHanger.Registry.lookup(registry, @icoa) == :error
  end

  test "removes aircraft on crash", %{registry: registry} do
    AircraftHanger.Registry.create(registry, @icoa)
    {:ok, aircraft} = AircraftHanger.Registry.lookup(registry, @icoa)

    # Stop the aircraft with non-normal reason
    Agent.stop(aircraft, :shutdown)
    assert AircraftHanger.Registry.lookup(registry, @icoa) == :error
  end
end
