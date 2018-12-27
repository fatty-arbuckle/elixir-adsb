defmodule AircraftHanger.Dump1090Listener do
  use Task
  require Logger

  def start_link(topic) do
    Logger.debug("AircraftHanger.Dump1090Listener started for #{topic}")
    {:ok, pid} = Task.start_link(&poll/0)
    PubSub.subscribe(pid, topic)
    {:ok, pid}
  end

  def poll() do
    receive do
      message ->
        Logger.info("AircraftHanger received message: " <> Kernel.inspect(message.msg))
      poll()
    end
  end

end
