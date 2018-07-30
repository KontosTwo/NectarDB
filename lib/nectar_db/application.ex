defmodule NectarDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  alias NectarDb.Oplog
  alias NectarDb.OtherNodes
  alias NectarDb.Store
  alias NectarDb.Server
  
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: NectarDb.Worker.start_link(arg)
      # {NectarDb.Worker, arg},
      worker(Oplog,[nil]),
      worker(Memtable,[nil]),
      worker(OtherNodes,[nil]),    
      worker(Store,[nil]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarDb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
