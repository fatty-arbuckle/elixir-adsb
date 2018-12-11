defmodule Dump1090Client.Network.Client do

  use GenServer

  require Logger

  @max_retries 10
  @retry_interval 1000

  defmodule DefaultCallbacks do
    require Logger

    def on_connect(state) do
      Logger.info("tcp connect to #{state.host}:#{state.port}", ansi_color: :yellow)
    end

    def on_disconnect(state) do
      Logger.info("tcp disconnect from #{state.host}:#{state.port}", ansi_color: :yellow)
    end

    def on_failure(state) do
      Logger.info("tcp failure from #{state.host}:#{state.port}. Max retries exceeded.", ansi_color: :yellow)
    end
  end

  defmodule State do
    defstruct host: "nope",
              port: 1234,
              failure_count: 0,
              on_connect: &DefaultCallbacks.on_connect/1,
              on_disconnect: &DefaultCallbacks.on_disconnect/1,
              on_failure: &DefaultCallbacks.on_failure/1

  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    state = opts_to_initial_state(opts)
    case :gen_tcp.connect(state.host, state.port, []) do
      {:ok, _socket} ->
        state.on_connect.(state)
        {:ok, state}
      {:error, _reason} ->
        new_state = %{state | failure_count: 1}
        new_state.on_disconnect.(new_state)
        {:ok, new_state, @retry_interval}
    end
  end

  defp parse_integer(s) do
    case Integer.parse(s) do
      {i, _} -> i
      :error -> nil
    end
  end

  defp parse_float(s) do
    case Float.parse(s) do
      {f, _} -> f
      :error -> nil
    end
  end

  # MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0
  def parse_adsb("MSG,1," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    callsign = String.trim(Enum.at(tmp, 8))
    Logger.debug("#{icoa} reporting callsign #{callsign}")
    %Aircraft{
      icoa: icoa,
      callsign: callsign
    }
  end
  def parse_adsb("MSG,3," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    altitude = parse_integer(Enum.at(tmp, 9))
    lat = parse_float(Enum.at(tmp, 12))
    lon = parse_float(Enum.at(tmp, 13))
    Logger.debug("#{icoa} reporting at #{lat}, #{lon} alt #{altitude}")
    %Aircraft{
      icoa: icoa,
      longitude: lon,
      latitude: lat,
      altitude: altitude
    }
  end
  def parse_adsb("MSG,4," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    speed = parse_integer(Enum.at(tmp, 10))
    heading = parse_integer(Enum.at(tmp, 11))
    Logger.debug("#{icoa} reporting speed #{speed}, heading #{heading}")
    %Aircraft{
      icoa: icoa,
      speed: speed,
      heading: heading
    }
  end
  def parse_adsb(_ignored) do
    :not_supported
  end

  def handle_info({:tcp, _socket, message}, state) do
    case parse_adsb(List.to_string(message)) do
      aircraft = %Aircraft{icoa: icoa} ->
        AircraftHanger.update_aircraft(icoa, aircraft, message)
      :not_supported ->
        :ok
    end
    {:noreply, state}
  end

  def handle_info(:timeout, state = %State{failure_count: failure_count}) do
    if failure_count <= @max_retries do
      case :gen_tcp.connect(state.host, state.port, []) do
        {:ok, _socket} ->
          new_state = %{state | failure_count: 0}
          new_state.on_connect.(new_state)
          {:noreply, new_state}
        {:error, _reason} ->
          new_state = %{state | failure_count: failure_count + 1}
          new_state.on_disconnect.(new_state)
          :timer.sleep(60 * 1000)
          {:noreply, new_state, @retry_interval}
      end
    else
      state.on_failure.(state)
      {:stop, :max_retry_exceeded, state}
    end
  end

  def handle_info({:tcp_closed, _socket}, state) do
    case :gen_tcp.connect(state.host, state.port, []) do
      {:ok, _socket} ->
        new_state = %{state | failure_count: 0}
        new_state.on_connect.(new_state)
        {:noreply, new_state}
      {:error, _reason} ->
        new_state = %{state | failure_count: 1}
        new_state.on_disconnect.(new_state)
        {:noreply, new_state, @retry_interval}
    end
  end

  defp opts_to_initial_state(opts) do
    host = Keyword.get(opts, :host, "localhost") |> String.to_charlist
    port = Keyword.fetch!(opts, :port)
    %State{host: host, port: port}
  end

end
