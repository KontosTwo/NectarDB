defmodule NectarDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  alias NectarDb.Oplog
  alias NectarDb.Communicator
  alias NectarDb.Store
  alias NectarDb.Memtable
  alias NectarDb.Pinger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: NectarDb.Worker.start_link(arg)
      # {NectarDb.Worker, arg},
      worker(Oplog, []),
      worker(Memtable, []),
      worker(Communicator, []),
      worker(Store, []),
      worker(Pinger, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarDb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
