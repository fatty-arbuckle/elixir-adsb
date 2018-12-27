defmodule Aircraft do

  def raw_message_topic, do: :raw_aircraft_messages
  def raw_aircraft_topic, do: :raw_aircraft_data

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
