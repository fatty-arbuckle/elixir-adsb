defmodule Aircraft do
  @enforce_keys [:icoa]
  defstruct [
    :icoa,
    :callsign,
    :longitude,
    :latitude,
    :altitude,
    :speed,
    :heading,
    :last_seen_time,
    :messages
  ]
end
