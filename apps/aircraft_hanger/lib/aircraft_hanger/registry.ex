defmodule AircraftHanger.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the aircraft registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the aircraft pid for icoa stored in `server`.

  Returns `{:ok, pid}` if the aircraft exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Looks up the aircraft pid for icoa stored in `server`.

  Returns `{:ok, pid}` if the aircraft exists, `:error` otherwise.
  """
  def all_names(server) do
    GenServer.call(server, {:all_names})
  end


  @doc """
  Ensures there is a aircraft associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks

  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, icoa}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, icoa), state}
  end

  def handle_call({:all_names}, _from, {names, _} = state) do
    {:reply, Map.keys(names), state}
  end

  def handle_cast({:create, icoa}, {names, refs}) do
    if Map.has_key?(names, icoa) do
      {:noreply, names}
    else
      {:ok, pid} = DynamicSupervisor.start_child(
        AircraftHanger.AircraftSupervisor,
        {AircraftHanger.Agent, fn -> %Aircraft{icoa: icoa} end}
      )
      refs = Map.put(refs, Process.monitor(pid), icoa)
      names = Map.put(names, icoa, pid)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
