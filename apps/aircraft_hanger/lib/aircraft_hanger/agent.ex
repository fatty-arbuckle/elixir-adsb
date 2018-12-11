defmodule AircraftHanger.Agent do
  use Agent, restart: :temporary

  @doc """
  Starts a new aircraft agent
  """
  def start_link(opts) do
    Agent.start_link(opts)
  end

  def get(icoa) do
    Agent.get(icoa, fn state -> state end)
  end

  @doc """
  Gets info from the aircraft specified by the key
  """
  def get(icoa, key) do
    Agent.get(icoa, &Map.get(&1, key))
  end

  @doc """
  Sets a value for the aircraft the key
  """
  def put(icoa, key, value) do
    Agent.update(icoa, &Map.put(&1, key, value))
    # Agent.update(icoa, fn icoa, k, v -> %Aircraft{icoa | k => v} end)
  end

  @doc """
  Addends a message to the aircraft message list
  """
  def append(icoa, :messages, nil) do
  end
  def append(icoa, :messages, message) do
    currentMessages = case get(icoa, :messages) do
      nil  -> []
      msgs -> msgs
    end
    newMessages = currentMessages ++ [message]
    put(icoa, :messages, newMessages)
  end

  @doc """
  Deletes info about the aircraft
  """
  def delete(icoa, key) do
    Agent.get_and_update(icoa, fn dict -> Map.pop(dict, key) end)
  end
end
