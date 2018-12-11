defmodule Dump1090Client do
  def reply_from_file(file_name, delay) do
    Task.async(fn ->
      File.stream!(file_name)
        |> Stream.map(fn(msg) ->
          case Dump1090Client.Network.Client.parse_adsb(msg) do
            aircraft = %Aircraft{icoa: icoa} ->
              AircraftHanger.update_aircraft(icoa, aircraft, msg)
            :not_supported ->
              :ok
          end
          :timer.sleep(delay)
        end)
        |> Stream.run
    end)
  end
end
