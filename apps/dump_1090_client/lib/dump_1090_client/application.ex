defmodule Dump1090Client.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Dump1090Client.Network.Client, [host: "127.0.0.1", port: 30003]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dump1090Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
